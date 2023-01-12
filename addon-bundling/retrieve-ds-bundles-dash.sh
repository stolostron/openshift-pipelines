#!/bin/bash
set -e
set -x

extractBundlesFromImage () {
    _image=$1
    _resultsDir=$2

    echo "== Extracting bundles from image ${_image} =="
    ${_DOCKER_OR_PODMAN} pull "$image"
    ${_DOCKER_OR_PODMAN} save "$image" --output temp.tar
    mkdir -p temp
    tar -xf temp.tar -C temp/

    _bundleURI=(${_image//:/ })
    _bundleURL=${_bundleURI[0]}
    _bundleTag=${_bundleURI[1]}

    _bundleDir=$(cat temp/repositories | jq -r ".\"${_bundleURL}\".\"${_bundleTag}\"")
    
    mkdir -p temp/${_bundleDir}/extractedLayer
    _extractedBundle=temp/${_bundleDir}/extractedLayer
    tar -xf temp/${_bundleDir}/layer.tar -C ${_extractedBundle} 

    echo "Image contents extracted. Copying bundle contents to results directory"
    
    mkdir -p ${_resultsDir}/manifests
    mkdir -p ${_resultsDir}/metadata
        
    cp -r ${_extractedBundle}/manifests/*.yaml ${_resultsDir}/manifests/
    cp -r ${_extractedBundle}/metadata/*.yaml ${_resultsDir}/metadata/

    echo "Results successfully copied. Cleaning up"
    rm -rf temp
    rm temp.tar
}

overrideMetadata () {
    _resultsDir=$1
    _channel=$2

    _CHANNEL=$_channel yq eval -i '.annotations."operators.operatorframework.io.bundle.channels.v1" = env(_CHANNEL)' ${_resultsDir}/metadata/annotations.yaml
    _CHANNEL=$_channel yq eval -i '.annotations."operators.operatorframework.io.bundle.channel.default.v1" = env(_CHANNEL)' ${_resultsDir}/metadata/annotations.yaml
}

fixCSVs () {
    _resultsDir=$1
    _csvName=$2
    yq eval -i 'del(.spec.customresourcedefinitions.owned.[].group)' ${_resultsDir}/manifests/${_csvName}
}

overrideVersionDash() {
    _resultsDir=$1
    _versionDash=$2
    
    _LOWER_BOUND=$(cat ${_resultsDir}/manifests/${_csvName} | yq eval '.metadata.annotations."olm.skipRange"' - | cut -d' ' -f1)

    # Step 1-3: Rename the skipRange, name, version to dash version
    _VALUE="$_LOWER_BOUND <${_versionDash}" yq eval -i '.metadata.annotations."olm.skipRange" = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}
    _VALUE="$operator.v${_versionDash}" yq eval -i '.metadata.name = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}
    _VALUE=$_versionDash yq eval -i '.spec.version = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}

    # Step 4: Rename the csv file dash version
    mv ${_resultsDir}/manifests/${_csvName} ${_resultsDir}/manifests/${operator}.v${_versionDash}.clusterserviceversion.yaml
}

overlayServiceMonitor() {
    for monitor in ocm-grc-policy-propagator-metrics.servicemonitor.yaml
    do
        cp -r ./servicemonitor/$monitor bundles/advanced-cluster-management/main/${addonDash}/manifests
    done
    for monitor in clusterlifecycle-state-metrics-v2.servicemonitor.yaml
    do
        cp -r ./servicemonitor/$monitor bundles/advanced-cluster-management/multicluster-engine/2.2.0-$dash/manifests
    done
}

_DOCKER_OR_PODMAN=${_DOCKER_OR_PODMAN:-podman}
if ! command -v ${_DOCKER_OR_PODMAN} &> /dev/null
then
    _DOCKER_OR_PODMAN=docker
fi

rm -rf bundles/*

declare -a bundles=($(yq e -o=j -I=0 '.bundles[]' config-dash.yaml ))
for bundle in "${bundles[@]}"; do

    image=$(echo "$bundle" | yq e '.image' -)
    version=$(echo "$bundle" | yq e '.version' -)
    addonChannel=$(echo "$bundle" | yq e '.addonChannel' -)
    operator=$(echo "$bundle" | yq e '.operator' -)
    parent=$(echo "$bundle" | yq e '.parent' -)
    csvNameOverride=$(echo "$bundle" | yq e '.csvNameOverride' -)
    dash=$(echo "$bundle" | yq e '.dash' -)

    if [[ "$parent" != "null" ]]; then
        resultsDir="bundles/${parent}/${operator}/${version}"
    else
        resultsDir="bundles/${operator}/main/${version}"
    fi

    if [[ "$csvNameOverride" != "null" ]]; then
        csvName=${csvNameOverride}.v${version}.clusterserviceversion.yaml
    else
        csvName=${operator}.v${version}.clusterserviceversion.yaml
    fi

    extractBundlesFromImage $image $resultsDir
    overrideMetadata $resultsDir $addonChannel
    fixCSVs $resultsDir $csvName

    export versionDash=$version-$dash
    export addon="3.7.0"
    export addonDash=$addon-$dash

    overrideVersionDash $resultsDir $versionDash

    # Step 5: rename folder addon version to dash version
    if [[ "$parent" != "null" ]]; then
        mv $resultsDir bundles/${parent}/${operator}/${versionDash}
    else
        mv $resultsDir bundles/${operator}/main/${addonDash}
    fi

    echo ""
done

overlayServiceMonitor
