# Confluent SE Workflow — AI-Assisted Solutions Engineering

A production-ready **Confluent Solutions Engineer workflow** built with Claude Code. Three phases (Discovery, Design, Validation), AI-powered automation, human-in-the-loop gates, and comprehensive templates for customer engagements.

**For Confluent Solutions Engineers:** This open-source workflow accelerates your customer engagements from discovery to demo-ready architecture in days instead of weeks.

---

## What This Is

Manual SE workflows look like this:

```
Discovery meeting prep  →  Architecture design  →  Demo prep + Validation
(5 prompt templates)       (6 prompt templates)     (5 prompt templates)
```

This repo replaces each manual prompt with a **specialized Claude Code subagent** that runs autonomously, writes files to disk, and hands off to the next agent — with a human checkpoint at every phase boundary.

```
Phase 1: Discovery    →  Gate 1  →  Phase 2: Design + Demo    →  Gate 2  →  Phase 3: Validation
discovery-agent              design-agent                            security-validator
                             diagram-agent                           scalability-validator
                             iac-agent (Confluent + AWS)             cost-validator
                             documentation-agent                     competitive-validator
                             demo-agent
```

The SE never skips a gate. AI does the 70–80% draft. The human adds the 20–30% that matters.

---

## The Agents

| Agent | Phase | What It Does |
|-------|-------|--------------|
| `discovery-agent` | 1 | Company research, stakeholder mapping, Confluent-specific discovery questions, post-meeting processing |
| `design-agent` | 2 | Three architecture options with Confluent Cloud as the backbone |
| `diagram-agent` | 2 | Architecture diagram using Python `diagrams` library |
| `iac-agent` | 2 | Confluent Cloud Terraform + AWS Terraform for surrounding infrastructure |
| `documentation-agent` | 2 | ADRs, reference architectures, architecture summary |
| `demo-agent` | 2 | Use-case-specific demo script, sample data generators, producer/consumer code |
| `security-validator` | 3 | Encryption, RBAC, private networking, compliance gap analysis |
| `scalability-validator` | 3 | Throughput, partition sizing, consumer lag, Flink parallelism |
| `cost-validator` | 3 | Confluent Cloud CKU/CU pricing, TCO vs. self-managed Kafka |
| `competitive-validator` | 3 | Positioning vs. MSK, Redpanda, Pulsar, self-managed Kafka |

---

## Customer Workspace

Each engagement lives in `customers/<company-slug>/`:

```
customers/
  aurorastream/                    ← example run (full output)
    project-context.md             ← living doc, updated at every gate
    00-discovery/
      company-brief.md
      stakeholder-map.md
      questions.md
      meeting-summary.md
      requirements.md
      gap-analysis.md
      follow-up.md
    01-design/
      architecture-options.md
      reference-architectures.md
      aurorastream-architecture.png
      ADR-001-migration-strategy.md
      ADR-002-confluent-cluster-strategy.md
      ADR-003-schema-registry.md
      ADR-004-stream-processing.md
      ADR-005-connectors-cdc.md
      ADR-006-data-residency-controls.md
      ADR-007-iac-tooling.md
      architecture-summary.md
      confluent-terraform/         ← Confluent Cloud resources
      aws-terraform/               ← AWS surrounding infrastructure
      demo/                        ← Demo scripts and sample code
    02-validation/
      security-report.md
      scalability-report.md
      cost-estimate.md
      competitive-positioning.md
      demo-readiness.md
      validation-summary.md
  _template/                       ← blank workspace for new engagements
```

---

## Requirements

- [Claude Code](https://claude.ai/code) (CLI or desktop app)
- Claude Max or API access with subagent support
- Confluent Cloud account (for demo environment)
- AWS CLI configured (for AWS infrastructure)
- Python `diagrams` library (`pip install diagrams`) for architecture diagrams
- Terraform >= 1.6.0

### Terraform Providers

| Provider | Purpose |
|----------|---------|
| `confluentinc/confluent` | All Confluent Cloud resources (clusters, topics, connectors, Flink, Schema Registry) |
| `hashicorp/aws` | AWS surrounding infrastructure (VPC, ECS, RDS, S3, Lambda) |

Install Confluent provider: automatically downloaded by `terraform init` from the Terraform Registry.

---

## Quickstart (5 Minutes to First Customer Engagement)

### 1. Clone and Open in Claude Code

```bash
git clone <this-repo-url>
cd confluent-se-workflow
```

Open the directory in Claude Code (CLI, Desktop, or claude.ai/code)

### 2. Start a New Customer Engagement

In Claude Code, type:

```
new customer
```

The principal agent will run a 7-question intake conversation:
- Company name and industry
- Meeting date/duration
- Stakeholders (names, roles, concerns)
- Known constraints (budget, timeline, compliance)
- Internal partner intelligence (what the AE knows)
- What you don't know yet
- Target use case (CDC, real-time analytics, event-driven microservices, etc.)

### 3. Discovery Phase (After Your Meeting)

Paste your raw meeting notes. Claude will generate:
- `meeting-summary.md` — what was said, decisions, surprises
- `requirements.md` — functional and non-functional requirements
- `gap-analysis.md` — critical gaps vs. nice-to-haves
- `follow-up.md` — action items for both teams

### 4. Design Phase

Say: **"let us move to phase two"**

Claude will generate:
- **3 architecture options** (conservative, recommended, aggressive)
- **Reference architectures** (Confluent case studies, best practices)
- **Terraform templates** (Confluent Cloud + AWS infrastructure)
- **Demo environment** (`setup.sh` for one-command provisioning)
- **Cost estimates** (monthly, annual, 3-year TCO)

### 5. Validation Phase (Optional)

For production deployments, run validation:
- Cost validation (3-year TCO vs. alternatives)
- Security validation (RBAC, encryption, compliance)
- Scalability validation (throughput sizing, partition count)
- Competitive positioning (vs. MSK, Redpanda, self-managed)

---

## What You Get

This workflow provides:

✅ **Structured customer intake** — 7-question conversation that populates `project-context.md`  
✅ **Automated discovery outputs** — company brief, stakeholder map, Confluent-specific questions, meeting summary, requirements, gap analysis  
✅ **Three architecture options** — conservative, recommended, aggressive (Confluent Cloud as backbone)  
✅ **Production-ready Terraform** — Confluent Cloud provider (connectors, Flink, Schema Registry) + AWS provider  
✅ **One-command demo environments** — `./setup.sh` provisions Confluent Cloud + starts data generator  
✅ **Competitive battlecards** — Confluent vs. MSK, Redpanda, self-managed Kafka, Pulsar  
✅ **Cost validation** — 3-year TCO comparison with detailed breakdowns  
✅ **7 common use case patterns** — CDC, real-time analytics, event-driven microservices, streaming ETL, IoT, AI/ML, multi-region

---

## Confluent Cloud Architecture Principles

Every architecture in this workflow follows these principles:

1. **Confluent Cloud is the streaming backbone** — Kafka, Schema Registry, Flink, connectors
2. **AWS provides surrounding infrastructure** — compute, databases, object storage, networking
3. **Stream Governance from day one** — Schema Registry, data lineage, quality rules
4. **Security by default** — RBAC, private networking, encryption at rest and in transit
5. **Demo-ready** — every engagement includes a Terraform-provisioned demo environment

---

## Decision Analysis Framework

Every architectural recommendation is evaluated on six axes:

1. **Cost** — Confluent Cloud CKU/CU pricing vs. self-managed Kafka TCO
2. **Timeline** — time to first message, time to production
3. **Team Capability** — Kafka experience, stream processing skills, IaC maturity
4. **Leadership Alignment** — risk tolerance, build vs. buy philosophy, cloud strategy
5. **Technical Fit** — throughput, latency, retention, connector ecosystem, compliance
6. **Competitive Positioning** — vs. MSK, Redpanda, Pulsar, self-managed Kafka on K8s

---

## Philosophy

> *AI gives speed and breadth. The SE provides depth, customer context, and the demo that wins the deal.*

This workflow produces **70–80% complete drafts** — not perfect documents. The SE adds the customer relationship layer: the off-hand comment in the meeting, the political context the AE shared, the gut feel about what the CISO will actually accept.

The gates are not optional. They are the workflow.

The demo is as important as the architecture. A great demo wins deals.

---

## Repository Structure

```
confluent-se-workflow/
├── CLAUDE.md                          # Principal agent instructions (DO NOT MODIFY)
├── README.md                          # This file
├── reference/
│   └── confluent-battlecards.md      # Competitive positioning (MSK, Redpanda, etc.)
└── customers/
    └── _template/                     # Blank customer workspace template
        ├── project-context.md         # Living document for engagement
        ├── 00-discovery/              # Discovery phase outputs
        ├── 01-design/                 # Architecture, Terraform, demo
        │   ├── confluent-terraform/   # Confluent Cloud resources
        │   │   ├── connectors.tf      # 7 connector examples
        │   │   ├── flink.tf           # 4 Flink SQL examples
        │   │   └── README.md
        │   └── demo/                  # One-command demo environment
        │       ├── setup.sh           # Provision Confluent Cloud + start data generator
        │       ├── teardown.sh        # Clean up demo resources
        │       └── data-generator/    # Python producer with Schema Registry
        └── 02-validation/             # Validation phase outputs
```

## For Confluent SEs: Getting Started

### Prerequisites
- [Claude Code](https://claude.ai/code) (CLI, Desktop, or Web)
- Confluent Cloud account with Cloud API Key (for demos)
- AWS CLI configured (for AWS infrastructure in demos)
- Terraform >= 1.6.0 (for IaC generation)

### Your First Customer Engagement

1. **Start engagement:** Type `new customer` in Claude Code
2. **Answer 7 intake questions** → `project-context.md` auto-populated
3. **Conduct discovery meeting** with customer
4. **Paste raw notes** → Claude generates structured discovery docs
5. **Design phase:** Say `let us move to phase two` → 3 architecture options + Terraform + demo
6. **Present to customer** → review, select option, approve

**Time saved:** 8-12 hours of manual doc writing, Terraform coding, and research per engagement.

## Customization for Your Territory

### Add Your Territory-Specific Templates

Edit `customers/_template/project-context.md` to add:
- Default cloud provider (AWS, GCP, Azure)
- Default region (us-east-1, eu-west-1, ap-southeast-1)
- Common compliance requirements (GDPR, PCI DSS, HIPAA)
- Your preferred architecture patterns

### Add Your Competitive Intelligence

Edit `reference/confluent-battlecards.md` to add:
- Territory-specific competitor pricing
- Customer objections you hear frequently
- Successful counter-arguments from past wins

### Add Custom Use Case Patterns

Edit `CLAUDE.md` → "Common Use Case Patterns" section to add:
- Industry-specific patterns (fintech, healthcare, retail, etc.)
- Regional patterns (APAC multi-region, EU data residency)
- Your unique customer success stories

## Advanced: Custom Agents (Optional)

The workflow is designed to work out-of-the-box, but you can add custom specialized agents for:
- Industry-specific discovery (e.g., healthcare compliance agent)
- Custom validation (e.g., PCI DSS validator)
- Regional requirements (e.g., China data residency agent)

See `CLAUDE.md` for agent invocation patterns.

## Support

**For Confluent SEs:**
- GitHub Issues: Report bugs or request features
- Contributions: PRs welcome!

## Contributing

Contributions from Confluent SEs are welcome! Please:
1. Fork the repo
2. Create a feature branch (`git checkout -b feature/my-enhancement`)
3. Add your enhancement (new use case pattern, competitive intel, Terraform module, etc.)
4. Submit a PR with clear description

**What to contribute:**
- ✅ New use case patterns (CLAUDE.md)
- ✅ Competitive intelligence updates (reference/confluent-battlecards.md)
- ✅ Terraform connector examples (customers/_template/01-design/confluent-terraform/)
- ✅ Demo templates for specific industries (customers/_template/01-design/demo/)
- ❌ Customer-specific data (never commit real customer engagements)

## License

Apache 2.0 — use it, adapt it, build on it.
