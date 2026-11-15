# Trasgo Speckit Website — Problem Requirements Document

---

## Problem Statement

**Pain Point**: A product engineer with 15+ years of experience has built a disciplined, spec-driven AI development workflow (Trasgo Speckit) but has no public-facing artifact that explains the paradigm, demonstrates the method, or differentiates it from ad-hoc AI prompting. The GitHub repo exists but is a raw preset with a technical README — it doesn't communicate the "why" or the workflow's value proposition. As a result, potential adopters can't discover or understand the approach, and potential clients can't evaluate the engineer's methodology before engaging.

---

**Who**:

- **Developers using AI coding tools** — engineers already using Copilot, Cursor, or Claude Code who get inconsistent, messy output. They want a structured workflow but don't know Trasgo Speckit exists or how it differs from prompting harder. Impact: they never discover the preset, so they keep struggling with ad-hoc AI output.

- **CTOs and tech leads evaluating contractors** — technical decision-makers looking for freelancers or product builders who demonstrate process discipline, not just a portfolio of finished work. Impact: they can't assess the engineer's methodology because there's no visible proof — just a LinkedIn profile and standard portfolio that look like every other contractor.

- **Non-technical founders** — solo founders or small teams with an idea but no engineering capacity. They need someone who understands product AND code — someone who knows *what* to build, not just *how*. Impact: they can't tell this engineer apart from a generic freelance developer because the spec-driven approach isn't communicated anywhere.

---

**Current Alternatives**: The engineer has a LinkedIn profile and a standard portfolio, but neither showcases the spec-driven methodology specifically. The trasgo-speckit GitHub repo is public but reads as a technical preset README — it doesn't explain the paradigm, tell a story, or promote services. Someone would need a direct conversation to understand the approach.

---

**Desired Outcome**: A public website where visitors can understand the spec-driven convergence loop, see how it produces reliable software through AI-assisted development, and take action. The primary measurable outcome is preset installations (visitors click through to GitHub and install trasgo-speckit). The secondary outcome is service inquiries (founders or teams contact the engineer to hire "actual trasgos" to build their product). The site becomes a linkable artifact for LinkedIn, resumes, and online presence that establishes authority on spec-driven AI development.

---

## Jobs to Be Done

- When I'm getting inconsistent results from AI coding tools, I want to see a structured workflow that tames the chaos, so I can adopt a method that produces reliable software instead of guessing with prompts.

- When I'm evaluating a product engineer for a contract or project, I want to see their development methodology in action, so I can trust they'll deliver disciplined, spec-driven work — not just "vibe code."

- When I have a product idea but no technical team, I want to find a builder who understands the product problem first, so I can get software that solves the right problem — not just code that compiles.

- When I'm building my professional presence online, I want a public artifact that demonstrates my spec-driven AI workflow, so I can differentiate myself from generic developers and establish authority in the space.

- When I discover a new development methodology, I want to try it quickly in my existing setup, so I can evaluate whether it improves my workflow without a large upfront commitment.

---

## User Journeys

- **J1**: Given a developer has landed on the website for the first time, when they read the hero section and introductory content, then they can articulate what spec-driven development is and how it differs from ad-hoc AI prompting — without scrolling past the first screen.

- **J2**: Given a visitor understands the philosophy, when they read the method section explaining the convergence loop, then they can describe the five steps (specify, plan, tasks, implement, converge) and understand that the pipeline loops until the deliverable matches the spec.

- **J3**: Given a visitor understands the method, when they read the value proposition section, then they see a clear claim about speed and quality (days not weeks, spec-gated quality) with enough specificity to evaluate whether the approach is credible.

- **J4**: Given a developer is convinced by the approach, when they click the primary call-to-action, then they arrive at the trasgo-speckit GitHub repository page with installation instructions visible.

- **J5**: Given a visitor wants to install the preset, when they follow the installation instructions on GitHub, then the preset is added to their Spec Kit setup and appears in `specify preset list` within two shell commands.

- **J6**: Given a non-technical founder or CTO is browsing the site, when they scroll to the services footer section, then they see a brief pitch explaining what "hiring trasgos" means (spec-driven product building) and a contact form to reach out — without needing to navigate away from the page.

- **J7**: Given a visitor has submitted the contact form, when the form is submitted, then they see a confirmation that their message was received, and the site owner receives the inquiry with the visitor's name, email, and message.

- **J8**: Given the site owner wants to share the site on LinkedIn or a resume, when they paste the site URL, then the link preview displays a professional title, description, and the trasgo workshop banner image.

- **J9**: Given a visitor is browsing on a mobile device, when they view any section of the site, then all content is readable and interactive without horizontal scrolling or broken layouts.

---

## Assumptions

1. The trasgo-speckit GitHub repo will remain public and accessible at https://github.com/trasgo-furioso/trasgo-speckit — the site links to it as the primary CTA.
2. The banner artwork (banner.webp) and the medieval fantasy visual identity already exist and are ready to use on the site.
3. The site does not need user accounts, authentication, or any persistent user state — it is a static informational and marketing site.
4. The contact form can send messages without requiring the site owner to run a backend server (e.g., a third-party form service or email forwarding is acceptable).
5. The target audience reads English — no internationalization is needed for the initial version.
6. The site needs to be hosted on a publicly accessible URL that can be linked from LinkedIn, resumes, and other online presence.
7. The medieval fantasy theme is expressed through visual art and design only — the copy remains professional and straightforward, not written in fantasy narrative style.
