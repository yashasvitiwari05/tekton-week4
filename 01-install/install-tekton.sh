#!/usr/bin/env bash
set -euo pipefail

echo "=== Installing Tekton Pipelines ==="
kubectl apply --filename https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

echo "=== Waiting for Tekton Pipelines pods to be ready ==="
kubectl wait --for=condition=Ready pod --all \
  --namespace tekton-pipelines \
  --timeout=120s

echo "=== Installing Tekton Dashboard ==="
kubectl apply --filename https://storage.googleapis.com/tekton-releases/dashboard/latest/release.yaml

echo "=== Waiting for Tekton Dashboard pods to be ready ==="
kubectl wait --for=condition=Ready pod --all \
  --namespace tekton-pipelines \
  --timeout=120s

echo "=== Installing Tekton Triggers ==="
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/release.yaml
kubectl apply --filename https://storage.googleapis.com/tekton-releases/triggers/latest/interceptors.yaml

echo "=== Waiting for Tekton Triggers ==="
kubectl wait --for=condition=Ready pod --all \
  --namespace tekton-pipelines \
  --timeout=120s

echo ""
echo "=== Installing tkn CLI (macOS) ==="
brew install tektoncd-cli || echo "Skipping brew – install tkn manually: https://github.com/tektoncd/cli/releases"

echo ""
echo "=== Verification ==="
kubectl get pods       -n tekton-pipelines
kubectl get pipelines  -A 2>/dev/null || true
kubectl get tasks      -A 2>/dev/null || true

echo ""
echo "=== Tekton installation complete ==="
