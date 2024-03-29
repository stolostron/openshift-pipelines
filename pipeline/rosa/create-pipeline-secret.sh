#!/bin/bash

export NS=${1:-"open-cluster-management-pipelines"}
export SECRET_NAME=${2:-"pipeline-secret"}

oc create secret generic -n $NS rosa-$SECRET_NAME \
--from-literal=aws_access_key_id=$AWS_ACCESS_KEY_ID \
--from-literal=aws_secret_access_key=$AWS_SECRET_ACCESS_KEY \
--from-literal=rosa-access-token=$ROSA_ACCESS_TOKEN \
--from-literal=client-id=$CLIENT_ID \
--from-literal=client-secret-encoded=$CLIENT_SECRET_ENCODED \
--dry-run -o yaml > /tmp/rosa-pipeline-secret.yaml.secret

# gcloud creds encoded is the service account json downloaded and b64 encoded
oc create secret generic -n $NS gcloud-$SECRET_NAME \
--from-literal=gcloud-creds-encoded=$GCLOUD_CREDS_ENCODED \
--dry-run -o yaml > /tmp/gcloud-pipeline-secret.yaml.secret

echo "The secret manifest is generated, to apply, run:"
echo ""
echo "oc apply -f /tmp/rosa-pipeline-secret.yaml.secret"
echo "oc apply -f /tmp/gcloud-pipeline-secret.yaml.secret"
