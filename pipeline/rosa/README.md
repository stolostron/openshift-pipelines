# Pipelines for ROSA deployment

Use this pipeline to work with ROSA clusters. Two pipelines are provided--create cluster, and delete all clusters.

* Install these pipelines in any namespace, that can run Openshift Pipelines.
* In order to import the clusters into RHACM or MCE, you will need cluster-admin roles to perform the import.
* In order to provision ROSA cluster, you will need a ROSA API token.

| pipeline        | tasks                        |
|-----------------|------------------------------|
| rosa-create     | task-rosa-create-cluster     |
| rosa-delete-all | task-rosa-delete-all-cluster |

## Setup

1. Apply the pipeline and tasks manifests:
```bash
export NS="your-work-namespace"
# example, I place all my ACM related pipelines in open-cluster-management-pipelines
oc apply -f pipeline/rosa/ -n $NS
```

2. Create the credential secret in the namespace where the pipeline will run:
```bash
# create the secret ./create-pipeline-secrets.sh <your-work-namespace> <secret name>
./create-pipeline-secret.sh open-cluster-management rosa-pipeline-secret
```

## Usage

```bash
# verify you have connection to console.redhat.com, and your api token is valid
rosa list clusters

# switch to your pipeline namespace
oc project open-cluster-management-pipelines

# start a pipeline run to create a cluster
tkn pipeline start rosa-create-cluster \
-p API_ENDPOINT=https://api.example.com:6443 \
-p namespace=open-cluster-management-pipelines \
-w name=shared-workspace,claimName=shared-storage-pvc

# delete all rosa clsuters associated to your current account
tkn pipeline start rosa-delete-cluster-all \
-p API_ENDPOINT=https://api.example.com:6443 \
-p namespace=open-cluster-management-pipelines \
-w name=shared-workspace,claimName=shared-storage-pvc

```
