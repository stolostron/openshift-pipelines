#!/bin/bash
set -e

extractBundlesFromImage () {
    _image=$1
    _resultsDir=$2

    echo "== Extracting bundles from image ${_image} =="

    if [[ $_DOCKER_OR_PODMAN == "podman" ]]; then
        cat > /etc/containers/registries.conf.d/myregistry.conf << EOF
    [[registry]]
    location = "registry-proxy.engineering.redhat.com"
    insecure = true
    EOF

    fi

    ${_DOCKER_OR_PODMAN} pull --platform linux/x86_64 --tls-verify false "$image"
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
