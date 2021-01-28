# Jenkins kubernetes helm deployment with custom jenkins configuration
# One click Jenkins deployment in kubernetes cluster using helm with custom jenkins default configurations

function helm_update {
  echo "Updating helm repo"
  helm repo add stable "https://charts.helm.sh/stable"
  helm repo update
  helm repo add local http://localhost:8879/charts
}

function repo_clone {
 echo "Cloning required repos"
 git clone https://review.gerrithub.io/att-comdev/charts
 git clone https://opendev.org/openstack/openstack-helm-infra.git || true
}

function build_helm_infra_chart {
  echo "Building openstack helm infra chart"
  cd openstack-helm-infra
  make helm-toolkit
}

function copy_infra_chart {
     echo "Copying helm infra chart in jenkins"
     fileName=`ls helm-toolkit-*tgz`
     tar -xvzf $fileName
     cd ..
     mv charts/jenkins .
     mkdir -p jenkins/charts
     cp -r openstack-helm-infra/helm-toolkit jenkins/charts
}

function update_node_label {
   echo "Updating node labels for jenkins"
   kubectl label nodes --all openstack-control-plane=enabled
}

function create_jenkins_pv {
   echo "Creating persistant volume for jenkins"
   kubectl apply -f create_kubernetes_jenkins_pv.yaml
}

function deploy_jenkins_chart {
 echo "Deploying jenkins helm chart"
 kubectl create ns jenkins || true	
 helm install jenkins --debug -f values.yaml ./jenkins --namespace jenkins
}

function display_jenkins_pods {
   echo "Displaying jenkins pod, job and services"
   helm list -n jenkins
   kubectl get all -n jenkins-nodes -o wide
   kubectl get all -n jenkins -o wide
   kubectl get ingress -n jenkins
}

function create_jenkins_node {
   echo "Creating jenkins executor"	
   mkdir -p /mnt/data/nodes/dev
   cp config.xml /mnt/data/nodes/dev/
}

function finish {
  node_ip=`kubectl get service/jenkins -n jenkins | awk '{print $3}' | tail -1`
  printf "\n******************************************************************************************************************************************\n"
  echo "Jeknins UI will take ~5-10 mins time to come up and will be avaiable at node $node_ip:8080 or https://jenkins.kubernetes.demo/"
  printf "\n******************************************************************************************************************************************\n"
}


repo_clone
helm_update
build_helm_infra_chart
copy_infra_chart
update_node_label
create_jenkins_pv
display_jenkins_pods
deploy_jenkins_chart
create_jenkins_node
finish
