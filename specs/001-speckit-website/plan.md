# Trasgo Speckit Website — Implementation Plan

---

## Problem Statement

A product engineer with 15+ years of experience has built Trasgo Speckit, a disciplined spec-driven AI development workflow, but has no public-facing artifact to explain the paradigm, drive adoption, or generate service leads. The GitHub repo is raw and technical. Potential adopters and clients can't discover, understand, or evaluate the approach.

## Target Users

| Persona | What they seek | Arrival path |
|---------|---------------|--------------|
| **Developers using AI coding tools** | A structured workflow to tame inconsistent AI output | Search, social media, community links |
| **CTOs / tech leads evaluating contractors** | Visible proof of process discipline and methodology | LinkedIn profile, resume link, direct share |
| **Non-technical founders** | A product builder who knows *what* to build, not just *how* | LinkedIn, referrals, resume link |

## Success Metrics

| Metric | Target | Measurement |
|--------|--------|-------------|
| Primary CTA clicks | Visitors click "Get Started" to GitHub repo | Link click tracking (outbound) |
| Contact form submissions | Founders/CTOs submit service inquiries | Netlify Forms submission count |
| Link preview quality | Professional OG preview on LinkedIn/social shares | Manual verification of meta tags |
| Mobile usability | All content readable without horizontal scroll | Playwright viewport tests |
| Page load time | < 2s on 3G connection | Lighthouse performance audit |

---

## Capability Tree

### Capability: Content Presentation
Communicates the spec-driven development paradigm through a progressive narrative: philosophy, method, result.

#### Feature: Hero Section
- **Description**: Above-the-fold section that communicates what spec-driven development is and how it differs from ad-hoc AI prompting
- **Inputs**: Workshop scene image (three-cartoony-goblins...png), headline copy, tagline
- **Outputs**: Rendered hero with banner image, headline, tagline, and primary CTA button
- **Behavior**: Display workshop scene prominently, state the core value proposition, and provide a clear "Get Started" button linking to GitHub repo
- **Supports**: J1, J4
- **Copy**:
  - Headline: "Spec-Driven Development for AI-Assisted Coding"
  - Tagline: "Stop prompting and praying. Start specifying, planning, and building — with a structured loop that converges on quality software in days, not weeks."
  - CTA: "Get Started" → https://github.com/trasgo-furioso/trasgo-speckit

#### Feature: Method Section (Convergence Loop)
- **Description**: Visual and textual explanation of the convergence loop, with per-step character cards
- **Inputs**: Convergence loop diagram SVG (swap-tasks-and-converge.svg), trasgo character images, step descriptions
- **Outputs**: Rendered section with loop diagram and 3-column feature cards
- **Behavior**: Display the loop diagram with brief explanation, then three character cards mapping trasgos to pipeline steps. Highlight that the pipeline loops — it's not a waterfall. Emphasize human gates at each step.
- **Supports**: J2
- **Copy**:
  - Section heading: "How It Works"
  - Diagram caption: "Every feature starts as a user problem, gets decomposed into testable journeys, and is implemented through red-green cycles. A convergence loop ensures the deliverable matches the spec."
  - Card 1 (green trasgo): **Specify & Plan** — "Define the problem, not the solution. Capture user journeys in Given/When/Then format, then design the architecture with journey contracts."
  - Card 2 (brown trasgo): **Tasks** — "Break the plan into BDD/TDD phases. Every task starts with a failing test. Every phase ends with a runnable exit command."
  - Card 3 (red trasgo): **Implement & Converge** — "Build phase by phase through red-green cycles. Then converge: compare the codebase against the spec, find gaps, and loop until done."

#### Feature: Value Proposition Section
- **Description**: Clear claim about the business outcome of spec-driven AI development — speed and quality
- **Inputs**: Copy with three icon cards
- **Outputs**: Rendered section with 3-column icon cards (Font Awesome icons)
- **Behavior**: Present three pillars: structured process, speed, and human control. Each card has an icon, title, and brief copy.
- **Supports**: J3
- **Copy**:
  - Section heading: "Why Spec-Driven?"
  - Subhead: "The opposite of vibe coding"
  - Card 1 (icon: fa-compass-drafting): **Structured, not ad-hoc** — "AI agents follow specs and journey contracts, not open-ended prompts. Every output is testable."
  - Card 2 (icon: fa-bolt): **Days, not weeks** — "The convergence loop eliminates rework. You specify once, then implement and converge until the deliverable matches the spec."
  - Card 3 (icon: fa-user-shield): **Human gates, AI labor** — "You review every artifact before the next step. The AI does the heavy lifting; you stay in control of what ships."

#### Feature: Install CTA
- **Description**: Code block with install commands and GitHub link
- **Inputs**: Install commands from README, GitHub repo URL
- **Outputs**: Rendered code block with install commands and a "View on GitHub" button
- **Behavior**: Show the two-command install sequence. Link to the GitHub repo. Positioned after the value proposition to capture visitors who've read through the narrative.
- **Supports**: J4, J5
- **Copy**:
  - Section heading: "Get Started"
  - Prerequisite: "Requires Spec Kit >= 0.15.0"
  - Code block:
    ```bash
    git clone https://github.com/trasgo-furioso/trasgo-speckit.git .trasgo-speckit
    specify preset add --dev .trasgo-speckit/preset/ --priority 1
    ```
  - Button: "View on GitHub" → https://github.com/trasgo-furioso/trasgo-speckit

### Capability: Lead Generation
Enables potential clients to express interest in hiring the product builder.

#### Feature: Services Footer
- **Description**: Footer section with a brief pitch explaining spec-driven product building services and a contact form
- **Inputs**: Service pitch copy, form fields (name, email, message)
- **Outputs**: Rendered footer with pitch text and embedded contact form
- **Behavior**: Display a brief professional pitch with a contact form. Form submits via Netlify Forms (no backend required). Notifications to trasgofurioso@gmail.com.
- **Supports**: J6, J7
- **Copy**:
  - Heading: "Hire Actual Trasgos"
  - Pitch: "Need a product built, not just coded? 15+ years of product and engineering experience, powered by spec-driven development. We know what to build — not just how."
  - Form fields: Name, Email, Message, Submit button
  - Bottom bar: Copyright, GitHub/LinkedIn social links

#### Feature: Form Submission Feedback
- **Description**: Confirmation UI after a visitor submits the contact form
- **Inputs**: Form submission event
- **Outputs**: Visual confirmation message replacing or overlaying the form
- **Behavior**: On successful submission, display "Message received — we'll be in touch." Clear the form fields. No page navigation required.
- **Supports**: J7

### Capability: Social Shareability
Ensures the site looks professional when shared as a link on LinkedIn, resumes, and social media.

#### Feature: Open Graph Meta Tags
- **Description**: Meta tags that control how the site's link preview appears on social platforms
- **Inputs**: Site title, description, banner image URL
- **Outputs**: HTML `<head>` meta tags (og:title, og:description, og:image, og:url, twitter:card)
- **Behavior**: Set og:title to "Trasgo Speckit — Spec-Driven Development for AI-Assisted Coding". Set og:description to a one-sentence summary. Set og:image to the banner.webp (or a PNG derivative if platforms require it). Include twitter:card=summary_large_image.
- **Supports**: J8

### Capability: Responsive Layout
Ensures the site works across devices and screen sizes.

#### Feature: Mobile-First Responsive Design
- **Description**: CSS layout that adapts all sections to mobile, tablet, and desktop viewports
- **Inputs**: HTML content from all sections
- **Outputs**: Responsive rendered layout at any viewport width >= 320px
- **Behavior**: Stack sections vertically on mobile. Use a max-width container for readability on desktop. Ensure the convergence loop diagram is legible on small screens. Contact form fields stack on mobile.
- **Supports**: J9

---

## Template Component Mapping

Based on `devtool-template-main/index.html`. Reference line numbers are from the original template.

| # | Site Section | Template Component (class / lines) | Action | Details |
|---|---|---|---|---|
| 1 | **Header** | `nav-container` (L47-71) | Modify | Logo SVG from brand.json, nav links → #method / #install / #services (anchor scroll), CTA button → GitHub repo, remove Sign In/Up buttons |
| 2 | **Hero** | `heading.hero` + `image-wide` (L73-91) | Modify | Remove eyebrow badge. H1 → "Spec-Driven Development for AI-Assisted Coding". Paragraph → tagline. Single CTA "Get Started" → GitHub. Image → workshop-scene.png |
| 3 | ~~Social proof~~ | `clients-container` (L92-106) | **Delete** | No client logos needed |
| 4 | **Method - Diagram** | `heading` + single `feature-card` in `grid` (L107-136) | Modify | H2 → "How It Works". Description → diagram caption. Image → swap-tasks-and-converge.svg. Delete the 2-column and 3-column feature grids below (L137-212) |
| 5 | **Method - Characters** | `grid columns-3` with 3x `feature-card` (L169-212) | Repurpose | Move up after diagram card. Card 1 → green trasgo + "Specify & Plan". Card 2 → brown trasgo + "Tasks". Card 3 → red trasgo + "Implement & Converge" |
| 6 | **Value Prop** | `cards-with-icons-container` with 3x `card-with-icon horizontal` (L214-258) | Modify | H2 → "Why Spec-Driven?". Subhead → "The opposite of vibe coding". Icons → `fa-compass-drafting` / `fa-bolt` / `fa-user-shield`. Copy per card |
| 7 | ~~Wide image block~~ | `heading` + `image-wide` (L260-276) | **Delete** | Not needed |
| 8 | **Install CTA** | `grid columns-1/2-1` + `card-code-block` (L278-314) | Modify | H2 → "Get Started". Description → "Requires Spec Kit >= 0.15.0". Code block → bash install commands. Add "View on GitHub" button via `button-group` |
| 9 | ~~FAQ~~ | `accordion-container` (L315-498) | **Delete** | Not needed for v1 |
| 10 | ~~Promo CTA~~ | `promo-cta` (L500-508) | **Delete** | Replaced by services section |
| 11 | **Services + Contact** | New section + modified `footer` (L510-550) | **Replace** | New `<section>` above footer: "Hire Actual Trasgos" heading + pitch paragraph + Netlify Forms contact form (name/email/message). Footer reduced to copyright + GitHub/LinkedIn social links |

**Kept unchanged**: `<head>` structure (OG values updated), font preloads, CSS/JS imports, `background-gradient` div, `page-container` wrapper, all responsive CSS files (tablet.css, mobile.css).

**Summary**: 6 template sections reused, 4 deleted, 1 replaced. No new CSS components needed — everything maps to existing LaunchKit classes.

---

## Journey Contracts

### J1: First-time visitor understands spec-driven development
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL
- **Action**: Read the hero section without scrolling
- **Assert**: Hero section contains visible text explaining what spec-driven development is. The section includes the banner image (loaded, non-zero dimensions). A CTA button with text "Get Started" or equivalent is visible and links to `https://github.com/trasgo-furioso/trasgo-speckit`.

### J2: Visitor understands the convergence loop
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL
- **Action**: Scroll to the method section
- **Assert**: Section contains the five step names (specify, plan, tasks, implement, converge). The word "loop" or "converge" appears to convey iteration. The section mentions "human gate" or equivalent concept.

### J3: Visitor sees speed and quality claim
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL
- **Action**: Scroll to the value proposition section
- **Assert**: Section contains text about delivery speed ("days" referenced). Section contains text about quality assurance ("spec-gated" or "spec-driven" referenced). No unsubstantiated claims without supporting explanation.

### J4: CTA links to GitHub repo
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL
- **Action**: Click the primary CTA button
- **Assert**: Navigation target is `https://github.com/trasgo-furioso/trasgo-speckit`. The link has `target="_blank"` or equivalent to open in new tab. The link `href` is exactly the expected URL.

### J5: Install instructions are followable
- **Tier**: API (shell execution test)
- **Setup**: A clean Spec Kit environment (>= 0.15.0) with no presets installed
- **Action**: Run the two install commands shown on the website (git clone + specify preset add)
- **Assert**: `specify preset list` output includes `trasgospec` at priority 1. Exit code is 0 for all commands.

### J6: Services footer with contact form
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL
- **Action**: Scroll to the bottom of the page (services footer)
- **Assert**: A section with service pitch text is visible (contains "product" and "build" or equivalent). A form is visible with fields: name (input), email (input type="email"), message (textarea). A submit button is visible.

### J7: Contact form submission shows confirmation
- **Tier**: Playwright (browser E2E)
- **Setup**: Navigate to site root URL, scroll to contact form
- **Action**: Fill in name ("Test User"), email ("test@example.com"), message ("Test inquiry"), submit the form
- **Assert**: After submission, a confirmation message is visible (contains "received" or "thank you"). The form fields are cleared or replaced by the confirmation.

### J8: Link preview shows professional metadata
- **Tier**: API (HTML inspection)
- **Setup**: Fetch the site's HTML via HTTP GET
- **Action**: Parse the HTML `<head>` section
- **Assert**: `og:title` meta tag exists and is non-empty. `og:description` meta tag exists and is non-empty. `og:image` meta tag exists and points to an accessible image URL. `twitter:card` meta tag is set to `summary_large_image`.

### J9: Mobile responsive layout
- **Tier**: Playwright (browser E2E, mobile viewport)
- **Setup**: Navigate to site root URL with viewport 375x812 (iPhone-sized)
- **Action**: Scroll through all sections
- **Assert**: No horizontal scrollbar appears (document.documentElement.scrollWidth <= window.innerWidth). All text is readable (font-size >= 14px for body text). CTA button and form fields are tappable (min 44px touch target).

---

## Repository Structure

Based on the [LaunchKit devtool-template](https://github.com/evilmartians/devtool-template) by Evil Martians.

```
site/                                   # FORK of devtool-template-main/
├── index.html                          # MODIFIED — single-page site (replaces template content)
├── css/
│   ├── index.css                       # MODIFIED — theme colors adapted to brand palette
│   ├── tablet.css                      # KEPT — tablet breakpoints
│   └── mobile.css                      # KEPT — mobile breakpoints
├── fonts/
│   ├── InterVariable.woff2             # KEPT — body font
│   ├── InterVariable-Italic.woff2      # KEPT
│   └── JetBrainsMono-VariableFont_wght.ttf  # KEPT — code blocks
├── images/
│   ├── banner.webp                     # COPY from assets/ — hero background
│   ├── banner.png                      # NEW — PNG fallback for OG image
│   ├── trasgo-specifier.png            # COPY — green goblin (specify/plan steps)
│   ├── trasgo-designer.png             # COPY — brown goblin (tasks/design steps)
│   ├── trasgo-builder.png              # COPY — red goblin (implement/converge steps)
│   ├── workshop-scene.png              # COPY — three trasgos at table (group scene)
│   ├── logo.svg                        # NEW — extracted from brand.json SVG
│   ├── favicon/
│   │   ├── favicon.png                 # NEW — generated from logo
│   │   ├── icon.svg                    # NEW — generated from logo
│   │   └── apple-touch-icon.png        # NEW — generated from logo
│   └── social-image.png               # NEW — OG image (1200x630) with banner + title
├── vendor/
│   └── font-awesome-6.7.2/            # KEPT — icons
├── js/
│   └── main.js                         # MODIFIED — add contact form handling
├── netlify.toml                        # NEW — Netlify deploy config
└── _headers                            # NEW — Netlify custom headers (caching)

tests/                                  # NEW — test suite
├── playwright.config.js                # NEW — Playwright config
├── e2e/
│   ├── hero.spec.js                    # NEW — J1, J4 tests
│   ├── method.spec.js                  # NEW — J2 tests
│   ├── value-prop.spec.js              # NEW — J3 tests
│   ├── contact-form.spec.js            # NEW — J6, J7 tests
│   ├── mobile.spec.js                  # NEW — J9 tests
│   └── meta-tags.spec.js              # NEW — J8 tests
└── package.json                        # NEW — test dependencies (Playwright)
```

## Visual Asset Strategy

### Brand Palette (from `assets/brand.json`)

| Token | Value | Usage |
|-------|-------|-------|
| Primary | `#2D5016` (forest green) | Accent color, CTA buttons, headings |
| Ink | `#1A1A1A` (near black) | Body text |
| Paper | `#F5F3EE` (warm parchment) | Page background |
| Gold | `#D4AF37` (gold accent) | Highlights, hover states, secondary accents |

These map to LaunchKit's OKLCH CSS variable system by overriding `--theme-hue`, `--theme-saturation`, and surface/text color variables.

### Character Art Placement

| Image | Character | Site Section | Role |
|-------|-----------|-------------|------|
| `trasgo-specifier.png` (green, glasses, compass) | The Architect | Method section — Specify & Plan steps | Represents the specification phase |
| `trasgo-designer.png` (brown, beret, sketchbook) | The Designer | Method section — Tasks step | Represents the design/planning phase |
| `trasgo-builder.png` (red, tool belt, hammer) | The Builder | Method section — Implement & Converge steps | Represents the build/verify phase |
| `workshop-scene.png` (group at table) | All three | Hero section — main visual | Sets the workshop atmosphere |
| `banner.webp` (original banner) | All three | OG image / social preview fallback | Social sharing |

### Image Optimization

- Character PNGs have transparent backgrounds — they can be placed over colored cards or sections
- Hero uses the workshop scene as a wide image block (like LaunchKit's hero image pattern)
- Method section uses individual character images inside feature cards (LaunchKit's 3-column grid)
- All images get `loading="lazy"` except the hero image
- Generate `social-image.png` (1200x630) compositing the banner with site title overlay for OG

### Imagery to Create with Recraft.ai

- **Convergence loop diagram**: Static visual showing the 5 steps in a circular flow with arrows, styled to match the brand palette (forest green, gold accents, parchment background). Line art style consistent with `brand.json` vector_illustration style.

### Existing Assets Ready to Use

- **Favicon/icon**: `assets/adapt-the-goblin-face-from-the-reference-image-int.svg` — 2048x2048 goblin face icon in brand colors (#315018 green on #F5F6EE parchment). Generate PNG derivatives (32x32, 180x180, 512x512) from this SVG for favicon set.

## Module Definitions

### Module: site/
- **Maps to capability**: Content Presentation, Lead Generation, Social Shareability, Responsive Layout
- **Responsibility**: Static website served by Netlify, forked from LaunchKit devtool-template
- **Base**: `devtool-template-main/` — keep CSS architecture, font stack, responsive breakpoints, JS patterns
- **Customize**: Theme colors (brand palette), content (all sections), images (trasgo artwork)

### Module: site/css/index.css
- **Maps to capability**: Responsive Layout, Content Presentation
- **Responsibility**: Theme customization and any trasgo-specific component styles
- **Key changes**:
  - Override `:root` / `.theme-light` color variables with brand palette
  - Override `.theme-dark` for dark mode (if kept — optional for v1)
  - Background color from white to `#F5F3EE` (paper)
  - Accent from blue to `#2D5016` (primary green)
  - Add gold accent for hover/highlight states

### Module: site/js/main.js
- **Maps to capability**: Lead Generation (form handling)
- **Responsibility**: Mobile nav (kept from template) + contact form submission handling
- **Key additions**:
  - Form submit handler — intercepts Netlify form POST, shows confirmation message
  - Smooth scroll — anchor link navigation between sections

### Module: tests/
- **Maps to capability**: All journey contracts
- **Responsibility**: E2E and integration tests validating journey contracts
- **Exports**: Playwright test suites

---

## System Components

```
┌──────────────────────────────────────────────────┐
│                   Visitor Browser                  │
│                                                    │
│  ┌─────────┐  ┌──────────┐  ┌─────────────────┐  │
│  │  Hero   │→│  Method  │→│  Value Prop      │  │
│  │ Section │  │  Section │  │  + Install CTA   │  │
│  └─────────┘  └──────────┘  └─────────────────┘  │
│                                                    │
│  ┌─────────────────────────────────────────────┐  │
│  │  Services Footer + Contact Form              │  │
│  └──────────────────┬──────────────────────────┘  │
│                     │ POST                         │
└─────────────────────┼──────────────────────────────┘
                      │
              ┌───────▼───────┐
              │ Netlify Forms │ → Email notification to site owner
              └───────────────┘
```

## Data Models

No database. The only data flow is the contact form:

| Field | Type | Required | Validation |
|-------|------|----------|------------|
| name | text | yes | Non-empty, max 100 chars |
| email | email | yes | Valid email format (HTML5 validation) |
| message | textarea | yes | Non-empty, max 2000 chars |

Netlify Forms handles storage and email forwarding natively.

## Technology Stack

| Layer | Technology | Rationale |
|-------|-----------|-----------|
| Template | LaunchKit (Evil Martians devtool-template) | Purpose-built for dev tool landing pages, no build step, OKLCH theming |
| Markup | HTML5 | No build step, maximum simplicity |
| Styling | CSS3 (vanilla, OKLCH variables from LaunchKit) | Responsive breakpoints, spacing system, and typography included |
| Fonts | Inter Variable + JetBrains Mono (self-hosted) | Professional + code-friendly, included in template |
| Icons | Font Awesome 6.7.2 (vendored) | Included in template, no CDN dependency |
| Interaction | Vanilla JS (ES6+) | Minimal — mobile nav (template), form handling, smooth scroll |
| Hosting | Netlify (free tier) | Built-in forms, CDN, custom domain support, zero config |
| Testing | Playwright | Browser E2E tests for journey contracts |
| Form backend | Netlify Forms | Zero backend, built-in to hosting platform |
| Imagery | Recraft.ai + existing character art | Convergence loop diagram, favicon, social image |

**Decision: LaunchKit devtool-template as base**
- **Rationale**: Purpose-built for dev tool landing pages. Includes responsive CSS architecture with OKLCH theming, typography system (Inter + JetBrains Mono), Font Awesome icons, and mobile navigation — all with zero build step. The LaunchKit sample site (launchkit.evilmartians.io) demonstrates high-impact imagery placement that maps directly to our trasgo artwork.
- **Trade-offs**: Inheriting a template means learning its CSS conventions. Some template sections (pricing, client logos) need removal.
- **Alternatives considered**: Building from scratch (more work, same result), Tailwind (adds build complexity), static site generators (overkill for single page).

**Decision: Netlify Forms for contact form**
- **Rationale**: Zero configuration, no backend server, built into the hosting platform. Free tier supports 100 submissions/month. Notifications to trasgofurioso@gmail.com.
- **Trade-offs**: Tied to Netlify hosting. Limited customization of email notifications.
- **Alternatives considered**: Formspree, EmailJS, custom serverless function (all add external dependencies).

---

## Technical Risks

**Risk**: Banner image (webp) may not render in OG previews on all platforms
- **Impact**: Medium — LinkedIn/Twitter may not display the preview image
- **Likelihood**: Medium — some platforms prefer PNG/JPG for OG images
- **Mitigation**: Generate a PNG version of the banner for the og:image meta tag
- **Fallback**: Use a separate, simpler OG image optimized for social previews

**Risk**: Netlify Forms spam without captcha
- **Impact**: Low — spam submissions clutter the inbox
- **Likelihood**: Medium — public forms attract bots
- **Mitigation**: Add Netlify's built-in honeypot spam filter (`netlify-honeypot` attribute)
- **Fallback**: Enable Netlify's reCAPTCHA integration if spam becomes a problem

## Dependency Risks

**Risk**: Trasgo-speckit GitHub repo becomes private or URL changes
- **Impact**: High — primary CTA breaks
- **Likelihood**: Low — repo is intentionally public
- **Mitigation**: Test the outbound link in CI. Monitor for 404s.
- **Fallback**: Update the CTA URL

## Scope Risks

**Risk**: Copy writing expands into a full documentation site
- **Impact**: Medium — delays launch, increases complexity
- **Likelihood**: Medium — the paradigm has many concepts worth explaining
- **Mitigation**: Limit to 5 sections on a single page. Defer detailed docs to README or future pages.
- **Fallback**: Ship the minimal page first, add content incrementally

---

## References

- [GitHub Spec Kit documentation](https://github.com/github/spec-kit) — paradigm source, SDD concepts, convergence loop
- [Spec Kit docs site](../spec-kit/docs/) — reference for content structure, SDD explanation, 9-step process
- [LaunchKit devtool-template](https://github.com/evilmartians/devtool-template) — base HTML/CSS/JS template
- [LaunchKit sample site](https://launchkit.evilmartians.io/) — visual reference for image placement and layout
- [Netlify Forms documentation](https://docs.netlify.com/forms/setup/) — form setup without backend
- [Open Graph Protocol](https://ogp.me/) — meta tag specification for link previews
- `assets/brand.json` — Recraft brand definition with palette, logo SVG, and style rules

## Glossary

| Term | Definition |
|------|-----------|
| SDD | Spec-Driven Development — the paradigm where specifications become executable, not just documentation |
| Convergence loop | The iterative cycle: specify > plan > tasks > implement > converge, repeating until deliverable matches spec |
| Human gate | A review checkpoint between pipeline steps where a human approves before the next step begins |
| Trasgo | Spanish for "goblin" — the project's mascot and the engineer's nickname |
| Journey contract | A testable bridge between a PRD user journey and an integration test, defining tier, setup, action, and assertion |

## Resolved Questions

1. **Convergence loop diagram**: Static visual for v1 — no animation.
2. **Form notification email**: trasgofurioso@gmail.com
3. **Banner attribution**: Not required — no licensing obligations.
