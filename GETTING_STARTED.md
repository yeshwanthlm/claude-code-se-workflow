# Getting Started — Confluent SE Workflow

**5 minutes to your first AI-assisted customer engagement.**

---

## Prerequisites

1. **Claude Code** installed (choose one):
   - CLI: `npm install -g @anthropics/claude-code` or download from https://claude.ai/code
   - Desktop app: Download for Mac/Windows
   - Web: https://claude.ai/code

2. **Confluent Cloud account** (for demos):
   - Sign up at https://confluent.cloud
   - Create Cloud API Key: Settings → API Keys → Add key → Cloud API Key

3. **Optional** (for demos):
   - AWS CLI configured
   - Terraform >= 1.6.0
   - Python 3.8+

---

## Step 1: Clone the Repository

```bash
git clone <your-repo-url>
cd confluent-se-workflow
```

---

## Step 2: Open in Claude Code

### Option A: Claude Code CLI
```bash
claude .
```

### Option B: Claude Code Desktop
- Open Claude Code Desktop app
- File → Open Folder → Select `confluent-se-workflow/`

### Option C: Claude Code Web
- Go to https://claude.ai/code
- Upload the `confluent-se-workflow/` folder

---

## Step 3: Start Your First Customer Engagement

Type in Claude Code:

```
new customer
```

Claude will ask you 7 questions:

```
1. What is the company name and what industry are they in?
2. When is the meeting, and how long do you have?
3. Who will be in the room? (names, roles, top concerns)
4. What constraints do you already know about?
5. Who is your internal partner on this account (AE, CSM, SDR)?
6. What do you NOT know yet that worries you?
7. What use case are you targeting?
```

Answer each question. Claude will create:
- `customers/<company-slug>/project-context.md` (auto-populated)
- Customer workspace directory structure

---

## Step 4: Conduct Your Discovery Meeting

Have your meeting with the customer. Take raw notes (don't worry about formatting).

---

## Step 5: Generate Discovery Outputs

Paste your raw meeting notes in Claude Code:

```
I have these details: [paste your raw notes]
```

Claude will generate:
- `meeting-summary.md` — what was said, decisions, surprises
- `requirements.md` — functional and non-functional requirements
- `gap-analysis.md` — critical gaps vs. nice-to-haves
- `follow-up.md` — action items for both teams

**Time saved:** 2-3 hours of manual doc writing

---

## Step 6: Generate Architecture Options

Say:

```
let us move to phase two
```

Claude will generate:
- **3 architecture options** (conservative, recommended, aggressive)
- **Reference architectures** (Confluent case studies)
- **Terraform templates** (Confluent Cloud + AWS)
- **Demo environment** (`setup.sh` for one-command provisioning)
- **Cost estimates** (monthly, annual, 3-year TCO)

**Time saved:** 5-6 hours of architecture design, Terraform coding, cost modeling

---

## Step 7: Present to Customer

Review the architecture options in:
- `customers/<company-slug>/01-design/architecture-options.md`
- `customers/<company-slug>/01-design/GATE-2A-SUMMARY.md`

Present to customer, collect feedback, select option.

---

## Step 8: Run the Demo (Optional)

If you selected an option with a demo environment:

```bash
cd customers/<company-slug>/01-design/demo

# Set Confluent Cloud credentials
export TF_VAR_confluent_cloud_api_key="<your-cloud-api-key>"
export TF_VAR_confluent_cloud_api_secret="<your-cloud-api-secret>"

# One-command setup (provisions Confluent Cloud + starts data generator)
./setup.sh

# After demo, clean up
./teardown.sh
```

**Time saved:** 4-5 hours of manual demo environment setup

---

## Total Time Saved Per Engagement: 12-15 hours

| Task | Manual Time | AI-Assisted Time | Savings |
|------|-------------|------------------|---------|
| Discovery doc writing | 2-3 hours | 5 minutes | 2-3 hours |
| Architecture design | 3-4 hours | 10 minutes | 3-4 hours |
| Terraform coding | 2-3 hours | 5 minutes | 2-3 hours |
| Cost modeling | 1-2 hours | 2 minutes | 1-2 hours |
| Demo environment setup | 4-5 hours | 10 minutes | 4-5 hours |
| **Total** | **12-17 hours** | **30-40 minutes** | **12-15 hours** |

---

## Common Questions

### Q: Do I need to code anything?
**A:** No. Claude generates all code (Terraform, Python, shell scripts). You review and customize.

### Q: What if my customer's use case isn't in the templates?
**A:** Claude adapts to any use case. Just describe it in the intake conversation. The templates are starting points, not limitations.

### Q: Can I customize the architecture options?
**A:** Yes. After Claude generates options, you can say:
- "Modify Option B to use Standard cluster instead of Dedicated"
- "Add Flink to Option A"
- "Remove PrivateLink from Option C to reduce cost"

### Q: What if I don't have a Confluent Cloud account?
**A:** You can still use the workflow for discovery and architecture design. The demo environment requires Confluent Cloud (free trial available: 300 usage credits).

### Q: How do I share this with my team?
**A:** Commit the workflow to your team's internal GitHub. Each SE can clone and use it independently. Customer engagements are auto-ignored by `.gitignore`.

### Q: What if Claude makes a mistake?
**A:** Review all outputs before presenting to customers. Claude generates 70-80% complete drafts — you add the 20-30% customer-specific context and polish.

---

## Next Steps

1. **Try the workflow** with an upcoming customer engagement
2. **Customize templates** for your territory (edit `customers/_template/project-context.md`)
3. **Add competitive intel** for your region (edit `reference/confluent-battlecards.md`)
4. **Share feedback** — open GitHub issues or contribute PRs

---

## Support

- **GitHub Issues:** Report bugs or request features
- **Internal Slack:** `#se-workflow` (if available)
- **Contributions:** PRs welcome!

---

**Ready? Type `new customer` in Claude Code and start your first engagement!**
