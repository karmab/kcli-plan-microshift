export CLUSTER_NAME={{ name }}
export KUBECONFIG=kubeconfig.extra
oc new-project ${CLUSTER_NAME}
cat <<EOF | oc apply -f -
apiVersion: agent.open-cluster-management.io/v1
kind: KlusterletAddonConfig
metadata:
  name: ${CLUSTER_NAME}
  namespace: ${CLUSTER_NAME}
spec:
  clusterName: ${CLUSTER_NAME}
  clusterNamespace: ${CLUSTER_NAME}
  applicationManager:
    enabled: true
  certPolicyController:
    enabled: true
  clusterLabels:
    cloud: auto-detect
    vendor: auto-detect
  iamPolicyController:
    enabled: true
  policyController:
    enabled: true
  searchCollector:
    enabled: true
  version: 2.2.0
EOF
cat <<EOF | oc apply -f -
apiVersion: cluster.open-cluster-management.io/v1
kind: ManagedCluster
metadata:
  name: ${CLUSTER_NAME}
spec:
  hubAcceptsClient: true
EOF
sleep 10
IMPORT=`oc get -n ${CLUSTER_NAME} secret ${CLUSTER_NAME}-import -o jsonpath='{.data.import\.yaml}'`
CRDS=`oc get -n ${CLUSTER_NAME} secret ${CLUSTER_NAME}-import -o jsonpath='{.data.crds\.yaml}'`
export KUBECONFIG=kubeconfig

test -f /root/auth.json && podman login registry.redhat.io --authfile /root/auth.json

oc new-project open-cluster-management-agent
oc create secret generic rhacm --from-file=.dockerconfigjson=auth.json --type=kubernetes.io/dockerconfigjson
oc create sa klusterlet
oc patch serviceaccount klusterlet -p '{"imagePullSecrets": [{"name": "rhacm"}]}' -n open-cluster-management-agent
oc create sa klusterlet-registration-sa 
oc patch serviceaccount klusterlet-registration-sa -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-work-sa
oc patch serviceaccount klusterlet-work-sa -p '{"imagePullSecrets": [{"name": "rhacm"}]}'

oc new-project open-cluster-management-agent-addon
oc create secret generic rhacm --from-file=.dockerconfigjson=auth.json --type=kubernetes.io/dockerconfigjson
oc create sa klusterlet-addon-operator
oc patch serviceaccount klusterlet-addon-operator -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-appmgr
oc patch serviceaccount klusterlet-addon-appmgr -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-certpolicyctrl
oc patch serviceaccount klusterlet-addon-certpolicyctrl -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-iampolicyctrl-sa
oc patch serviceaccount klusterlet-addon-iampolicyctrl-sa -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-policyctrl
oc patch serviceaccount klusterlet-addon-policyctrl -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-search
oc patch serviceaccount klusterlet-addon-search -p '{"imagePullSecrets": [{"name": "rhacm"}]}'
oc create sa klusterlet-addon-workmgr
oc patch serviceaccount klusterlet-addon-workmgr -p '{"imagePullSecrets": [{"name": "rhacm"}]}'

oc project open-cluster-management-agent
echo $CRDS | base64 -d | oc apply -f -
echo $IMPORT | base64 -d | oc apply -f -
