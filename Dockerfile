FROM cytopia/terragrunt

#FROM amazon/aws-cli as aws
#COPY --from=cytopia/terragrunt /usr/bin/terraform /usr/bin/terraform
#COPY --from=cytopia/terragrunt /usr/bin/terragrunt /usr/bin/terragrunt

RUN apk add --update \
  curl bash jq bash-completion make\
  gettext moreutils openssl\
  python3 py3-pip tar\
  && pip3 install --upgrade pip \
  #&& pip3 install awscli --upgrade --user \
  && pip3 install --no-cache-dir \ 
  awscli==1.21.0\
  && rm -rf /var/cache/apk/*

# RUN curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"  \
#   && unzip awscli-bundle.zip \
#   && ./awscli-bundle/install -i /usr/local/aws -b /usr/local/bin/aws

RUN aws --version

RUN wget -q -O /usr/bin/yq $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/latest | jq -r '.assets[] | select(.name == "yq_linux_amd64") | .browser_download_url') \
  && chmod +x /usr/bin/yq

# Install kubectl from Docker Hub.
COPY --from=line/kubectl-kustomize /usr/local/bin/kubectl /usr/local/bin/kubectl
COPY --from=line/kubectl-kustomize /usr/local/bin/kustomize /usr/local/bin/kustomize

RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 \
  && chmod 700 get_helm.sh \
  &&  ./get_helm.sh

RUN VERSION=$(curl --silent "https://api.github.com/repos/argoproj/argo-cd/releases/latest" | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/') && \
  curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/download/$VERSION/argocd-linux-amd64 && \
  chmod +x /usr/local/bin/argocd

RUN curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/aws-iam-authenticator && \
  chmod +x ./aws-iam-authenticator && mkdir -p $HOME/bin && cp ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator && export PATH=$PATH:$HOME/bin && \
  echo 'export PATH=$PATH:$HOME/bin' >> ~/.bashrc

RUN curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp && \
  mv -v /tmp/eksctl /usr/local/bin

# cert-manager plugin
RUN curl -L -o kubectl-cert-manager.tar.gz https://github.com/jetstack/cert-manager/releases/latest/download/kubectl-cert_manager-linux-amd64.tar.gz && \
  tar xzf kubectl-cert-manager.tar.gz && \
  mv kubectl-cert_manager /usr/local/bin
#https://docs.aws.amazon.com/eks/latest/userguide/create-kubeconfig.html

#RUN eksctl completion bash >> ~/.bash_completion && \
#  . /etc/profile.d/bash_completion.sh 
#&& . ~/.bash_completion  

#    helm completion bash >> ~/.bash_completion
# . /etc/profile.d/bash_completion.sh
# . ~/.bash_completion
# source <(helm completion bash)

RUN curl -sSLO https://raw.githubusercontent.com/ahmetb/kubectx/master/kubectx \ 
  && chmod 755 kubectx \ 
  && mv kubectx /usr/local/bin


  #ARGO CLI
RUN curl -sLO https://github.com/argoproj/argo-workflows/releases/download/v3.2.4/argo-linux-amd64.gz && \
  gunzip argo-linux-amd64.gz && \
  chmod +x argo-linux-amd64 && \ 
  mv ./argo-linux-amd64 /usr/local/bin/argo

# RUN SNIPPET="export PROMPT_COMMAND='history -a' && export HISTFILE=/commandhistory/.bash_history" \
#     && echo $SNIPPET >> "/root/.bashrc"

RUN curl -sL https://raw.githubusercontent.com/crossplane/crossplane/master/install.sh | sh \
  && mv kubectl-crossplane /usr/local/bin

# kubeflow cli
RUN curl -sLO https://github.com/kubeflow/kfctl/releases/download/v1.2.0/kfctl_v1.2.0-0-gbc038f9_linux.tar.gz && \
  tar -xvf kfctl_v1.2.0-0-gbc038f9_linux.tar.gz && \
  chmod +x kfctl && \ 
  mv ./kfctl /usr/local/bin

ENV CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws_cognito.v1.2.0.yaml"
ENV AWS_CLUSTER_NAME="labs"

EXPOSE 8080
WORKDIR /data
CMD ["terragrunt", "--version"]


