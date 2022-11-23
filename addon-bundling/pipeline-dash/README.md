## How this works

1. We want to be able to generate the manifest files form a given set of bundle images.
2. We then want to run the `managedtenants` cli to generate the MTB bundles and index images.

2.1 We saw that the `managedtenants` cli requires `docker`, which we don't immediately run in Pipelines.
2.2 To run `docker` commands, we need to setup docker in docker and perhaps privilege mode.
2.3 Getting an dnd container with python to run `managedtenants` cli may be something new to work out.
2.4 Would be nice to see how CICD is running this, perhaps as a jenkins job that has access to docker.
2.5 We can run `managedtenants` cli on macos with `docker` desktop running.

## Usage

1. oc new project open-cluster-management-pipelines-ocm-addon
2. oc apply -f ./addon-bundling/pipeline-dash/.prereqs/secret.yaml.secret
