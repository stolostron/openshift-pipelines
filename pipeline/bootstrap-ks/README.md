# bootstrap-ks pipeline

This pipeline leverages the bootstrap-ks repo to provision and import clusters into RHACM/MCE.


```bash
# navigate to the pipeline workspace
oc project open-cluster-management-pipelines

# create a new rosa cluster with a generated cluster name
tkn pipeline start bootstrap-mce -w name=shared-workspace,claimName=shared-storage-pvc -p action=create -p target=rosa
```
