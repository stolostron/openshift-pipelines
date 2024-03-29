# KCP Compute Operator Pipeline

## About

This repo contains a pipeline and its associated tasks and resources to create and configure the cluster for the Singapore Gateway Service. 

* This pipeline is currently hosted on Collective in the `managed-services` namespace.
* This pipeline can be triggered from there
* This pipeline can be re-triggered/re-run to reconfigure an existing KCP SGS cluster

## Prereqs

The following prereqs are required to run this Pipeline -

1. An OCP Cluster (4.8+ recommended) with the following Operators installed -
    * OpenShift Pipelines
    * Advanced Cluster Management (2.4+ recommended). The MultiClusterHub CR must be installed and Running.
2. A Clusterpool must be configured in the same namespace of the Pipeline. 
    * Currently the Pipeline expects a clusterpool called `hypershift-cluster-pool`.
    * The [clusterPoolName](pipeline.yaml#L36) parameter can be updated in the task to claim from a different pool if required.
3. The following secrets must be defined in the same namespace of the Pipeline.
    * See [secrets_template.yaml](prereqs/secrets_template.yaml) for a template of the secret which must be applied.

## How to deploy

To deploy the Pipelines run:

```bash
# oc apply -f folder/ -n <NAMESPACE>
oc apply -f kcp-co-pipelines/ -n managed-services
```

## Design

* The `pipeline.yaml` references the list of `tasks` that will be performed.
* This folder will contain `task` definitions used by the pipeline.
* Some tasks may exist in the namespace or server, or basically, we can have `duplicates` of tasks.
* We will give each tasks "unique" names for now.