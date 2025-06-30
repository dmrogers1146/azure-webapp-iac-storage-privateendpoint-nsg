# GitHub Deployment Interview Demo Commands

## Overview
This demonstrates a complete GitOps workflow with branch protection, pull requests, and Azure deployment using GitHub Actions.

## Prerequisites Check
```powershell
# Verify current status
git status
git branch -a
gh auth status
terraform --version
```

## Part 1: Create Feature Branch and Make Changes

```powershell
# 1. Create and switch to feature branch
git checkout -b feature/demo-deployment

# 2. Make a visible infrastructure change (example: add a tag)
# Edit terraform.tfvars to add a new tag
code terraform.tfvars
```

**Add this line to terraform.tfvars:**
```hcl
# Add to the tags section
demo_deployment_date = "2025-06-30"
```

```powershell
# 3. Update variables.tf to support the new tag
code variables.tf
```

**Add this to variables.tf:**
```hcl
variable "demo_deployment_date" {
  description = "Date of demo deployment"
  type        = string
  default     = ""
}
```

```powershell
# 4. Update main.tf to use the new tag
code main.tf
```

**Update the tags in main.tf:**
```hcl
tags = merge(var.tags, {
  demo_deployment_date = var.demo_deployment_date
})
```

## Part 2: Commit and Push Changes

```powershell
# 5. Stage and commit changes
git add .
git status
git commit -m "Add demo deployment date tag for interview demonstration"

# 6. Push feature branch to GitHub
git push origin feature/demo-deployment
```

## Part 3: Create Pull Request (GitHub CLI)

```powershell
# 7. Create pull request
gh pr create --title "Demo: Add deployment date tag" --body "Demonstration of infrastructure change deployment process for interview" --base main --head feature/demo-deployment

# 8. List pull requests to verify
gh pr list
```

## Part 4: Review and Merge (Simulating Approval Process)

```powershell
# 9. View the pull request details
gh pr view

# 10. Check GitHub Actions status for the PR
gh pr checks

# 11. Approve and merge the pull request (in interview, explain this would normally be done by a reviewer)
gh pr review --approve --body "Approved for demo purposes"
gh pr merge --squash --delete-branch
```

## Part 5: Switch Back to Main and Verify Deployment

```powershell
# 12. Switch back to main branch
git checkout main
git pull origin main

# 13. Verify the merge
git log --oneline -5

# 14. Monitor GitHub Actions workflow
gh run list --limit 5
gh run watch
```

## Part 6: Check Deployment Status

```powershell
# 15. Check specific workflow run
gh run list --workflow=deploy.yml --limit 3

# 16. View workflow details (replace RUN_ID with actual ID from above)
gh run view [RUN_ID]

# 17. View workflow logs
gh run view [RUN_ID] --log
```

## Part 7: Verify Infrastructure Changes

```powershell
# 18. Check Terraform state locally (optional)
terraform plan

# 19. Verify resources in Azure Portal or CLI
az group show --name rg-webapp-payg-demo --query tags

# 20. Check application status
curl -I https://app-webapp-payg-demo.azurewebsites.net
```

## Part 8: Alternative - Manual Workflow Dispatch

```powershell
# 21. Trigger deployment manually (if configured)
gh workflow run deploy.yml --ref main

# 22. Monitor the manually triggered run
gh run watch
```

## Part 9: Branch Cleanup and Status Check

```powershell
# 23. Clean up local branches
git branch -d feature/demo-deployment

# 24. Verify branch protection is working
git checkout -b test-protection
echo "# Test" > test-file.txt
git add test-file.txt
git commit -m "Test direct push to main"
git checkout main

# This should fail due to branch protection:
git merge test-protection
# Expected: Error about branch protection

# 25. Clean up test branch
git branch -D test-protection
```

## Interview Talking Points

### Technical Demonstration:
- **GitOps Workflow**: Feature branch → PR → Review → Merge → Deploy
- **Branch Protection**: Prevents direct pushes to main
- **Automated Testing**: GitHub Actions runs on PR creation
- **Infrastructure as Code**: Terraform changes deployed automatically
- **Security**: Service principal authentication for Azure
- **Monitoring**: GitHub Actions provide deployment visibility

### Problem-Solving Example:
- **Scenario**: "What if deployment fails?"
- **Response**: Show `gh run view [RUN_ID] --log` to debug
- **Follow-up**: Demonstrate rollback with `terraform destroy` or previous commit

### Best Practices Demonstrated:
- Feature branch workflow
- Pull request reviews
- Automated testing and deployment
- Infrastructure versioning
- Secure credential management

## Quick Reference Commands

```powershell
# Status checks
git status
gh pr list
gh run list --limit 5
terraform plan

# Emergency commands
gh run cancel [RUN_ID]
terraform destroy -auto-approve
git reset --hard HEAD~1
```

## Notes for Interview
- Explain each step as you execute it
- Mention security considerations (service principal, secrets)
- Discuss scalability (multiple environments, approval workflows)
- Show troubleshooting skills when issues arise
- Emphasize the value of GitOps and Infrastructure as Code
