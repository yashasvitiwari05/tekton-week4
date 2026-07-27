#!/usr/bin/env bash
set -euo pipefail

echo "--- Pods in tekton-pipelines ---"
kubectl get pods -n tekton-pipelines

echo ""
echo "--- Pipelines (all namespaces) ---"
kubectl get pipelines -A 2>/dev/null || echo "(none yet)"

echo ""
echo "--- Tasks (all namespaces) ---"
kubectl get tasks -A 2>/dev/null || echo "(none yet)"

echo ""
echo "--- tkn version ---"
tkn version
