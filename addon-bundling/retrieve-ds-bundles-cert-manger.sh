#!/bin/bash
set -e
set -x

source util.sh

overrideCertManagerMetadata () {
    _resultsDir=$1
    _channel=$2
    _operator=$3

    _OPERATOR=$_operator yq eval -i '.annotations."operators.operatorframework.io.bundle.package.v1" = env(_OPERATOR)' ${_resultsDir}/metadata/annotations.yaml
    _CHANNEL=$_channel yq eval -i '.annotations."operators.operatorframework.io.bundle.channels.v1" = env(_CHANNEL)' ${_resultsDir}/metadata/annotations.yaml
    _CHANNEL=$_channel yq eval -i '.annotations."operators.operatorframework.io.bundle.channel.default.v1" = env(_CHANNEL)' ${_resultsDir}/metadata/annotations.yaml
}

overrideCertManagerVersion() {
    _resultsDir=$1
    _version=$2
    _csvName=$3
    
    _VALUE="<${_version}" yq eval -i '.metadata.annotations."olm.skipRange" = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}
    _VALUE="$operator.v${_version}" yq eval -i '.metadata.name = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}
    _VALUE=$_version yq eval -i '.spec.version = strenv(_VALUE)' ${_resultsDir}/manifests/${_csvName}
}

_DOCKER_OR_PODMAN=${_DOCKER_OR_PODMAN:-podman}
if ! command -v ${_DOCKER_OR_PODMAN} &> /dev/null
then
    _DOCKER_OR_PODMAN=docker
fi

rm -rf bundles/cert-manager-operator/*

declare -a bundles=($(yq e -o=j -I=0 '.bundles[]' config-cert-manger.yaml ))
for bundle in "${bundles[@]}"; do

    image=$(echo "$bundle" | yq e '.image' -)
    version=$(echo "$bundle" | yq e '.version' -)
    addonChannel=$(echo "$bundle" | yq e '.addonChannel' -)
    operator=$(echo "$bundle" | yq e '.operator' -)
    resultsDir="bundles/${operator}/main/${version}"
    csvName=${operator}.clusterserviceversion.yaml

    extractBundlesFromImage $image $resultsDir
    overrideCertManagerMetadata $resultsDir $addonChannel $operator
    overrideCertManagerVersion $resultsDir $version $csvName

    echo ""
done
