#!/bin/bash

ns=$1

if [ "$ns" = "" ]
then
  echo "namespace is not set!"
  exit
fi

echo "create namespace"
kubectl create namespace ${ns}

echo "deploy-etcd"
kubectl apply -f  deploy-etcd-cluster.yml  -n ${ns}

echo "deploy-apisix-gw"
sed -i -e "s%{YOUR_NAMESPACE}%apisix%g" apisix-config.yml
kubectl create configmap  apisix-config   --from-file=apisix-config.yml -n ${ns}
kubectl apply -f deploy-apisix-gw.yml -n ${ns}
# 如果集群中没有部署prometheus-operator，则不需要执行
kubectl apply -f apisix-service-monitor-for-prometheus.yml -n ${ns}

echo "deploy-apisix-mysql"
cp apisix-manager-schema.sql mysql-custom-init.sql
kubectl create configmap  mysql-custom-init   --from-file=mysql-custom-init.sql -n ${ns}
kubectl apply -f deploy-apisix-mysql.yml  -n ${ns}

echo "deploy-apisix-manager"
kubectl apply -f deploy-apisix-manager.yml  -n ${ns}

echo "deploy-apisix-dashboard"
kubectl apply -f deploy-apisix-dashboard.yml -n ${ns}