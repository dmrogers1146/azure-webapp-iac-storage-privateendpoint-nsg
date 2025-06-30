# Quick Interview Demo Script

## 🚀 Fast Demo Sequence (5-10 minutes)

```powershell
# 1. Create feature branch
git checkout -b feature/interview-demo

# 2. Make a quick change (add tag to terraform.tfvars)
echo 'interview_demo = "2025-06-30"' >> terraform.tfvars

# 3. Commit and push
git add terraform.tfvars
git commit -m "Add interview demo tag"
git push origin feature/interview-demo

# 4. Create PR
gh pr create --title "Interview Demo Change" --body "Demonstrating deployment workflow" --base main

# 5. Approve and merge
gh pr review --approve
gh pr merge --squash --delete-branch

# 6. Monitor deployment
git checkout main && git pull
gh run watch

# 7. Verify deployment
gh run list --limit 3
```

## 🎯 Key Interview Points to Mention

- **Branch Protection**: "Notice I can't push directly to main"
- **Automated Testing**: "GitHub Actions runs tests on every PR"
- **Infrastructure as Code**: "Changes are version controlled and auditable"
- **Security**: "Using service principal, no hardcoded credentials"
- **Rollback Capability**: "Can revert any deployment via Git history"

## 📊 Status Commands for Live Demo

```powershell
# Quick status check
git status && gh pr list && gh run list --limit 3

# Detailed workflow status
gh run view --log

# Azure resource verification
terraform show | findstr "tags"
```

## 🔧 Troubleshooting Commands (If Issues Arise)

```powershell
# Cancel running workflow
gh run cancel $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

# Check branch protection
gh api repos/OWNER/REPO/branches/main/protection

# Force sync main branch
git fetch origin && git reset --hard origin/main
```
