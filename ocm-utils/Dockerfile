FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

RUN microdnf update -y && microdnf install -y file podman python39 python-pip tar gzip jq wget git make unzip \
    httpd-tools findutils which make gcc

RUN python3 -m pip install --upgrade pip

RUN python3 -m pip install ansible

# Install github 'hub' CLI
RUN curl -sLO https://github.com/github/hub/releases/download/v2.14.2/hub-linux-amd64-2.14.2.tgz -o hub-linux-amd64-2.14.2.tgz && \
    tar xzf hub-linux-amd64-2.14.2.tgz && chmod +x hub-linux-amd64-2.14.2/bin/hub && mv hub-linux-amd64-2.14.2/bin/hub /usr/local/bin/hub && \
    rm hub-linux-amd64-2.14.2.tgz

# Install oc/kubectl
RUN curl -sLO https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz -o openshift-client-linux.tar.gz && \
    tar xzf openshift-client-linux.tar.gz && chmod +x oc && mv oc /usr/local/bin/oc && \
    chmod +x kubectl && mv kubectl /usr/local/bin/kubectl && rm openshift-client-linux.tar.gz

# Install yq
RUN curl -sLO https://github.com/mikefarah/yq/releases/download/v4.16.1/yq_linux_amd64 -o yq_linux_amd64 &&\
    mv yq_linux_amd64 /usr/local/bin/yq && \
    chmod +x /usr/local/bin/yq

# Install go 1.17
RUN curl -sLO https://go.dev/dl/go1.17.6.linux-amd64.tar.gz &&\
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.6.linux-amd64.tar.gz

# Install helm
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    && chmod 700 get_helm.sh \
    && ./get_helm.sh

# Install aws-cli
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm -rf awscliv2.zip && \
    rm -rf aws

# Install rosa-cli
RUN curl -sLO https://mirror.openshift.com/pub/openshift-v4/clients/rosa/latest/rosa-linux.tar.gz -o rosa-linux.tar.gz && \
    tar -xvzf rosa-linux.tar.gz && chmod +x rosa && mv rosa /usr/local/bin/rosa && \
    rm rosa-linux.tar.gz

# Install cm-cli
RUN curl -sLO https://github.com/stolostron/cm-cli/releases/download/v1.0.7/cm_linux_amd64.tar.gz -o cm_linux_amd64.tar.gz && \
    tar -xvzf cm_linux_amd64.tar.gz && chmod +x cm && mv cm /usr/local/bin/cm && \
    rm cm_linux_amd64.tar.gz

# Install ocm cli
RUN mkdir -p ~/bin && \
    curl -Lo ~/bin/ocm https://github.com/openshift-online/ocm-cli/releases/download/v0.1.62/ocm-linux-amd64 && \
    chmod +x ~/bin/ocm && \
    mv ~/bin/ocm /usr/local/bin/ocm

# Install az cli
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    echo -e "[azure-cli]\n\
name=Azure CLI\n\
baseurl=https://packages.microsoft.com/yumrepos/azure-cli\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | tee /etc/yum.repos.d/azure-cli.repo && \
    microdnf -y install azure-cli

# Install gcloud cli
RUN echo -e "[google-cloud-cli]\n\
name=Google Cloud CLI\n\
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64\n\
enabled=1\n\
gpgcheck=0\n\
repo_gpgcheck=0\n\
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg\n\
    https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg" | tee /etc/yum.repos.d/google-cloud-sdk.repo && \
    microdnf -y install google-cloud-cli

# Install eks cli
RUN curl --silent --location https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz | tar xz -C /tmp && \
    mv /tmp/eksctl /usr/local/bin

# Install ibmcloud cli
RUN curl -fsSL https://clis.cloud.ibm.com/install/linux | sh && \
    ibmcloud update

ENV PATH=${PATH}:/usr/local/go/bin
