go for sprint 8 planning# GitHub Features Inventory for EVA Factory

Version: 1.0.0
Date: 2026-03-01
Purpose: Map GitHub subscription features to EVA Factory automation opportunities

---

## Subscription Details

**GitHub Pro** ($48/year):
- Unlimited public/private repositories
- 3,000 Actions minutes/month (20 min used / 3,000 included as of March 2026)
- 2GB Packages storage
- 180 core-hours Codespaces compute/month
- 20GB Codespaces storage
- Code owners, required reviewers, GitHub Pages
- Advanced tools access

**Copilot Pro+** ($390/year):
- GitHub Copilot in IDE (VS Code, Visual Studio, JetBrains, etc.)
- GitHub Copilot in GitHub (web UI, mobile)
- GitHub Models API access (gpt-4o, gpt-4o-mini available -- verified in 51-ACA sprint-agent.yml)
- Unlimited messages and interactions
- Priority access to latest models

**Current Usage** (March 1-31, 2026):
- Actions minutes: 20 / 3,000 (0.67% used)
- Actions storage: 0 GB / 2 GB
- **Cost**: $1.98 metered + $1.97 included discounts = ~$2/month actual

---

## Feature 1: GitHub Actions (Already Active)

**What It Is**: CI/CD automation, workflow orchestration

**Current EVA Usage**:
- **51-ACA**: sprint-agent.yml (trigger on issue label "sprint-task", execute full sprint)
- **51-ACA**: sonnet-review.yml (code review automation)
- **51-ACA**: dpdca-agent.yml, collector-schedule.yml, deploy-phase1.yml
- **Usage**: 20 minutes / 3,000 available (99.3% headroom)

**Strategic Value**:
- One-line governance: gh issue create -> automated execution
- Cloud agent execution: no local compute required
- PR automation: agent commits + opens PR
- Evidence collection: upload artifacts (sprint-state.json, evidence/)

**Expansion Opportunities**:
1. **Deploy to 12 active projects**: Template sprint-agent.yml via Phase 3
2. **Continuous sprint execution**: Sprint 1 -> Sprint 30 automated (future vision from 51-ACA)
3. **ADO sync workflows**: Auto-create ADO work items from GitHub issues (38-ado-poc integration)
4. **Veritas gating**: Run MTI audit in workflow, block PR merge if <threshold
5. **Dashboard updates**: POST to 40-eva-control-plane after sprint completion

**Cost Monitoring**:
- Current burn: ~20 min/month (51-ACA only)
- 12 projects x 4 sprints/month x 5 min/sprint = 240 min/month (still 8% of quota)
- **Risk**: LOW -- plenty of headroom

---

## Feature 2: GitHub Projects (Not Yet Used)

**What It Is**: Project management boards, roadmaps, issue tracking

**Available Tiers**:
- **Projects v2** (free for public repos + Pro plan): Kanban boards, custom fields, automation
- **Organization Projects**: Cross-repo boards, portfolio views

**EVA Factory Use Cases**:
1. **Portfolio Dashboard** (replaces 39-ado-dashboard for GitHub-native projects):
   - Board: C:\eva-foundry\ workspace view
   - Columns: Not Started / In Progress / Done / Blocked
   - Custom fields: MTI Score, Test Count, Phase, Maturity
   - Filter: Active projects (12 projects from registry)

2. **Sprint Planning Board** (per-project):
   - One project board per numbered folder (e.g., "51-ACA Sprint Backlog")
   - Stories from PLAN.md -> GitHub issues
   - Custom fields: Story ID (ACA-NN-NNN), Size (XS/S/M/L), Sprint Number, MTI Impact
   - Automation: Move to "In Progress" when PR opened, "Done" when merged

3. **Cross-Project Dependencies**:
   - Track governance toolchain (36, 37, 38, 39, 40, 48) blockers
   - Link issues across repos (e.g., 33-brain-v2 API needed by 31-faces)
   - Visualize dependency graph

**How to Enable**:
- Navigate: https://github.com/orgs/eva-foundry/projects
- Create: "EVA Foundation Portfolio" (organization-level project)
- Link: Issues from all eva-foundry/* repos
- Automate: GitHub Actions workflows can update project fields via GraphQL API

**Integration with Data Model**:
- GitHub Projects <- sync -> 37-data-model WBS layer
- Bidirectional: Issues created from PLAN.md (seed), status updated to data model (act)
- Evidence: Project board state exported as evidence pack to 40-control-plane

**Cost**: FREE (included in GitHub Pro)

---

## Feature 3: GitHub Codespaces (Available, Not Used)

**What It Is**: Cloud-based VS Code environments, pre-configured dev containers

**Current Quota**:
- 180 core-hours/month (2-core machine = 90 hours, 4-core = 45 hours)
- 20GB storage
- Supports devcontainer.json (pre-install dependencies, extensions)

**EVA Factory Use Cases**:
1. **Agent Dev Environment** (consistent setup for all contributors):
   - .devcontainer/devcontainer.json in each project
   - Pre-installed: Python 3.12, Node.js 20, Azure CLI, GitHub CLI
   - Pre-configured: venv at C:\eva-foundry\.venv, data model API base URL
   - Extensions: Python, Copilot, Copilot Chat, Azure Tools

2. **Sprint Agent Execution Environment** (alternative to GitHub Actions runners):
   - Pros: Faster startup (persistent container), more compute (up to 32-core), interactive debugging
   - Cons: Manual start/stop, not event-driven (unless triggered via API)
   - Use Case: Complex M/L story execution where agent needs >15 min runtime

3. **Veritas Audit Environment** (portable, reproducible audits):
   - Codespace with 48-eva-veritas + 37-data-model pre-configured
   - Run audits on any EVA project without local setup
   - Share codespace URL for collaborative audit reviews

**How to Enable**:
- Add .devcontainer/devcontainer.json to each project root
- Template available: https://containers.dev/templates
- Start codespace: https://github.com/codespaces/new?machine=basicLinux32gb&repo=eva-foundry/51-ACA

**Cost**:
- 2-core machine: FREE up to 90 hours/month
- 4-core machine: FREE up to 45 hours/month
- Storage: FREE up to 20GB (persistent across sessions)

**Risk**: LOW -- plenty of quota, can control machine size

---

## Feature 4: GitHub Packages (Available, Not Used)

**What It Is**: Package registry (npm, NuGet, Maven, RubyGems, Docker)

**Current Quota**:
- 2GB storage (GitHub Pro)
- Unlimited public packages
- 10GB data transfer/month (public packages)

**EVA Factory Use Cases**:
1. **Docker Images for Agents**:
   - Build: eva-foundry/sprint-agent:latest (Python 3.12 + dependencies)
   - Build: eva-foundry/veritas-audit:latest (48-eva-veritas CLI)
   - Use: Pull from ghcr.io/eva-foundry/sprint-agent in GitHub Actions workflows
   - Benefit: Faster workflow startup (no pip install every run)

2. **Python Package Distribution**:
   - Package: eva-foundry-core (shared utilities for all EVA projects)
   - Package: eva-veritas (48-eva-veritas as installable CLI)
   - Install: pip install eva-foundry-core --index-url https://ghcr.io/eva-foundry
   - Benefit: Centralize common code (auth, logging, data model client)

3. **Reusable GitHub Actions**:
   - Action: eva-foundry/setup-eva-environment (install dependencies, configure paths)
   - Action: eva-foundry/run-veritas-audit (audit + gate PR merge)
   - Use: steps: - uses: eva-foundry/setup-eva-environment@v1

**How to Enable**:
- Configure: Settings -> Packages (already enabled for organization)
- Publish: docker push ghcr.io/eva-foundry/sprint-agent:latest
- Authenticate: echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin

**Cost**: FREE (2GB included, public packages unlimited transfer)

---

## Feature 5: GitHub Models API (Already Active)

**What It Is**: Access to Azure OpenAI models via GitHub Copilot Pro+ subscription

**Available Models** (verified in 51-ACA sprint-agent.yml):
- gpt-4o (large/complex tasks)
- gpt-4o-mini (small/simple tasks)
- **NOT available**: claude-sonnet-4.6, claude-* (not in GitHub Models catalog)

**Current EVA Usage**:
- **51-ACA sprint-agent.py**: Calls gpt-4o for M/L stories, gpt-4o-mini for XS/S stories
- **API endpoint**: https://models.inference.ai.azure.com
- **Authentication**: Bearer $GITHUB_TOKEN (no separate API key required)

**Strategic Value**:
- **FREE** inference (included in Copilot Pro+ $390/year)
- No separate Azure OpenAI subscription required
- Rate limits unknown (assumed generous for Pro+ tier)

**Expansion Opportunities**:
1. **Deploy to all 12 active projects**: Template sprint-agent.yml in Phase 3
2. **Sonnet-review replacement**: Use gpt-4o for code review (current sonnet-review.yml uses Anthropic API)
3. **Multi-agent orchestration**: gpt-4o-mini for routing, gpt-4o for execution
4. **Evaluation**: Use gpt-4o as judge for MTI quality assessment (36-red-teaming integration)

**Risk**: Monitor rate limits (unknown, but no issues observed in 51-ACA with ~20 sprint executions)

---

## Feature 6: GitHub Pages (Available, Not Used)

**What It Is**: Static site hosting (free for public repos)

**Current Quota**: Unlimited (free for public repos with GitHub Pro)

**EVA Factory Use Cases**:
1. **EVA Foundation Documentation Portal**:
   - URL: https://eva-foundry.github.io/eva-foundation/
   - Content: Architecture docs, DPDCA workflow guide, agent skill catalog
   - Build: MkDocs (similar to 10-mkdocs-poc)
   - Benefit: Public-facing EVA Factory documentation

2. **Project Status Dashboards** (static HTML, updated by Actions):
   - URL: https://eva-foundry.github.io/eva-foundation/status/
   - Content: MTI scores, test counts, sprint progress (12 projects)
   - Update: GitHub Actions workflow queries 37-data-model, generates HTML, commits to gh-pages branch
   - Benefit: Public-facing portfolio metrics (no 39-ado-dashboard React app required)

3. **Veritas Reports Archive**:
   - URL: https://eva-foundry.github.io/eva-foundation/audits/
   - Content: Historical MTI reports, gap analysis, coverage trends
   - Benefit: Auditable history (compliance, retrospectives)

**How to Enable**:
- Settings -> Pages -> Source: Deploy from a branch (gh-pages)
- Build: GitHub Actions workflow generates site, pushes to gh-pages branch

**Cost**: FREE

---

## Feature 7: GitHub Security Features (Available)

**What It Is**: Dependabot, secret scanning, code scanning (CodeQL)

**Current Quota** (GitHub Pro):
- Dependabot alerts: Enabled (automatic PRs for dependency updates)
- Secret scanning: Enabled (detects leaked secrets in commits)
- CodeQL: Enabled (Advanced Security not required for public repos)

**EVA Factory Use Cases**:
1. **Dependabot for 12 Projects**:
   - Enable: .github/dependabot.yml in each project
   - Benefit: Auto-update pip requirements.txt, npm package.json
   - Integration: Dependabot PR -> pytest workflow -> auto-merge if tests pass

2. **Secret Scanning**:
   - Detects: Azure connection strings, API keys, PATs leaked in commits
   - Alert: Block PR merge if secret detected
   - Benefit: Prevent credential leaks

3. **CodeQL Analysis**:
   - Scan: Python, TypeScript, JavaScript for security vulnerabilities
   - Schedule: Weekly scan via GitHub Actions workflow
   - Benefit: Proactive security auditing (complements 36-red-teaming)

**How to Enable**:
- Settings -> Security -> Code security and analysis -> Enable all

**Cost**: FREE for public repos

---

## Strategic Recommendations for EVA Factory

### High Priority (Implement in Foundation Completion Plan)

1. **Expand GitHub Actions to 12 Projects** (Phase 3):
   - Deploy sprint-agent.yml template to all active projects
   - Expected cost: 240 min/month (8% of quota)
   - Benefit: One-line governance for all projects

2. **Create EVA Foundation Portfolio Project** (Phase 7):
   - Organization-level GitHub Project board
   - Link: All eva-foundry/* issues
   - Custom fields: MTI Score, Sprint Number, Story ID, Size
   - Benefit: Portfolio visibility (replaces/complements 39-ado-dashboard)

3. **Package Sprint Agent as Docker Image** (Phase 3):
   - Build: eva-foundry/sprint-agent:latest (Python + dependencies)
   - Publish: ghcr.io/eva-foundry/sprint-agent:latest
   - Benefit: Faster workflow startup (5 min -> 30 sec)

### Medium Priority (Post-Foundation)

4. **Enable GitHub Pages for Documentation**:
   - Build: MkDocs site from 09-eva-repo-documentation
   - Deploy: https://eva-foundry.github.io/eva-foundation/
   - Benefit: Public-facing docs (no separate hosting cost)

5. **Configure Dependabot for All Projects**:
   - Add: .github/dependabot.yml template in 07-foundation-layer
   - Deploy: Reseed-Projects.ps1 -Scope active
   - Benefit: Automated dependency updates

6. **Explore Codespaces for Complex Sprints**:
   - Add: .devcontainer/devcontainer.json to 51-ACA (prototype)
   - Test: Run Sprint 8 in Codespace instead of GitHub Actions runner
   - Benefit: Interactive debugging, longer runtime (if needed)

### Low Priority (Future Research)

7. **GitHub Models Rate Limit Analysis**:
   - Monitor: gpt-4o / gpt-4o-mini usage in 51-ACA over 30 days
   - Document: API response headers (X-RateLimit-Remaining, etc.)
   - Benefit: Understand capacity before scaling to 12 projects

8. **GitHub Copilot Workspace** (when available):
   - New feature: AI-powered workspace planning (announced 2024, rollout ongoing)
   - Benefit: Could replace/enhance sprint-agent.py with native GitHub feature

---

## Cost Projection (12 Projects Active)

| Feature | Current | 12 Projects | % Quota | Risk |
|---|---|---|---|---|
| Actions minutes | 20/3000 | 240/3000 | 8% | LOW |
| Actions storage | 0/2GB | 0.5/2GB | 25% | LOW |
| Packages storage | 0/2GB | 0.3/2GB | 15% | LOW |
| Codespaces compute | 0/180hr | 0/180hr | 0% | LOW |
| Codespaces storage | 0/20GB | 0/20GB | 0% | LOW |
| **Total monthly cost** | $2 | $5-8 est | - | **LOW** |

**Conclusion**: GitHub subscription has **massive headroom**. Current usage is <1% of compute quota. Can safely scale to all 12 active projects + portfolio automation without hitting limits.

---

## Next Actions

1. **Commit this inventory** to 07-foundation-layer/docs/
2. **Update foundation-completion-plan.md Phase 3** to include GitHub Packages (Docker image)
3. **Create GitHub Project board** for EVA Foundation Portfolio (URL: https://github.com/orgs/eva-foundry/projects)
4. **Add .devcontainer/devcontainer.json template** to 07-foundation-layer/02-design/artifact-templates/
5. **Document GitHub Actions cost monitoring** in workspace copilot-instructions.md (section: "GitHub Actions Usage Policy")

---

## References

- GitHub Pro features: https://docs.github.com/en/get-started/learning-about-github/githubs-plans
- GitHub Actions pricing: https://docs.github.com/en/billing/managing-billing-for-github-actions/about-billing-for-github-actions
- GitHub Models: https://github.com/marketplace/models
- GitHub Projects: https://docs.github.com/en/issues/planning-and-tracking-with-projects
- GitHub Codespaces: https://docs.github.com/en/codespaces
- GitHub Packages: https://docs.github.com/en/packages

