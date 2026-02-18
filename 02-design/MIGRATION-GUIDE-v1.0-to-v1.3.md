# Migration Guide: v1.0.0 to v1.3.0

**Project**: Apply-Project07-Artifacts.ps1  
**Migration Type**: Major upgrade with breaking changes  
**Estimated Time**: 30-60 minutes per project  
**Risk Level**: Medium (template changes require re-customization)

---

## Breaking Changes Summary

| Change | Impact | Mitigation |
|--------|--------|------------|
| **Template v2.0.0 → v2.1.0** | New metadata placeholders | Extract PART 2, re-run script, re-populate |
| **Project type detection changed** | May reclassify projects | Review new classification, adjust if needed |
| **Quality validation enforced** | Blocks <50% completion | Populate [CRITICAL] TODOs first |
| **TODO priorities added** | Changes TODO structure | Review priorities, adjust as needed |

---

## Pre-Migration Checklist

- [ ] Identify all projects deployed with v1.0.0
- [ ] Back up all `.github/copilot-instructions.md` files
- [ ] Document current project classifications
- [ ] Test migration on non-critical project first
- [ ] Allocate time for re-customization
- [ ] Review v1.3.0 CHANGELOG.md

---

## Migration Steps

### Step 1: Backup Current State

```powershell
# For each project with copilot instructions
$projects = @(
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\01-documentation-generator",
    "I:\EVA-JP-v1.2\docs\eva-foundation\projects\06-JP-Auto-Extraction"
    # Add all deployed projects
)

foreach ($project in $projects) {
    $instructionsFile = Join-Path $project ".github\copilot-instructions.md"
    if (Test-Path $instructionsFile) {
        $backupFile = "$instructionsFile.v1.0.0.backup"
        Copy-Item $instructionsFile $backupFile -Force
        Write-Host "[PASS] Backed up: $project" -ForegroundColor Green
    }
}
```

### Step 2: Extract PART 2 Content

For each project, manually extract PART 2:

```powershell
$instructionsFile = ".github\copilot-instructions.md"
$content = Get-Content $instructionsFile -Raw
$part2Start = $content.IndexOf("## PART 2:")

if ($part2Start -gt 0) {
    $part2Content = $content.Substring($part2Start)
    $part2File = ".github\copilot-instructions-PART2-extracted.md"
    Set-Content $part2File $part2Content
    Write-Host "[INFO] PART 2 extracted to: $part2File"
}
```

### Step 3: Run v1.3.0 Deployment

```powershell
# Navigate to Project 07
cd "I:\EVA-JP-v1.2\docs\eva-foundation\projects\07-foundation-layer\02-design\artifact-templates"

# DRY RUN FIRST to preview changes
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -DryRun

# Review output carefully, then apply
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject"
```

### Step 4: Review New Classification

Check if project type changed:

```powershell
# Old v1.0.0 classification may have been "General Purpose Project"
# New v1.3.0 uses enhanced detection

# Review the generated PART 2 header:
# ## PART 2: [PROJECT_NAME] PROJECT SPECIFIC
# **System Type**: [NEW_CLASSIFICATION]

# If incorrect, manually edit or use -Interactive mode to adjust
```

### Step 5: Merge PART 2 Content

Compare extracted PART 2 with new template:

```powershell
# Open both files side-by-side
code --diff .github\copilot-instructions-PART2-extracted.md .github\copilot-instructions.md

# Manually merge:
# 1. Keep custom content from extracted file
# 2. Add new v2.1.0 metadata placeholders
# 3. Preserve existing documentation
# 4. Update [TODO] items with new priorities
```

### Step 6: Prioritize TODOs

New v1.3.0 priority levels:

```markdown
# Old v1.0.0 format:
- [TODO] Add authentication details
- [TODO] Document API endpoints

# New v1.3.0 format with priorities:
- [CRITICAL] Add authentication details - System won't work without this
- [HIGH] Document API endpoints - Core functionality incomplete
- [MEDIUM] Add performance tips - Important but not blocking
- [LOW] Add troubleshooting FAQ - Nice to have
```

**Migration Strategy**:
1. Review all existing [TODO] items
2. Assign priority based on impact:
   - **[CRITICAL]**: Blocks core functionality
   - **[HIGH]**: Limits major features
   - **[MEDIUM]**: Reduces usability
   - **[LOW]**: Enhancement only
3. Populate [CRITICAL] items immediately
4. Schedule [HIGH] items for next sprint

### Step 7: Populate New Metadata

v2.1.0 template adds placeholders:

```markdown
**Required New Fields**:
- [ARCHITECTURE_PATTERN]: RAG, Microservices, Serverless, Monolith, Event-Driven
- [DEPLOYMENT_TARGET]: Azure Container Apps, AWS Lambda, Local Docker, etc.
- [TEST_FRAMEWORK]: Jest, pytest, Pester, Playwright, etc.
- [MONITORING_STACK]: Application Insights, CloudWatch, Prometheus, etc.

**How to Populate**:
1. Review project structure
2. Check deployment scripts (infra/, Makefile)
3. Inspect test files (tests/, __tests__/)
4. Review monitoring configuration
5. Fill in placeholders with actual values
```

### Step 8: Validate Quality

Run quality check:

```powershell
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -ValidateOnly

# Review quality score:
# - <50%: BLOCKED - Too many TODOs, populate critical items
# - 50-70%: WARNING - Needs work
# - 70-85%: GOOD - Acceptable quality
# - >85%: EXCELLENT - Comprehensive documentation
```

### Step 9: Test Copilot Integration

Validate Copilot uses new instructions:

1. Open project in VS Code
2. Ask Copilot: "Summarize this project's architecture"
3. Verify response includes:
   - New v1.3.0 metadata (architecture pattern, deployment target)
   - Project-specific PART 2 content
   - Correct project classification
4. Test code generation with project-specific patterns
5. Confirm encoding safety (ASCII-only) in generated scripts

---

## Rollback Procedure

If v1.3.0 causes issues:

```powershell
# Option 1: Restore from backup
Copy-Item .github\copilot-instructions.md.v1.0.0.backup .github\copilot-instructions.md -Force

# Option 2: Re-run v1.0.0 script
# Download v1.0.0 from git history:
git show v1.0.0:Apply-Project07-Artifacts.ps1 > Apply-Project07-Artifacts-v1.0.0.ps1
.\Apply-Project07-Artifacts-v1.0.0.ps1 -TargetPath "I:\YourProject"

# Option 3: Manual revert
# Keep PART 2 from backup, replace PART 1 with v1.0.0 template
```

---

## Common Migration Issues

### Issue 1: Project Reclassified Incorrectly

**Symptom**: Project changed from "RAG System" to "General Purpose API"

**Cause**: Enhanced detection uses keyword analysis, may misclassify

**Solution**:
```powershell
# Use -Interactive mode to override:
.\Apply-Project07-Artifacts.ps1 `
    -TargetPath "I:\YourProject" `
    -Interactive

# When prompted, select correct classification manually
```

### Issue 2: Too Many TODOs After Migration

**Symptom**: Quality validation fails with >50% TODO density

**Cause**: v2.1.0 adds new metadata placeholders, increasing TODO count

**Solution**:
1. Focus on [CRITICAL] TODOs only (usually 5-10 items)
2. Run validation with relaxed threshold:
   ```powershell
   # Edit script temporarily:
   # Line ~800: $todoThreshold = 0.50 → 0.70
   ```
3. Populate incrementally over 2-3 sprints

### Issue 3: Lost Custom PART 2 Content

**Symptom**: Custom documentation disappeared after migration

**Cause**: Failed to extract PART 2 before re-running script

**Solution**:
1. Restore from backup: `.github\copilot-instructions.md.v1.0.0.backup`
2. Follow Step 2 properly: Extract PART 2 first
3. Re-run migration with extracted content ready for merge

### Issue 4: Interactive Mode Hangs

**Symptom**: Script waits indefinitely for input in `-Interactive` mode

**Cause**: PowerShell execution policy or terminal compatibility

**Solution**:
```powershell
# Run without -Interactive for automated flow
.\Apply-Project07-Artifacts.ps1 -TargetPath "I:\YourProject"

# Or use -Force to skip prompts
.\Apply-Project07-Artifacts.ps1 -TargetPath "I:\YourProject" -Force
```

---

## Post-Migration Checklist

- [ ] All projects migrated successfully
- [ ] [CRITICAL] TODOs populated (target: 100%)
- [ ] [HIGH] TODOs scheduled for sprint
- [ ] Quality validation passing (>70%)
- [ ] Copilot integration tested
- [ ] Team notified of new TODO priority system
- [ ] Backups retained for 30 days
- [ ] Migration issues documented

---

## Migration Timeline (Example)

**Week 1: Preparation**
- Day 1: Identify all v1.0.0 deployments
- Day 2: Back up all projects
- Day 3: Test migration on 1-2 non-critical projects
- Day 4-5: Document project-specific issues

**Week 2: Core Projects**
- Migrate 3-5 high-priority projects
- Populate [CRITICAL] TODOs immediately
- Validate Copilot integration

**Week 3: Remaining Projects**
- Migrate all remaining projects
- Focus on quality score >70%
- Schedule [HIGH] TODO population

**Week 4: Cleanup**
- Remove temporary files (extracted PART 2)
- Archive backups
- Update team documentation
- Conduct retrospective

---

## Support & Resources

- **CHANGELOG.md**: Full list of v1.3.0 changes
- **README.md**: Updated Project 07 documentation
- **copilot-instructions-template.md v2.1.0**: New template reference
- **Test-Project07-Deployment.ps1**: Test suite for validation
- **Project 07 GitHub Issues**: Report migration problems

---

## Feedback

If you encounter migration issues not covered in this guide, please:
1. Document the issue with steps to reproduce
2. Note the project type and classification
3. Share error messages or unexpected behavior
4. Open issue in Project 07 repository

This guide will be updated based on community feedback.

---

**Last Updated**: January 29, 2026  
**Guide Version**: 1.0  
**Applies To**: Apply-Project07-Artifacts.ps1 v1.0.0 → v1.3.0
