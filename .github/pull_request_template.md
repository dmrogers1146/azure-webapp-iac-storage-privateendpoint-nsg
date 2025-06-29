## Infrastructure Change Summary

### What changed?
<!-- Brief description of the infrastructure changes -->

### Why was this change needed?
<!-- Business justification for the change -->

### Resources Modified
- [ ] Virtual Network/Subnets
- [ ] App Service/App Service Plan
- [ ] SQL Server/Database
- [ ] Storage Account
- [ ] Application Gateway
- [ ] Key Vault
- [ ] NSG Rules
- [ ] Private Endpoints
- [ ] Other: _____

### Testing Performed
- [ ] `terraform validate` passed
- [ ] `terraform plan` reviewed
- [ ] Local testing completed
- [ ] Security review completed

### Deployment Plan
- [ ] This is a breaking change
- [ ] Requires maintenance window
- [ ] Can be deployed during business hours
- [ ] Rollback plan documented

### Post-Deployment Verification
- [ ] All resources created successfully  
- [ ] Application connectivity verified
- [ ] Private endpoint connectivity tested
- [ ] NSG rules validated
- [ ] Key Vault access confirmed

### Security Checklist
- [ ] No secrets in code
- [ ] Managed Identity used where possible
- [ ] Least privilege access implemented
- [ ] Private endpoints configured correctly
- [ ] Network security groups reviewed

### Screenshots/Evidence
<!-- Add any relevant screenshots or terraform plan output -->

### Related Issues
<!-- Link any related GitHub issues -->
Closes #

---
**Reviewer Notes:**
Please ensure:
1. Terraform plan output has been reviewed
2. Security implications are understood
3. Rollback procedure is clear
4. Documentation is updated if needed
