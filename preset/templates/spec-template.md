<prd-method>
# Problem Requirements Document (PRD) Template

This template teaches you (AI or human) how to capture the **problem space** before jumping to solutions. It produces a structured PRD that feeds into `docs/plan-template.md` for solution design.

## Core Principles

1. **Problem before solution**: Describe WHAT hurts and WHO it hurts — never HOW to fix it
2. **Specificity over generality**: Concrete pain points, named personas, measurable outcomes
3. **Challenge vagueness**: Push back on "all users", "better experience", "and more" — demand specifics
4. **Jobs to Be Done**: Frame everything as user motivations, not system features

## How to Use This Template

- Follow the instructions in each `<instruction>` block
- Look at `<example>` blocks to see good vs bad patterns
- Fill in each section from discovery conversations, user research, or domain knowledge
- The resulting `prd.md` is the input for creating a `plan.md` using `docs/plan-template.md`

## Document Pipeline

```
prd.md (this template)     → Problem space: pain, personas, outcomes, testable journeys
  ↓
plan.md (plan-template)    → Solution space: capabilities, journey contracts, architecture, risks
  ↓
tasks.md (tasks-template)  → Execution: BDD phases (journey tests), TDD tasks (unit contracts)
```
</prd-method>

---

<problem-statement>
<instruction>
Describe the core problem. Be ruthlessly specific:
- What exactly breaks, fails, or frustrates?
- What is the observable symptom the user sees?
- What is the root cause (if known)?

Do NOT describe solutions here. If you catch yourself writing "we should add X" or "the fix is Y", stop — that belongs in the plan, not the PRD.

<example type="good">
**Pain Point**: All user-uploaded content (profile pictures, inbox avatars, conversation attachments) breaks after every deploy. Active Storage URLs redirect to the app dashboard instead of serving the file, because Caddy's catch-all intercepts them before they reach Rails.
</example>

<example type="bad">
**Pain Point**: We need to add a /rails/* proxy rule to Caddy and migrate to S3.
(Problem: This is a SOLUTION, not a pain point. What user-visible problem does it solve?)

**Pain Point**: File uploads don't work well.
(Problem: Too vague. What specifically doesn't work? For whom? When?)
</example>
</instruction>

## Problem Statement

**Pain Point**: [What breaks, fails, or frustrates — be specific about the observable symptom]

</problem-statement>

---

<who>
<instruction>
Name the specific personas affected. For each persona, state:
- Their role or relationship to the system
- What content or workflow is affected
- How severely they're impacted

Reject vague audiences. "All users" is not a persona — break it down into concrete segments.

<example type="good">
**Who**:
- **Super admins** (type=SuperAdmin) — profile pictures and global bot avatars appear broken after deploy
- **Account agents** (type=nil) — conversation attachments show as broken images to contacts
- **Contacts** (end users) — receive broken image links in WhatsApp messages, eroding trust
</example>

<example type="bad">
**Who**: All users are affected.
(Problem: Which users? What are they doing when they're affected? How severely?)

**Who**: People who upload files.
(Problem: What kind of people? What kind of files? What happens to them?)
</example>
</instruction>

**Who**: [Specific personas, their roles, and how they're affected]

</who>

---

<current-alternatives>
<instruction>
What do users do TODAY to work around this problem? Options:
- Manual workaround (re-upload, restart, clear cache)
- Alternative tool or service
- They don't — they just suffer
- This is the first time the problem has surfaced

Be honest. "None" is a valid answer if the problem is new or has no workaround. But if there IS a workaround, describe it — understanding current behavior reveals how urgent the fix is.

<example type="good">
**Current Alternatives**: None. Uploads break on every deploy and stay broken until re-uploaded — which also breaks on the next deploy. Users have reported it once but assumed it was a temporary glitch.
</example>

<example type="bad">
**Current Alternatives**: There are some workarounds.
(Problem: What workarounds? Be specific.)
</example>
</instruction>

**Current Alternatives**: [What users do today — workarounds, alternative tools, or nothing]

</current-alternatives>

---

<desired-outcome>
<instruction>
What does success look like FROM THE USER'S PERSPECTIVE? Not "implement X" — what changes for the user?

State outcomes in observable, measurable terms:
- "Uploaded content persists across deploys" (observable)
- "Each partner's storage costs are attributable" (measurable)

Avoid implementation language. If you find yourself naming technologies, classes, or config files, you've crossed into solution territory.

The Desired Outcome describes the high-level change. The User Journeys section (next) breaks it down into testable scenarios.

<example type="good">
**Desired Outcome**: Uploaded content (avatars, attachments) remains accessible after every deploy. Each partner's storage costs are independently attributable. Uploads survive server migration or volume loss.
</example>

<example type="bad">
**Desired Outcome**: Add a handle /rails/* block to Caddyfile and migrate Active Storage to S3-compatible service with per-PlatformApp bucket routing.
(Problem: This is an implementation plan, not a desired outcome. What does the USER experience?)

**Desired Outcome**: Better file handling.
(Problem: Unmeasurable. What does "better" mean in observable terms?)
</example>
</instruction>

**Desired Outcome**: [What changes for the user — observable and measurable]

</desired-outcome>

---

<jobs-to-be-done>
<instruction>
Frame user needs as Jobs to Be Done. The format is:

  "When [situation], I want to [motivation], so I can [outcome]."

Rules:
- The situation is WHEN the need arises (not "always")
- The motivation is what the user WANTS TO DO (not what the system should do)
- The outcome is WHY they want it (the business or personal value)

Write 3-6 JTBD statements. Each should be independent — not steps in a sequence.

<example type="good">
- When I deploy a new version, I want uploaded content to keep working, so users don't see broken images.
- When a partner onboards, I want their uploads isolated to their own storage, so I can attribute costs per partner.
- When the server is migrated, I want uploads to survive, so there's no data loss.
</example>

<example type="bad">
- I want the system to use S3.
(Problem: This is a solution, not a job. WHY do you want S3? What situation triggers this need?)

- When I use the app, I want it to work.
(Problem: Too vague. What specific situation? What specific thing should work?)
</example>
</instruction>

## Jobs to Be Done

- When [situation], I want to [motivation], so I can [outcome]

</jobs-to-be-done>

---

<user-journeys>
<instruction>
Break the desired outcome into testable user journeys. Each journey is a scenario that can be directly translated into an integration test.

The format is:

  "Given [precondition], when [action], then [observable result]."

Rules:
- The "given" sets up the precondition (what must be true before the action)
- The "when" is the user action or system event that triggers the behavior
- The "then" is an observable, verifiable result — if you can't write a test for it, it's too vague
- Number each journey (J1, J2, ...) — downstream documents reference them by ID
- Each journey is independent — not a step in a sequence
- No implementation language — no endpoint paths, class names, or config files (those belong in the plan)

Jobs to Be Done capture user MOTIVATION ("so I can..."). User Journeys capture testable BEHAVIOR ("then X happens"). Both are needed — they serve different purposes.

<example type="good">
- **J1**: Given a user has uploaded a profile picture, when a new version is deployed, then the profile picture URL returns the image (not a redirect to the SPA).
- **J2**: Given an account belongs to a partner's platform, when a user uploads a conversation attachment, then the file is stored in that partner's isolated storage.
- **J3**: Given the server is migrated to a new host, when a user views a previously uploaded avatar, then the avatar loads successfully.
</example>

<example type="bad">
- Given the system is running, when a user uploads a file, then it works.
(Problem: "it works" is not observable. What specifically happens? What can you assert?)

- Given the Caddyfile has a /rails/* proxy rule, when a GET request hits /rails/active_storage/blobs/redirect/..., then it returns 302.
(Problem: Implementation language — Caddyfile, endpoint paths. This belongs in the plan's journey contract, not the PRD.)

- J1: Upload avatar. J2: View avatar. J3: Delete avatar.
(Problem: These are steps in a sequence, not independent journeys. Each should stand alone.)
</example>
</instruction>

## User Journeys

- **J1**: Given [precondition], when [action], then [observable result]
- **J2**: Given [precondition], when [action], then [observable result]

</user-journeys>

---

<assumptions>
<instruction>
List what you're assuming to be true. Assumptions are things that, if wrong, would change the scope or approach significantly.

Categories:
- **Data assumptions**: What exists in the system today (records, configurations, infrastructure)
- **User assumptions**: How users behave or what they expect
- **Technical assumptions**: What the system can or can't do today
- **Scope assumptions**: What's included vs excluded

Each assumption should be falsifiable — you could check whether it's true.

<example type="good">
1. The heyclara PlatformApp already exists in production (verified via Rails console)
2. Every account must belong to exactly one PlatformApp — orphan accounts need migration
3. Spaces credentials are already available in the production environment
4. The Caddy fix and storage migration can ship as separate deploys
</example>

<example type="bad">
1. This should be easy to implement.
(Problem: Not falsifiable. Not an assumption about the problem — it's a guess about the solution.)

2. Users will like this.
(Problem: Vague. Which users? Like what specifically?)
</example>
</instruction>

## Assumptions

- [Assumption 1 — falsifiable statement about current state]

</assumptions>

---

<research-findings>
<instruction>
Include this section ONLY when web research was conducted during discovery. If no research was done, omit the entire section.

For each finding:
- State the fact or data point
- Include the source (URL or reference)
- Note whether the user confirmed, corrected, or rejected it

Do not include speculative findings or unverified claims.
</instruction>

## Research Findings

- [Finding 1 — fact, source, user confirmation status]

(Omit this section entirely if no web research was conducted.)

</research-findings>

---

<quality-checklist>
# PRD Quality Checklist

Before finalizing, verify:

- [ ] **Pain Point** describes a user-visible problem, not a solution
- [ ] **Who** names specific personas with concrete impacts — not "all users"
- [ ] **Current Alternatives** is honest — workarounds, nothing, or first occurrence
- [ ] **Desired Outcome** is observable and measurable — no implementation language
- [ ] **Jobs to Be Done** use the When/Want/So format with independent statements
- [ ] **User Journeys** use Given/When/Then with observable "then" clauses
- [ ] **User Journeys** are numbered (J1, J2, ...) and each is independent
- [ ] **User Journeys** contain no implementation language (no endpoints, class names, config files)
- [ ] **Assumptions** are falsifiable and relevant to scope decisions
- [ ] No solution language leaked into any section (no class names, config files, or API endpoints)
- [ ] A reader who knows nothing about the codebase can understand the problem
</quality-checklist>
