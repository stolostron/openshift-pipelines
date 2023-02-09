#!/bin/bash
set -e

source util.sh

_DOCKER_OR_PODMAN=podman
if ! command -v ${_DOCKER_OR_PODMAN} &> /dev/null
then
    _DOCKER_OR_PODMAN=docker
fi

rm -rf bundles/*

declare -a bundles=($(yq e -o=j -I=0 '.bundles[]' config.yaml ))
for bundle in "${bundles[@]}"; do

    image=$(echo "$bundle" | yq e '.image' -)
    version=$(echo "$bundle" | yq e '.version' -)
    addonChannel=$(echo "$bundle" | yq e '.addonChannel' -)
    operator=$(echo "$bundle" | yq e '.operator' -)
    parent=$(echo "$bundle" | yq e '.parent' -)
    csvNameOverride=$(echo "$bundle" | yq e '.csvNameOverride' -)

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

    echo ""
done
