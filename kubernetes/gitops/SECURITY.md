# Security Configuration

This GitOps setup implements security best practices for the monitoring stack.

## 🔐 Secure Credentials Management

### Overview
- **No hardcoded passwords** in Git repository
- **Kubernetes Secrets** for credential storage  
- **Auto-generated secure passwords** using OpenSSL
- **Proper secret permissions** (600) for local files

### Setup Process

1. **Generate Secure Credentials** (run this first):
   ```bash
   ./setup-monitoring-secrets.sh
   ```
   This creates:
   - Random 32-character base64 passwords
   - Kubernetes secrets in the monitoring namespace
   - Local credentials file with secure permissions

2. **Deploy Monitoring Stack**:
   ```bash
   ./deploy-monitoring.sh
   ```
   This automatically checks for secrets and prompts to create them if missing.

### Kubernetes Secrets Created

```yaml
# grafana-admin-credentials secret
apiVersion: v1
kind: Secret
metadata:
  name: grafana-admin-credentials
  namespace: monitoring
data:
  admin-user: <base64-encoded-username>
  admin-password: <base64-encoded-secure-password>

# monitoring-credentials secret (backup)
apiVersion: v1 
kind: Secret
metadata:
  name: monitoring-credentials
  namespace: monitoring
data:
  grafana-admin-password: <base64-encoded-secure-password>
  alertmanager-password: <base64-encoded-secure-password>
```

### Retrieving Passwords

```bash
# Get Grafana admin password
kubectl get secret grafana-admin-credentials -n monitoring \
  -o jsonpath='{.data.admin-password}' | base64 -d

# Get all monitoring credentials
kubectl get secret monitoring-credentials -n monitoring \
  -o jsonpath='{.data}' | jq -r 'to_entries[] | "\(.key): \(.value | @base64d)"'
```

## 🛡️ Security Features Implemented

### 1. **External Secrets Integration**
- Grafana configured to use `existingSecret`
- No passwords stored in Helm values
- Secrets managed outside of GitOps workflow

### 2. **Resource Optimization** 
- Homelab-appropriate resource limits
- Reduced storage requirements
- CPU/memory optimized for small environments

### 3. **Secure Configuration**
- Cookie security enabled in production
- Anonymous authentication disabled
- Proper RBAC configuration

### 4. **File Permissions**
- Generated credentials files have 600 permissions
- Scripts create secure temporary files
- Automatic cleanup recommendations

## 🎯 Production Recommendations

### For Production Environments:
1. **Use External Secret Management**:
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - External Secrets Operator

2. **Enable TLS/HTTPS**:
   - Configure ingress with TLS
   - Use cert-manager for certificate management
   - Enable secure cookies

3. **Network Security**:
   - Implement NetworkPolicies
   - Use service mesh (Istio/Linkerd)
   - Restrict NodePort access

4. **Monitoring Security**:
   - Enable audit logging
   - Monitor secret access
   - Regular credential rotation

## 🚨 Security Checklist

- [ ] Secrets created using `setup-monitoring-secrets.sh`
- [ ] No hardcoded passwords in Git repository  
- [ ] Local credentials file has 600 permissions
- [ ] Monitoring namespace exists with proper RBAC
- [ ] External secret integration configured
- [ ] Resource limits appropriate for environment
- [ ] Network policies implemented (production)
- [ ] TLS/HTTPS configured (production)
- [ ] Regular secret rotation scheduled (production)

## 🔧 Troubleshooting

### Secret Issues
```bash
# Check if secrets exist
kubectl get secrets -n monitoring | grep -E "(grafana|monitoring)"

# Recreate secrets if needed
kubectl delete secret grafana-admin-credentials -n monitoring
./setup-monitoring-secrets.sh
```

### Permission Issues
```bash
# Fix file permissions
chmod 600 monitoring-credentials.txt
chmod +x setup-monitoring-secrets.sh
```

### ArgoCD Sync Issues
```bash
# Force application sync
kubectl patch application monitoring -n argocd --type merge \
  --patch '{"operation":{"sync":{"revision":"HEAD"}}}'
```
