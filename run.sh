#!/usr/bin/env bash

set -eo pipefail

if [ -z "${PLUGIN_K3D_CLUSTER_NAME}" ] && [ -z "${K3D_CLUSTER_NAME}" ];
then
	echo "Please set K3D cluster name"
	exit 1
fi

if [ -z "${K3D_CLUSTER_NAME}" ];
then 
  K3D_CLUSTER_NAME="${PLUGIN_K3D_CLUSTER_NAME}"
fi

if [ -z "${PLUGIN_DAG_STACK_CLONE_PATH}" ];
then
	echo "Please set path where dag-stack is cloned"
	exit 1
fi

direnv allow . && eval "$(direnv export bash)"
# since the kubeconfig in the container is set to /apps/.config
unset KUBECONFIG

configs_path=/apps/configs
mkdir -p "${configs_path}"

if [ "${PLUGIN_CREATE_K3D_CLUSTER}" == "true" ] || [ "${PLUGIN_CREATE_K3D_CLUSTER}" == "yes" ];
then
  printf "\n Creating k3d cluster \n"
  envsubst < "${PLUGIN_DAG_STACK_CLONE_PATH}/hack/k3s-cluster-config.yaml.tpl" > "${configs_path}/k3s-cluster-config.yaml"
  envsubst < "${PLUGIN_DAG_STACK_CLONE_PATH}/config/etc/rancher/k3s/registries.yaml" > "${configs_path}/registries.yaml"
  k3d cluster create \
    --config "${configs_path}/k3s-cluster-config.yaml" \
    --registry-config "${configs_path}/registries.yaml"
fi

# Export/Override KUBECONFIG
export KUBECONFIG=/apps/.kube/config
chmod 0700 "$KUBECONFIG"
k3d kubeconfig get "${K3D_CLUSTER_NAME}" > "${KUBECONFIG}"

OLDIFS=$IFS
IFS=', ' read -r -a installable_components <<< "$PLUGIN_INSTALL_COMPONENTS"
IFS=$OLDIFS

INSTALL_CHECK_SCRIPTS=()
for c in "${installable_components[@]}"
do
  INSTALL_CHECK_SCRIPTS+=("${PLUGIN_DAG_STACK_CLONE_PATH}/hack/install-${c}")
  if [ "${PLUGIN_CHECK_INSTALL}" ];
  then
    INSTALL_CHECK_SCRIPTS+=("${PLUGIN_DAG_STACK_CLONE_PATH}/hack/check-${c}")
  fi
done
OLDIFS=$IFS
INSTALL_CHECK_SCRIPTS=("$(IFS="~" ; echo "${INSTALL_CHECK_SCRIPTS[*]}")")
cmd="${INSTALL_CHECK_SCRIPTS/'~'/' && '}"
IFS=$OLDIFS

printf "\nRunning scripts %s" "${cmd}\n"
exec bash -c "${cmd}"
