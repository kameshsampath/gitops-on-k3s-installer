#!/usr/bin/env bash

set -exo pipefail

if [ -z "${PLUGIN_K3D_CLUSTER_NAME}" ] && [ -z "${K3D_CLUSTER_NAME}" ];
then
	echo "Please set K3D cluster name"
	exit 1
fi

if [ -z "${K3D_CLUSTER_NAME}" ];
then 
  K3D_CLUSTER_NAME="${PLUGIN_K3D_CLUSTER_NAME}"
fi

if [ -z "${PLUGIN_INSTALL_SOURCE}" ];
then
	PLUGIN_INSTALL_SOURCE=https://github.com/kameshsampath/gitops-on-k3s
fi

if [ -z "${PLUGIN_CLONE_PATH}" ];
then
	PLUGIN_CLONE_PATH=/tmp/work
fi

git clone "${PLUGIN_INSTALL_SOURCE}" "${PLUGIN_CLONE_PATH}"
cd "${PLUGIN_CLONE_PATH}"

direnv allow . && eval "$(direnv export bash)"

# overload the K3D_CLUSTER_NAME using PLUGIN_K3D_CLUSTER_NAME 
unset K3D_CLUSTER_NAME
unset DOCKER_NETWORK_NAME
export K3D_CLUSTER_NAME="${PLUGIN_K3D_CLUSTER_NAME}"
export DOCKER_NETWORK_NAME="${PLUGIN_K3D_CLUSTER_NAME}"
# since the kubeconfig in the container is set to /apps/.config
unset KUBECONFIG

if [ -n "${PLUGIN_DELETE_CLUSTER}" ];
then
  #. hack/kill.sh
  [[ -d "${DRONE_WORKSPACE}/.kube" ]] &&  rm -rf "${DRONE_WORKSPACE}/.kube"
  exit 0
fi


configs_path=/apps/configs
mkdir -p "${configs_path}"

if [ "${PLUGIN_CREATE_CLUSTER}" == "true" ] || [ "${PLUGIN_CREATE_CLUSTER}" == "yes" ];
then
  printf "\n Creating k3d cluster \n"
  . hack/cluster.sh
fi

mkdir -p "$DRONE_WORKSPACE/.kube"
k3d kubeconfig get "${K3D_CLUSTER_NAME}" > "$DRONE_WORKSPACE/.kube/config"
sed -i 's|host.docker.internal|127.0.0.1|g' "$DRONE_WORKSPACE/.kube/config"
k3d kubeconfig get "${K3D_CLUSTER_NAME}" > "$DRONE_WORKSPACE/.kube/config.internal"
chmod 0700 -R "$DRONE_WORKSPACE/.kube"

export KUBECONFIG="$DRONE_WORKSPACE/.kube/config.internal"

OLDIFS=$IFS
IFS=', ' read -r -a installable_components <<< "$PLUGIN_INSTALL_COMPONENTS"
IFS=$OLDIFS

INSTALL_CHECK_SCRIPTS=()
for c in "${installable_components[@]}"
do
  INSTALL_CHECK_SCRIPTS+=("hack/install-${c}")
  if [ -n "${PLUGIN_CHECK_INSTALL}" ];
  then
    INSTALL_CHECK_SCRIPTS+=("hack/check-${c}")
  fi
done

cmd=$(printf " && %s" "${INSTALL_CHECK_SCRIPTS[@]}")
cmd=${cmd:3}
printf "\nRunning scripts %s\n" "${cmd}"
exec bash -c "${cmd}"
