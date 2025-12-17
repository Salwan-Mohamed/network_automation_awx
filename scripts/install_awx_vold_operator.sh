#!/usr/bin/env bash
set -euo pipefail

############################################
# CONFIGURATION
############################################
AWX_NAMESPACE="awx"
AWX_VERSION="23.6.0"
NODEPORT="30080"

POSTGRES_CONTAINER="awx-postgres"
POSTGRES_USER="awx"
POSTGRES_PASSWORD="awxpass"
POSTGRES_DB="awx"
POSTGRES_HOST="host.minikube.internal"
POSTGRES_PORT="5433"

ADMIN_PASSWORD="Admin@12345"

############################################
# PRECHECKS
############################################
echo "🔍 Checking prerequisites..."

for cmd in docker kubectl minikube; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "❌ $cmd not found. Install it first."
    exit 1
  fi
done

############################################
# START MINIKUBE
############################################
echo "🚀 Starting Minikube..."
minikube status >/dev/null 2>&1 || minikube start --driver=docker

############################################
# POSTGRES (EXTERNAL - DOCKER)
############################################
echo "🐘 Setting up external PostgreSQL..."

if docker ps -a --format '{{.Names}}' | grep -q "^${POSTGRES_CONTAINER}$"; then
  echo "⚠️ Existing postgres container found, removing..."
  docker rm -f ${POSTGRES_CONTAINER}
fi

docker run -d \
  --name ${POSTGRES_CONTAINER} \
  -e POSTGRES_USER=${POSTGRES_USER} \
  -e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
  -e POSTGRES_DB=${POSTGRES_DB} \
  -p ${POSTGRES_PORT}:5432 \
  postgres:15

############################################
# INSTALL AWX OPERATOR
############################################
echo "📦 Installing AWX Operator..."

kubectl create ns ${AWX_NAMESPACE} --dry-run=client -o yaml | kubectl apply -f -

kubectl apply -n ${AWX_NAMESPACE} \
  -f https://raw.githubusercontent.com/ansible/awx-operator/2.14.0/deploy/awx-operator.yaml

echo "⏳ Waiting for AWX Operator..."
kubectl rollout status deployment/awx-operator-controller-manager -n ${AWX_NAMESPACE}

############################################
# SECRETS
############################################
echo "🔐 Creating secrets..."

kubectl delete secret awx-admin-password -n ${AWX_NAMESPACE} --ignore-not-found
kubectl create secret generic awx-admin-password \
  --from-literal=password=${ADMIN_PASSWORD} \
  -n ${AWX_NAMESPACE}

kubectl delete secret awx-postgres-configuration -n ${AWX_NAMESPACE} --ignore-not-found
kubectl create secret generic awx-postgres-configuration \
  --from-literal=host=${POSTGRES_HOST} \
  --from-literal=port=${POSTGRES_PORT} \
  --from-literal=database=${POSTGRES_DB} \
  --from-literal=username=${POSTGRES_USER} \
  --from-literal=password=${POSTGRES_PASSWORD} \
  -n ${AWX_NAMESPACE}

############################################
# AWX MANIFEST
############################################
echo "🧩 Deploying AWX..."

cat <<EOF | kubectl apply -f -
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: awx
  namespace: ${AWX_NAMESPACE}
spec:
  service_type: NodePort

  image: ghcr.io/ansible/awx
  image_version: ${AWX_VERSION}
  image_pull_policy: IfNotPresent

  admin_user: admin
  admin_password_secret: awx-admin-password

  replicas: 1

  postgres_configuration_secret: awx-postgres-configuration

  web_resource_requirements:
    requests:
      cpu: 300m
      memory: 512Mi
    limits:
      cpu: 600m
      memory: 1Gi

  task_resource_requirements:
    requests:
      cpu: 600m
      memory: 1Gi
    limits:
      cpu: "1"
      memory: 2Gi

  task_readiness_initial_delay: 60
  task_liveness_initial_delay: 60
  task_readiness_timeout: 5
  task_liveness_timeout: 5
  task_readiness_period: 10
  task_liveness_period: 10
  task_readiness_failure_threshold: 10
  task_liveness_failure_threshold: 10
EOF

############################################
# WAIT FOR PODS
############################################
echo "⏳ Waiting for AWX pods..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=awx-web -n ${AWX_NAMESPACE} --timeout=600s
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/name=awx-task -n ${AWX_NAMESPACE} --timeout=600s

############################################
# FIX NODEPORT
############################################
echo "🌐 Setting fixed NodePort ${NODEPORT}..."

kubectl patch svc awx-service -n ${AWX_NAMESPACE} -p "{
  \"spec\": {
    \"type\": \"NodePort\",
    \"ports\": [{
      \"port\": 80,
      \"targetPort\": 8052,
      \"nodePort\": ${NODEPORT}
    }]
  }
}"

############################################
# OUTPUT
############################################
MINIKUBE_IP=$(minikube ip)

cat <<EOF

✅ AWX INSTALLED SUCCESSFULLY

URL:
  http://${MINIKUBE_IP}:${NODEPORT}

LOGIN:
  Username: admin
  Password: ${ADMIN_PASSWORD}

PostgreSQL:
  Host: ${POSTGRES_HOST}
  Port: ${POSTGRES_PORT}

EOF
