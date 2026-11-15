# Trasgo Speckit Website — Tasks

---

## Dependency Chain

### Foundation Layer (P1)
- **site/**: Copy of `devtool-template-main/` — template scaffold, CSS architecture, fonts, icons, JS mobile nav. No dependencies.

### Content Layer (P2-P5)
- **site/index.html (hero)**: Depends on [site/]. Supports J1, J4.
- **site/index.html (method)**: Depends on [site/, hero]. Supports J2.
- **site/index.html (value-prop)**: Depends on [site/]. Supports J3.
- **site/index.html (install-cta)**: Depends on [site/]. Supports J4, J5.

### Interactivity Layer (P6)
- **site/index.html (services + contact form)**: Depends on [site/]. Supports J6, J7.
- **site/js/main.js (form handler)**: Depends on [services section]. Supports J7.

### Polish Layer (P7)
- **site/images/social-image.png**: Depends on [site/]. Supports J8.
- **site/css/ (responsive verification)**: Depends on [all content sections]. Supports J9.

---

## Development Phases

### Phase 1: Scaffold & Brand
**Journey**: Foundation — no specific journey, enables all subsequent phases

**Entry Criteria**: `devtool-template-main/` exists in repo root, `assets/brand.json` and trasgo images exist in `assets/`

**Tasks**:
- [ ] Copy `devtool-template-main/` to `site/`
- [ ] Delete unused template files: `pricing.html`, `licenses.html`, `css/pricing.css`, `js/pricing.js`
- [ ] Delete unused sections from `site/index.html`: social proof / clients-container (L92-106), 2-column feature grid (L137-168), wide image block (L260-276), FAQ accordion (L315-498), promo CTA (L500-508)
- [ ] Override CSS theme in `site/css/index.css`: set `.theme-light` color variables to brand palette — background `#F5F3EE` (paper), accent `#2D5016` (forest green), text primary `#1A1A1A` (ink), add gold accent `#D4AF37` for hover states
- [ ] Copy `assets/adapt-the-goblin-face-from-the-reference-image-int.svg` to `site/images/favicon/icon.svg` and generate PNG derivatives (32x32 favicon.png, 180x180 apple-touch-icon.png) — update favicon links in `<head>`
- [ ] Extract logo SVG from `assets/brand.json` → `site/images/logo.svg`, replace template logo in nav-container
- [ ] Update OG meta tags in `<head>`: og:title → "Trasgo Speckit — Spec-Driven Development for AI-Assisted Coding", og:description → "A structured, spec-driven workflow for AI-assisted coding. Stop prompting and praying — specify, plan, and build with a convergence loop that delivers quality software in days, not weeks.", twitter:card → summary_large_image
- [ ] Create `site/netlify.toml` with publish directory `site/` and basic caching headers

**Exit**: Use Playwright MCP to navigate to the site served locally. Verify:
1. Page loads without errors
2. Background color is parchment (`#F5F3EE`)
3. Favicon is the goblin face (not the template default)
4. OG meta tags are present in page source with correct values
5. Deleted sections (FAQ, pricing, social proof, promo CTA) are gone
6. Header, remaining content skeleton, and footer are visible

Exit command: `cd site && python3 -m http.server 8080 &` then verify with Playwright MCP

---

### Phase 2: Hero Section
**Journey**: J1 — First-time visitor understands spec-driven development, J4 — CTA links to GitHub repo

**Entry Criteria**: Phase 1 complete

**Tasks**:
- [ ] Copy `assets/three-cartoony-goblins-in-a-medieval-fantasy-works.png` → `site/images/workshop-scene.png`
- [ ] Modify hero section in `site/index.html`: remove eyebrow badge, set H1 to "Spec-Driven Development for AI-Assisted Coding", set paragraph to tagline "Stop prompting and praying. Start specifying, planning, and building — with a structured loop that converges on quality software in days, not weeks."
- [ ] Replace hero CTA buttons: single "Get Started" button (class `button primary`) linking to `https://github.com/trasgo-furioso/trasgo-speckit` with `target="_blank"`
- [ ] Replace hero `image-wide` img src with `images/workshop-scene.png`, set appropriate alt text
- [ ] Update header nav: replace template nav links with anchor links — "Method" → `#method`, "Install" → `#install`, "Services" → `#services`. Replace Sign In/Up buttons with single "Get Started" button → GitHub repo. Update GitHub icon link to `https://github.com/trasgo-furioso/trasgo-speckit`

**Exit**: Use Playwright MCP to verify:
1. Hero section visible with H1 containing "Spec-Driven Development"
2. Workshop scene image loaded (visible, non-zero dimensions)
3. "Get Started" CTA button visible and links to `https://github.com/trasgo-furioso/trasgo-speckit`
4. CTA has `target="_blank"` attribute
5. Nav links point to #method, #install, #services anchors

---

### Phase 3: Method Section
**Journey**: J2 — Visitor understands the convergence loop

**Entry Criteria**: Phase 2 complete

**Tasks**:
- [ ] Copy `assets/swap-tasks-and-converge.svg` → `site/images/convergence-loop.svg`
- [ ] Copy character images to `site/images/`: `show-this-green-goblin-architect-character-as-a-fu.png` → `trasgo-specifier.png`, `show-this-brown-skinned-goblin-designer-character-.png` → `trasgo-designer.png`, `show-this-red-goblin-constructor-character-as-a-fu.png` → `trasgo-builder.png`
- [ ] Modify feature showcase section: add `id="method"` for anchor link. Set H2 to "How It Works". Set description to diagram caption: "Every feature starts as a user problem, gets decomposed into testable journeys, and is implemented through red-green cycles. A convergence loop ensures the deliverable matches the spec."
- [ ] Replace full-width feature card image with convergence loop SVG (`images/convergence-loop.svg`)
- [ ] Repurpose the 3-column `grid columns-3` with three `feature-card` components:
  - Card 1: `trasgo-specifier.png` image + H3 "Specify & Plan" + paragraph "Define the problem, not the solution. Capture user journeys in Given/When/Then format, then design the architecture with journey contracts."
  - Card 2: `trasgo-designer.png` image + H3 "Tasks" + paragraph "Break the plan into BDD/TDD phases. Every task starts with a failing test. Every phase ends with a runnable exit command."
  - Card 3: `trasgo-builder.png` image + H3 "Implement & Converge" + paragraph "Build phase by phase through red-green cycles. Then converge: compare the codebase against the spec, find gaps, and loop until done."

**Exit**: Use Playwright MCP to verify:
1. Section with id="method" exists
2. H2 "How It Works" visible
3. Convergence loop SVG image loaded and visible
4. Page text contains all five step names: "specify", "plan", "tasks", "implement", "converge" (case-insensitive)
5. Text contains "loop" or "converge" conveying iteration
6. Three character cards visible, each with an image and heading text

---

### Phase 4: Value Proposition
**Journey**: J3 — Visitor sees speed and quality claim

**Entry Criteria**: Phase 3 complete

**Tasks**:
- [ ] Modify cards-with-icons section: set H2 to "Why Spec-Driven?", set subhead paragraph to "The opposite of vibe coding"
- [ ] Update the three `card-with-icon horizontal` components:
  - Card 1: icon `fa-solid fa-compass-drafting`, title "Structured, not ad-hoc", description "AI agents follow specs and journey contracts, not open-ended prompts. Every output is testable."
  - Card 2: icon `fa-solid fa-bolt`, title "Days, not weeks", description "The convergence loop eliminates rework. You specify once, then implement and converge until the deliverable matches the spec."
  - Card 3: icon `fa-solid fa-user-shield`, title "Human gates, AI labor", description "You review every artifact before the next step. The AI does the heavy lifting; you stay in control of what ships."

**Exit**: Use Playwright MCP to verify:
1. Section contains "Why Spec-Driven?" heading
2. Three icon cards visible
3. Text contains "days" (speed claim)
4. Text contains "spec-driven" or "spec-gated" (quality claim)
5. Each card has a Font Awesome icon element

---

### Phase 5: Install CTA
**Journey**: J4 — CTA links to GitHub repo, J5 — Install instructions are followable

**Entry Criteria**: Phase 4 complete

**Tasks**:
- [ ] Modify the `grid columns-1/2-1` code block section: add `id="install"` for anchor link. Set H2 to "Get Started". Set description to "Requires Spec Kit >= 0.15.0"
- [ ] Replace code block content with bash install commands (use [Code to Markup tool](https://psd-coder.github.io/code-to-markup/) referenced in template FAQ for syntax highlighting):
  ```bash
  git clone https://github.com/trasgo-furioso/trasgo-speckit.git .trasgo-speckit
  specify preset add --dev .trasgo-speckit/preset/ --priority 1
  ```
- [ ] Add a `button-group` below the description with "View on GitHub" button (class `button secondary`) linking to `https://github.com/trasgo-furioso/trasgo-speckit` with `target="_blank"`

**Exit**: Use Playwright MCP to verify:
1. Section with id="install" exists
2. H2 "Get Started" visible
3. Code block contains `git clone` and `specify preset add` commands
4. "View on GitHub" button visible and links to `https://github.com/trasgo-furioso/trasgo-speckit`
5. Text "Requires Spec Kit" visible

---

### Phase 6: Services & Contact Form
**Journey**: J6 — Services footer with contact form, J7 — Contact form submission shows confirmation

**Entry Criteria**: Phase 5 complete

**Tasks**:
- [ ] Add new `<section>` with `id="services"` before the footer. Use `heading centered` component with H2 "Hire Actual Trasgos" and paragraph "Need a product built, not just coded? 15+ years of product and engineering experience, powered by spec-driven development. We know what to build — not just how."
- [ ] Add Netlify Forms contact form inside the services section:
  - `<form name="contact" method="POST" data-netlify="true" netlify-honeypot="bot-field">`
  - Hidden honeypot field: `<input name="bot-field" type="hidden">`
  - Name field: `<input type="text" name="name" placeholder="Name" required maxlength="100">`
  - Email field: `<input type="email" name="email" placeholder="Email" required>`
  - Message field: `<textarea name="message" placeholder="Tell us about your project" required maxlength="2000"></textarea>`
  - Submit button: `<button type="submit" class="button primary">Send Message</button>`
  - Style form fields to match template design (use existing input/form styles or add minimal CSS)
- [ ] Add confirmation message element (hidden by default): `<div class="form-confirmation" style="display:none"><p class="paragraph m">Message received — we'll be in touch.</p></div>`
- [ ] Update `site/js/main.js`: add form submit handler that intercepts the form POST via fetch, shows the confirmation message on success, hides the form fields
- [ ] Reduce the footer: remove template link groups (Pricing, Docs, Blog, Careers). Keep copyright ("Trasgo Speckit" instead of "LoremIpsumInc") and social links. Update GitHub link to `https://github.com/trasgo-furioso/trasgo-speckit`, LinkedIn link to actual profile. Remove X/Twitter link if not needed. Add "Built with LaunchKit" attribution.

**Exit**: Use Playwright MCP to verify:
1. Section with id="services" exists
2. "Hire Actual Trasgos" heading visible
3. Pitch text contains "product" and "build"
4. Form visible with name input, email input (type="email"), message textarea, and submit button
5. Form has `data-netlify="true"` attribute
6. Footer shows copyright and GitHub/LinkedIn social links
7. (Form submission cannot be fully tested locally without Netlify — verify form structure only)

---

### Phase 7: Social & Mobile Polish
**Journey**: J8 — Link preview shows professional metadata, J9 — Mobile responsive layout

**Entry Criteria**: Phase 6 complete

**Tasks**:
- [ ] Generate `site/images/social-image.png` (1200x630): composite the banner artwork with "Trasgo Speckit — Spec-Driven Development for AI-Assisted Coding" title text overlay. Update og:image and twitter:image meta tags to point to this file with absolute URL.
- [ ] Copy `assets/banner.webp` → `site/images/banner.webp` as fallback asset
- [ ] Verify and fix mobile responsive issues: serve the site and use Playwright MCP with mobile viewport (375x812) to check all sections. Fix any layout breakage — the template's `tablet.css` and `mobile.css` handle most cases, but the convergence loop SVG and character images may need max-width constraints.
- [ ] Ensure contact form fields stack vertically on mobile and submit button is full-width
- [ ] Verify all touch targets are >= 44px on mobile (CTA buttons, form fields, nav links)

**Exit**: Use Playwright MCP to verify:
1. At desktop viewport: og:title meta tag exists and is non-empty, og:description exists, og:image exists and points to social-image.png, twitter:card is "summary_large_image"
2. At mobile viewport (375x812): page loads, scroll through all sections, no horizontal scrollbar (document.documentElement.scrollWidth <= window.innerWidth), all text readable, CTA buttons and form fields tappable

---

## BDD/TDD Cycle

This project uses a simplified BDD cycle without unit tests:

1. **Phase starts** → review the exit criteria (journey contract assertions)
2. **Build tasks** sequentially — each task modifies HTML, CSS, or JS files
3. **Phase complete** → serve the site locally and use Playwright MCP to navigate and verify all exit criteria
4. **If exit criteria fail** → fix the issues and re-verify
5. **Phase passes** → commit and move to next phase

There are no unit tests. The "tests" are Playwright MCP directions — navigate to the page, inspect elements, verify text content, check attributes, and confirm visual layout. Each phase's exit section describes exactly what to check.

## Test Conventions

- **Exit verification**: Playwright MCP navigating `http://localhost:8080` (or whichever port the local server uses)
- **Local server**: `cd site && python3 -m http.server 8080` (no build step)
- **No test files**: Exit criteria are verified interactively via Playwright MCP, not via stored test suites
- **Commit cadence**: One commit per completed phase (all exit criteria passing)

## Edge Cases and Error Scenarios

- **Images fail to load**: Verify all `<img>` src paths are correct relative to `site/index.html`. Character PNGs are large (1MB+) — consider optimizing if page load is slow.
- **SVG rendering**: The convergence loop SVG is 53KB with embedded path data. Verify it renders correctly in Safari, Chrome, and Firefox.
- **Netlify Forms detection**: Netlify detects forms at deploy time by scanning HTML for `data-netlify="true"`. The form must be present in the static HTML (not dynamically injected by JS) for Netlify to detect it.
- **OG image dimensions**: LinkedIn requires og:image to be at least 1200x627. Twitter requires minimum 300x157. The social-image.png at 1200x630 satisfies both.
- **Honeypot spam filter**: The `bot-field` hidden input must be present but invisible. If a bot fills it, Netlify rejects the submission. Do not add `display:none` to the honeypot via CSS (some bots detect that) — use a visually hidden pattern or rely on `type="hidden"`.

## Test Generation Guidelines

- When verifying with Playwright MCP, use text content assertions (check visible text) rather than implementation-specific selectors where possible
- For link verification, check both the `href` attribute value and the `target` attribute
- For image verification, check that the element is visible and has non-zero rendered dimensions
- For form verification, check that all expected input types and names are present
- Mobile viewport testing should use 375x812 (iPhone SE equivalent) as the baseline
