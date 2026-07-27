# Tekton Week-4 Assignment

## Directory Structure

```
tekton-week4/
├── 01-install/
│   ├── install-tekton.sh          # Install Tekton Pipelines, Dashboard & Triggers
│   └── verify.sh                  # Verify installation
├── 02-tasks/
│   ├── task-clone-repo.yaml       # Task: Clone Repository
│   ├── task-print-files.yaml      # Task: Print Files
│   ├── task-validate-yaml.yaml    # Task: Validate YAML
│   └── taskruns/
│       ├── taskrun-clone.yaml
│       ├── taskrun-print-files.yaml
│       └── taskrun-validate-yaml.yaml
├── 03-pipeline/
│   ├── pipeline.yaml              # Complete CI Pipeline
│   └── pipelinerun.yaml           # PipelineRun to trigger it
├── 04-secrets/
│   ├── git-secret.yaml            # Git credentials secret
│   ├── registry-secret.yaml       # Docker registry secret
│   ├── service-account.yaml       # ServiceAccount + RBAC
│   └── task-kubernetes-deploy.yaml
├── 05-reliability/
│   ├── pipeline-reliable.yaml     # Pipeline with retries/timeouts/finally
│   ├── task-run-tests.yaml
│   ├── task-workspace-cleanup.yaml
│   └── task-send-notification.yaml
└── 06-expert/
    ├── cluster-task-security-scan.yaml   # ClusterTask: Trivy security scan
    ├── triggers/
    │   ├── event-listener.yaml
    │   ├── trigger-binding.yaml
    │   ├── trigger-template.yaml
    │   └── rbac-triggers.yaml
    ├── blue-green/
    │   └── pipeline-blue-green.yaml
    ├── pac/
    │   └── pipelinerun-pac.yaml
    └── resource-optimization/
        └── pipeline-optimized.yaml
```

## Quick Start

### 1. Install Tekton
```bash
chmod +x 01-install/install-tekton.sh
./01-install/install-tekton.sh
```

### 2. Apply Tasks
```bash
kubectl apply -f 02-tasks/task-clone-repo.yaml
kubectl apply -f 02-tasks/task-print-files.yaml
kubectl apply -f 02-tasks/task-validate-yaml.yaml
```

### 3. Run Individual Tasks
```bash
kubectl create -f 02-tasks/taskruns/taskrun-clone.yaml
kubectl create -f 02-tasks/taskruns/taskrun-print-files.yaml
kubectl create -f 02-tasks/taskruns/taskrun-validate-yaml.yaml

# Watch progress
tkn taskrun logs --last -f
```

### 4. Apply & Run Full Pipeline
```bash
# Secrets first
kubectl apply -f 04-secrets/service-account.yaml
kubectl apply -f 04-secrets/git-secret.yaml
kubectl apply -f 04-secrets/registry-secret.yaml

# Tasks
kubectl apply -f 02-tasks/
kubectl apply -f 04-secrets/task-kubernetes-deploy.yaml
kubectl apply -f 05-reliability/task-run-tests.yaml
kubectl apply -f 05-reliability/task-workspace-cleanup.yaml
kubectl apply -f 05-reliability/task-send-notification.yaml

# Pipelines
kubectl apply -f 03-pipeline/pipeline.yaml
kubectl apply -f 05-reliability/pipeline-reliable.yaml

# Run it
kubectl create -f 03-pipeline/pipelinerun.yaml
tkn pipelinerun logs --last -f
```

### 5. Apply Expert Resources
```bash
kubectl apply -f 06-expert/cluster-task-security-scan.yaml
kubectl apply -f 06-expert/triggers/
kubectl apply -f 06-expert/resource-optimization/pipeline-optimized.yaml
```

### 6. Verify Deployment
```bash
kubectl get pods
kubectl get svc
kubectl rollout status deployment/myapp -n default
```

## Verification Commands
```bash
kubectl get pods -n tekton-pipelines
kubectl get pipelines -A
kubectl get tasks -A
kubectl get clustertasks
tkn pipeline list
tkn task list
tkn pipelinerun list
tkn taskrun list
```
