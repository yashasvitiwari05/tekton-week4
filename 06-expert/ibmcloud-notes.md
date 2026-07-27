# IBM Cloud / OpenShift Pipelines — Enterprise Integration Notes

## How This Pipeline Fits into IBM Cloud Continuous Delivery

### IBM Cloud Continuous Delivery Toolchain
IBM Cloud Continuous Delivery provides a managed Tekton runtime (hosted pipelines)
inside a Toolchain. The `ci-pipeline-reliable` defined in this assignment maps
directly to an IBM Cloud Tekton pipeline with **zero code changes**; only the
workspace PersistentVolumeClaim and secret bindings differ.

```
IBM Cloud Toolchain
└── Tekton Pipeline (managed)
    ├── PipelineRun  ← triggered by GitHub/GitLab webhook via EventListener
    ├── Tasks        ← same YAML, uploaded as pipeline definitions
    └── Secrets      ← stored in IBM Secrets Manager, injected at runtime
```

### Image Registry — IBM Container Registry (ICR)
Replace `docker.io/yourorg/yourapp` with `icr.io/<namespace>/yourapp`.

```bash
# Create ICR namespace
ibmcloud cr namespace-add my-namespace

# Create registry secret
kubectl create secret docker-registry registry-credentials \
  --docker-server=icr.io \
  --docker-username=iamapikey \
  --docker-password=$(ibmcloud iam api-key-create tekton-key -q) \
  --docker-email=user@example.com
```

### RBAC & Service Accounts on OpenShift
OpenShift (RHOCP) ships **OpenShift Pipelines** (Tekton operator).
The `pipeline-sa` ServiceAccount must have an SCC (Security Context Constraint):

```bash
oc adm policy add-scc-to-user privileged \
  -z pipeline-sa \
  -n my-namespace
```

### Secrets — IBM Secrets Manager Integration
Use the **Secrets Store CSI Driver** or **External Secrets Operator** to
pull secrets from IBM Secrets Manager at pod start time instead of storing
them as Kubernetes Secrets.

```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: registry-credentials
spec:
  secretStoreRef:
    name: ibm-secrets-manager
    kind: SecretStore
  target:
    name: registry-credentials
  data:
    - secretKey: .dockerconfigjson
      remoteRef:
        key: registry-creds
        property: dockerconfigjson
```

### Enterprise Security Considerations

| Concern | Solution |
|---|---|
| Image signing | Cosign / Notary v2 – sign after `kaniko` build, verify before deploy |
| Vulnerability scanning | Trivy ClusterTask (see `06-expert/cluster-task-security-scan.yaml`) |
| Secret rotation | IBM Secrets Manager + External Secrets Operator |
| Network policies | Isolate `tekton-pipelines` namespace with NetworkPolicy |
| Audit logging | IBM Log Analysis (LogDNA) for all PipelineRun events |
| RBAC least-privilege | Separate SAs for triggers, pipeline, and deploy tasks |
| Image provenance | SLSA Level 2 – generate provenance with `slsa-github-generator` |

### Blue/Green on OpenShift with Argo Rollouts
The `blue-green-deploy-pipeline` can integrate with OpenShift GitOps (Argo CD):

```yaml
# Argo CD Application points to your GitOps repo
# Argo Rollouts manages the actual blue/green traffic split
# Tekton pipeline commits the new image tag → Argo CD syncs → Rollout proceeds
```

### Pipeline-as-Code (PaC) on IBM Cloud
1. Install the Pipelines-as-Code controller on your cluster.
2. Register your GitHub repo webhook pointing to the EventListener.
3. Place `.tekton/pipelinerun.yaml` (see `06-expert/pac/`) in your repo.
4. Every push/PR automatically triggers the correct PipelineRun.

```bash
# Register repo with tkn-pac
tkn-pac create repo \
  --git-provider=github \
  --url=https://github.com/your-org/your-app
```

## Deployment Strategies Summary

### Blue/Green
- Two identical deployments (`myapp-blue`, `myapp-green`)
- Service selector switches between them atomically
- Zero-downtime; instant rollback by re-pointing selector

### Canary
- Progressive traffic shift: 10% → 30% → 50% → 100%
- Controlled by Istio VirtualService weight or NGINX Ingress annotation
- Metrics-gated promotion (error rate, latency p99)

### Rolling (default Kubernetes)
- `maxSurge: 1`, `maxUnavailable: 0`
- Simplest; no extra infrastructure needed
- Slightly slower rollback than blue/green
