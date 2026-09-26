#!/usr/bin/env bash

set -euo pipefail

# ---------------------------------------------------------
# Jenkins -> Kubernetes Bootstrap
# ---------------------------------------------------------
# Purpose:
#   Prepare Kubernetes access required by Jenkins CI/CD.
#   Creates/updates the Jenkins ServiceAccount and RBAC
#   permissions and verifies deployment access.
# ---------------------------------------------------------

NAMESPACE="enterprise-dev"
SERVICE_ACCOUNT="jenkins-deployer"

SERVICE_ACCOUNT_MANIFEST="kubernetes/jenkins/service-account.yaml"
RBAC_MANIFEST="kubernetes/jenkins/rbac.yaml"

echo "=========================================="
echo " Jenkins -> Kubernetes Bootstrap"
echo "=========================================="

# ---------------------------------------------------------
# 1. Check required commands
# ---------------------------------------------------------

echo "Checking required tools..."

for command in kubectl docker; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "ERROR: $command is not installed or not available in PATH."
        exit 1
    fi
done

echo "Required tools are available."


# ---------------------------------------------------------
# 2. Check Kubernetes cluster connectivity
# ---------------------------------------------------------

echo "Checking Kubernetes cluster connectivity..."

if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Kubernetes cluster is not reachable."
    exit 1
fi

echo "Kubernetes cluster is reachable."


# ---------------------------------------------------------
# 3. Check required Kubernetes manifest files
# ---------------------------------------------------------

echo "Checking Kubernetes manifests..."

if [[ ! -f "$SERVICE_ACCOUNT_MANIFEST" ]]; then
    echo "ERROR: $SERVICE_ACCOUNT_MANIFEST not found."
    exit 1
fi

if [[ ! -f "$RBAC_MANIFEST" ]]; then
    echo "ERROR: $RBAC_MANIFEST not found."
    exit 1
fi

echo "Required Kubernetes manifests are available."


# ---------------------------------------------------------
# 4. Apply Jenkins ServiceAccount
# ---------------------------------------------------------

echo "Applying Jenkins ServiceAccount..."

kubectl apply -f "$SERVICE_ACCOUNT_MANIFEST"


# ---------------------------------------------------------
# 5. Apply Jenkins RBAC configuration
# ---------------------------------------------------------

echo "Applying Jenkins RBAC..."

kubectl apply -f "$RBAC_MANIFEST"


# ---------------------------------------------------------
# 6. Verify Jenkins deployment permission
# ---------------------------------------------------------

echo "Verifying Jenkins deployment permissions..."

if ! kubectl auth can-i patch deployments \
    --namespace="$NAMESPACE" \
    --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
    | grep -q "^yes$"; then

    echo "ERROR: Jenkins ServiceAccount cannot patch deployments."
    exit 1
fi

echo "Jenkins ServiceAccount can patch deployments."


# ---------------------------------------------------------
# 7. Verify Jenkins does NOT have cluster-admin-like access
# ---------------------------------------------------------

echo "Checking least-privilege restriction..."

if kubectl auth can-i delete namespaces \
    --as="system:serviceaccount:${NAMESPACE}:${SERVICE_ACCOUNT}" \
    2>/dev/null \
    | grep -q "^yes$"; then

    echo "ERROR: Jenkins ServiceAccount has excessive cluster permissions."
    exit 1
fi

echo "Least-privilege RBAC verification passed."


# ---------------------------------------------------------
# Bootstrap completed
# ---------------------------------------------------------

echo "=========================================="
echo " Jenkins Kubernetes bootstrap completed."
echo "=========================================="