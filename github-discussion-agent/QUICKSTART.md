# Phone Sprint Agent - Quick Reference

**TL;DR**: Open your repo on phone → Discussions → Ask sprint question → Get answer in 30 seconds

---

## On Your Phone (Browser URL: github.com)

### 1. Navigate to Discussions
```
repo.com
  └─ Discussions tab (top menu)
```

### 2. Create New Discussion
```
✓ Click "New Discussion"
✓ Title: Any sprint question
✓ Category: General
✓ Body: (copy one of these)
```

### 3. What to Ask

Copy one of these and paste:

```
progress report
```
→ Where are we? (% done, FP, blockers)

```
gap report
```
→ What's blocking? (ranked blockers, mitigation)

```
sprint advance
```
→ Plan next sprint (pre-checks, stories, risks)

```
veritas expert
```
→ Evidence quality? (MTI score, gaps)

```
show velocity
```
→ Team speed trend (3 sprint history)

---

## Wait ~30 seconds

Agent posts detailed response 📤

**Result**: Markdown document with:
- Status update
- Recommendations
- Links to blockers
- Next actions
- Timeline

---

## Example Conversation

### You (on phone):
```
progress report
```

### Agent (30 seconds later):
```markdown
# 📊 Sprint Progress Report

Summary
├─ Completion: 68% (34/50 FP)
├─ MTI: 0.72 ✅
├─ Coverage: 87% ✅
└─ Blockers: 2

Top 5 Stories
1. ACA-08-001 ... 75% done
2. ACA-08-002 ... ready to start
...

Next Actions
→ Resolve 2 blockers
→ Complete ACA-08-001
→ Start ACA-08-002
```

### You read response and:
- ✅ Know exactly what to do next
- ✅ Can share with team
- ✅ Have full audit trail

---

## Available Commands

| Ask | Get | Time |
|-----|-----|------|
| `progress report` | Sprint status, top stories, blockers | 20s |
| `gap report` | Blockers, root cause, mitigation plan | 25s |
| `sprint report` | Velocity, burndown, quality metrics | 30s |
| `sprint advance` | Next sprint plan, DPDCA timeline, risks | 35s |
| `veritas expert` | MTI score, evidence audit, gaps | 40s |
| `show velocity` | Velocity trend, team speed analysis | 20s |
| `blockers` | Same as gap report | 25s |
| `mti` | Same as veritas expert | 40s |
| `plan sprint` | Sprint manifest, automation scripts | 45s |

---

## What Agent Sees

When you ask a question, agent automatically gathers:

```
Your Discussion Post
        ↓
Git history (commits, PRs, tags)
        ↓
37-data-model API (project metadata)
        ↓
48-eva-veritas (trust scores, evidence)
        ↓
51-ACA patterns (DPDCA, story structure)
        ↓
Generates response based on REAL DATA ✓
```

So answers are based on actual project state, not guesses! 📊

---

## Real Example

### Scenario: You're traveling, need sprint update

**Your iPhone** (2026-03-10 15:30):
```
Discussions
  New Discussion
  Body: progress report
  Post
```

**Agent responds** (2026-03-10 15:32):
```markdown
# 📊 Sprint Progress Report
...
- Completion: 92% (46/50 FP) ✅
- Blockers: 1 (API endpoint ETA Mar 12)
- Next: Start ACA-09-001, complete ACA-08-004
- Recommendation: On track for 100% by Friday
```

**You (on iPhone)**: Read response, understand status, share with team Slack

**No need to be at desk!** ✅

---

## No Setup Needed!

Agent already installed. Just create a Discussion.

Files automatically ready:
- ✅ `.github/workflows/discussion-bot-agent.yml`
- ✅ `github-discussion-agent/agent.py`
- ✅ `github-discussion-agent/README.md`

---

## Limitations

⚠️ **Can't create issues** — Copy response, create manually  
⚠️ **Read-only** — Safety feature  
⚠️ **Needs internet** — Data model + GitHub APIs must be online  
⚠️ **30sec timeout** — Very complex queries might not complete

---

## Troubleshooting

**Q: What if agent doesn't respond?**
A: Check workflow in Actions tab. On first run, you may need to approve it.

**Q: Can I ask custom questions?**
A: Yes! But stick to sprint management for best results.

**Q: Does it work internationally?**
A: Yes! Cloud-based, works anywhere with GitHub access.

**Q: Can team members use it?**
A: Yes! Anyone with repo access can create Discussions.

---

## Quick Commands Cheat Sheet

Save this on your phone for quick copy-paste:

```
progress report
```

```
gap report
```

```
sprint advance
```

```
veritas expert
```

```
show velocity
```

---

**You're now a sprint manager with just a phone and browser!** 🚀📱

For details, see: `github-discussion-agent/README.md`
