# The Definitive Guide to Crafting a Product Vision "North Star" Document for a Multi-Surface SaaS Platform

## Purpose of This Guide

This guide provides a comprehensive, actionable methodology for creating a **Product Vision Document** — the strategic north star that aligns every team, surface, and decision across a multi-surface SaaS platform. It is designed to be used alongside qualitative research data (stakeholder interviews, pilot user interviews, needs assessments) to synthesize raw insights into a cohesive product direction.

The intended output is a single, living document that serves as the **single source of truth** for what the product aspires to become, who it serves, why it matters, and the principles that govern how it shows up across every touchpoint — web administration portals, tenant-facing web apps, mobile experiences, APIs, and surfaces not yet imagined.

---

## Part 1: Foundations — What a Product Vision Document Is (and Is Not)

### 1.1 Definition

A **Product Vision** describes the future your product aims to create. It is the reason your product exists and what success looks like in the long run. It is the story your company is working toward — one that aligns your strategy, roadmap, and daily work.

It is **not** a mission statement, a feature list, a backlog, or a set of quarterly goals.

| Concept | Role | Timeframe |
|---|---|---|
| **Vision** | The destination — the long-term positive change you want to create | 3–10 years |
| **Strategy** | How you get there — the choices and trade-offs you make | 1–3 years |
| **Roadmap** | What you'll build along the way — the tactical plan | Quarters to 1 year |
| **Backlog** | The work to be done now — prioritized tasks | Weeks to months |

A well-defined vision gives direction without prescribing every detail. It empowers teams to make decisions confidently because they know the bigger picture they're building toward.

### 1.2 Why It Matters for SaaS Platforms

For SaaS companies — especially multi-surface platforms — the product vision plays three critical roles:

1. **Guiding roadmap decisions**: Every new feature, surface, or experiment should tie back to your long-term purpose.
2. **Driving alignment**: It connects teams across functions — engineering, design, product, marketing, sales, customer success — around a shared goal.
3. **Enabling adaptability**: When markets shift, new surfaces emerge, or customer needs evolve, a clear vision helps you pivot without losing direction.

Without a vision, product teams risk building faster than they're learning — shipping features that look good in isolation but fail to create meaningful, coherent outcomes across surfaces.

### 1.3 Vision vs. Strategy vs. Roadmap

Understanding the hierarchy is essential:

**Vision → Strategy → Objectives → Initiatives → Roadmap → Backlog**

Each layer narrows the focus, ensuring everything you build supports the bigger goal. The vision document sits at the very top of this cascade.

---

## Part 2: The Anatomy of a Product Vision Document

A comprehensive Product Vision Document for a multi-surface SaaS platform should contain the following sections. Each section is described in detail below with guidance on what to include and how to derive it from stakeholder and user research.

### 2.1 Executive Vision Statement

**What it is:** A single, concise, inspiring sentence (or two) that captures the essence of the product's future — the "what" and the "why."

**Characteristics of a great vision statement:**
- **Inspiring**: Describes the positive change the product should create
- **Shared**: Unites people and creates alignment across all teams
- **Customer-centric**: Centers the user's world, not your technology
- **Concise**: Easy to understand and remember (1–2 sentences)
- **Ambitious**: Describes a big, audacious goal that might never be fully reached
- **Enduring**: Provides guidance for the next 5–10 years and is free from assumptions about specific solutions
- **Ethical**: Gives rise to a product that does not cause harm

**Template (Geoffrey Moore's Elevator Pitch):**

> **For** [target customer]
> **who** [statement of the need or opportunity],
> **the** [product name] **is a** [product category]
> **that** [key benefit, compelling reason to use].
> **Unlike** [primary competitive alternative],
> **our product** [statement of primary differentiation].

This template, introduced in *Crossing the Chasm*, is one of the most widely used frameworks for articulating product vision. It forces you to be specific about who you serve, what problem you solve, and how you're different.

**How to derive from research:** Look for the most frequently cited pain points across stakeholder and user interviews. Identify the "job to be done" that unites all user types. The vision statement should articulate what success looks like when that job is done well.

**Real-world examples for inspiration:**
- Amazon Kindle: *"Every book ever printed in any language all available in 60 seconds."*
- LinkedIn: *"Create economic opportunity for every member of the global workforce."*
- Slack: *"Make work life simpler, more pleasant, and more productive."*

### 2.2 Target Users & Customer Segments

**What it is:** A clear characterization of the people who will use the product — broken down by role, context, and relationship to the platform.

For a multi-surface SaaS platform, you must map **multiple user archetypes**, as the platform will serve fundamentally different audiences through different surfaces:

| Surface | Primary User Archetype | Relationship to Platform |
|---|---|---|
| Admin Web App | Platform operators, internal staff, super-admins | Manage, configure, monitor |
| Tenant Web App | Customer organization admins, team leads | Customize, administer their tenant space |
| Tenant End-User Web App | End users within tenant organizations | Consume core value, complete tasks |
| Mobile App(s) | Any of the above, in mobile-first contexts | On-the-go access, contextual interactions |
| API / Integrations | Developers, technical partners | Extend, integrate, automate |
| Future Surfaces | Unknown — could be voice, embedded, wearable, etc. | To be discovered |

**Guidance:**
- Be specific: You should be able to tell whether a person belongs to a segment or not.
- Use behavioral and needs-based attributes, not just demographics.
- Prioritize: Order segments by strategic importance. Not all users are equal in platform value.
- If you identify several segments, ensure they are cohesive — members share similar attributes.

**How to derive from research:** From your interview vault, extract and cluster user descriptions, roles, workflows, and contexts. Look for patterns in how different users describe their relationship to the problem space. Map these to the surfaces they would naturally gravitate toward.

### 2.3 Core Problems & User Needs

**What it is:** A prioritized articulation of the problems the product solves or the benefits it delivers, framed from the user's perspective.

**Critical principle: Needs, not features.** Frame everything as outcomes the user wants to achieve, not as things the product does.

**Framework: Jobs to Be Done (JTBD)**

The JTBD framework shifts focus from what a product *is* to why it's *used*. Users "hire" products to get jobs done. These jobs have three dimensions:

- **Functional jobs**: The practical task the user is trying to accomplish (e.g., "Schedule a league game quickly")
- **Emotional jobs**: How the user wants to feel (e.g., "Feel confident I haven't double-booked a field")
- **Social jobs**: How the user wants to be perceived (e.g., "Be seen as an organized, professional league admin")

**Desired Outcome Statements:** For each core job, articulate specific, measurable desired outcomes:

> "Minimize the time it takes to [action]"
> "Minimize the likelihood of [negative outcome]"
> "Increase the ability to [positive outcome]"

These outcome statements become the criteria against which every design decision and feature is evaluated — across all surfaces.

**How to derive from research:** From your stakeholder and pilot user interviews:
1. Identify recurring pain points and desires across all interview subjects.
2. Cluster them into themes (e.g., "scheduling friction," "communication gaps," "lack of visibility").
3. Frame each theme as a Job to Be Done.
4. Under each JTBD, list the desired outcome statements that emerged from interviews.
5. Prioritize by frequency, severity, and strategic importance.

### 2.4 Value Proposition & Differentiation

**What it is:** A clear articulation of why users would choose this product over alternatives — including the alternative of doing nothing.

**Components:**
- **Core value proposition**: The primary benefit the platform delivers, stated in user-outcome terms.
- **Key differentiators**: 3–5 aspects that set the product apart from competing offerings. These should be big, coarse-grained capabilities — not granular features.
- **Competitive context**: A brief, honest assessment of the landscape — what alternatives exist and where they fall short.

**How to derive from research:** Look for moments in interviews where users describe frustration with current solutions or workarounds. These gaps between what exists and what users need are your differentiation opportunities. Also look for "delight moments" — things users wish they had that no one offers.

### 2.5 Platform Principles (Design Tenets)

**What it is:** A set of 5–8 guiding principles that govern how the product behaves and how decisions are made across all surfaces. These are the "laws of the land" — the non-negotiable values that shape every design, engineering, and product decision.

**Why this matters for multi-surface platforms:** When your product lives on multiple surfaces (web, mobile, API, future unknowns), you cannot control every pixel and interaction from a single design spec. Instead, you need **principles** that empower autonomous teams to make consistent decisions independently.

**Format for each principle:**
- **Principle name**: A memorable, concise label
- **Statement**: One sentence that articulates the principle
- **Rationale**: Why this principle matters (can reference user research insights)
- **Implications**: What this means in practice — what you will and won't do
- **Example**: A concrete scenario showing the principle in action

**Example principles for a multi-surface SaaS platform:**

| Principle | Statement |
|---|---|
| **Surface-Agnostic Value** | The core value of the platform must be accessible regardless of which surface the user is on. No surface should be a second-class citizen. |
| **Progressive Disclosure** | Each surface should present the right level of complexity for its context. Mobile doesn't mean "less" — it means "appropriate." |
| **Coherent, Not Identical** | Experiences across surfaces should feel like they belong to the same family without being pixel-for-pixel clones. Respect each platform's native patterns. |
| **Tenant Autonomy** | Tenant organizations should be able to customize their experience within well-defined guardrails, without requiring platform-level intervention. |
| **API-First Thinking** | Every capability should be built as a service first, with surfaces as consumers. This ensures extensibility and future-proofs for surfaces we haven't imagined. |
| **Data Flows, Users Don't Repeat** | If a user enters data on one surface, it should be available on every other surface. No re-entry, no sync gaps. |

**How to derive from research:** Principles emerge from the *tensions* in your research data. When users express conflicting needs (e.g., "I want power" vs. "I want simplicity"), a principle resolves the tension (e.g., "Progressive Disclosure"). Look for repeated frustrations that point to systemic values the product must uphold.

### 2.6 Experience Vision by Surface

**What it is:** A narrative description of the ideal experience on each known surface, written from the user's perspective. This is where you paint a picture of what the product *feels like* to use.

**Format:** For each surface, write a brief (1–2 paragraph) narrative that describes a day-in-the-life scenario. What does the user do? How does the product help? What's the emotional arc?

**Surfaces to cover:**

**Admin Web App**
- Who uses it and in what context
- What the experience optimizes for (efficiency, oversight, control)
- Key workflows and their emotional qualities

**Tenant Customer Web App**
- Who uses it and in what context
- What the experience optimizes for (self-service, customization, team management)
- Key workflows and their emotional qualities

**Mobile App(s)**
- Who uses it and in what context
- What the experience optimizes for (speed, contextual relevance, on-the-go tasks)
- How it complements rather than duplicates the web experience

**API / Developer Experience**
- Who uses it and in what context
- What the experience optimizes for (clarity, predictability, extensibility)
- How it enables the ecosystem to grow beyond what the core team builds

**Future / Unknown Surfaces**
- A brief statement acknowledging that new surfaces will emerge
- How the platform architecture and principles ensure readiness

**How to derive from research:** From your interviews, extract workflow descriptions and "day-in-the-life" narratives. Note which tasks users perform on which devices and in which contexts. Map these to surfaces and write the aspirational version of those workflows.

### 2.7 Multi-Surface Design Philosophy

**What it is:** The overarching design strategy that ensures coherence, consistency, and quality across every surface the platform touches.

**Key concepts to address:**

**Cross-Platform Consistency**
Users who interact with your product on mobile, tablet, and desktop should find a cohesive experience that doesn't require relearning. This is not just about aesthetics — it's about maintaining functional consistency (similar navigation, features, interactions) while optimizing for each platform's unique characteristics.

**Design System as Single Source of Truth**
A design system consolidates rules, patterns, and visual standards into one reliable reference. It should include:
- **Visual design standards**: Color palettes, typography, iconography
- **Component library**: Modular, reusable UI elements with defined behaviors
- **Design principles**: Core guidelines governing interaction and UX
- **Design tokens**: Named properties that define visual design attributes (colors, spacing, typography) as platform-agnostic variables that can be consumed by any surface
- **Implementation documentation**: Technical specs for developers
- **Governance model**: Process for evolving and maintaining the system

**Atomic Design Methodology**
Structure your UI building blocks hierarchically:
- **Design Tokens** (subatomic): The raw values — colors, spacing, type scales — abstracted into named variables
- **Atoms**: Basic elements — buttons, inputs, labels
- **Molecules**: Simple combinations — a search bar (input + button + label)
- **Organisms**: Complex sections — a complete navigation header
- **Templates**: Page-level layout structures
- **Pages**: Specific instances with real content

This modular approach ensures components are reusable across surfaces while maintaining consistency through shared tokens.

**Surface-Specific Adaptation**
While the design system provides a shared foundation, each surface should respect platform-native conventions:
- Web apps can leverage hover states, keyboard shortcuts, and spacious layouts
- Mobile apps should use native gesture patterns, bottom navigation, and condensed layouts
- APIs should follow RESTful or GraphQL conventions with clear documentation

### 2.8 Platform Architecture Vision

**What it is:** A high-level description of the technical philosophy that enables the multi-surface, multi-tenant platform — written for a product audience, not a deeply technical one.

**Key architectural tenets to address:**

**Multi-Tenancy Model**
Describe the tenant isolation philosophy:
- How tenant data is separated and secured
- How tenant customization is supported (branding, configuration, feature flags)
- How different tenant tiers may receive different levels of isolation or features

**API-First / Service-Oriented Design**
- Core capabilities are exposed as services that any surface can consume
- Internal and external consumers use the same APIs ("dogfooding")
- This enables the ecosystem to grow beyond what the core team builds

**Platform Thinking Layers**
Describe the platform in terms of strategic layers:
1. **Base Layer**: Foundational data models, infrastructure, identity, and core business logic
2. **Extensibility Layer**: APIs, SDKs, webhooks, and integration points
3. **Value Creation Layer**: How different participants (internal teams, tenants, partners) create value on the platform
4. **Governance Layer**: Rules, standards, and policies that maintain platform integrity

**Future-Proofing**
- Modular architecture that allows new surfaces to be added without re-architecting
- Feature flags and configuration systems that allow per-tenant and per-surface customization
- Event-driven patterns that decouple surfaces from core logic

### 2.9 Success Metrics & North Star Metric

**What it is:** The measurable indicators that tell you whether you're moving toward your vision.

**North Star Metric**
Identify one primary metric that reflects the core value your product delivers to users. This metric should:
- Express the value your product delivers to customers
- Connect directly to your product vision and strategy
- Serve as a leading indicator of future business success (not a lagging indicator like revenue)
- Be actionable — your team can influence it through product decisions

**Supporting Input Metrics**
Identify 3–5 complementary metrics that directly influence the North Star Metric. These should be:
- Descriptive of distinct, important dimensions of product health
- Practically actionable by your product teams
- Leading indicators, not lagging ones

**Vision Alignment Metrics**
Beyond product analytics, track:
- **Strategic alignment**: What percentage of initiatives tie back to the vision?
- **Internal awareness**: Do teams recall and understand the vision?
- **Decision speed**: Are product decisions faster because of clear direction?
- **Customer outcomes**: Are users achieving the results your vision promises?

**How to derive from research:** From your interviews, identify the outcomes users most consistently describe as "success." These become the foundation for your North Star Metric. The things they describe as barriers or frustrations point to input metrics you need to move.

### 2.10 Business Goals & Constraints

**What it is:** The company's reasons for investing in this product, stated as desired business outcomes — not features.

**Include:**
- Revenue targets or models (subscription tiers, usage-based, etc.)
- Market positioning goals
- Growth targets (users, tenants, surfaces)
- Known constraints (budget, timeline, regulatory, technical debt)
- Competitive pressures that shape urgency or priorities

**Keep this section honest and grounded.** The vision document should inspire, but it should also acknowledge reality.

### 2.11 Open Questions & Assumptions

**What it is:** An explicit inventory of what you don't yet know and what you're assuming to be true. This is one of the most valuable sections of the document — it shows intellectual honesty and creates a built-in research agenda.

**Format:**
- **Assumption**: What we believe to be true based on current evidence
- **Confidence level**: High / Medium / Low
- **Validation plan**: How we intend to test this assumption
- **Risk if wrong**: What happens if this assumption is incorrect

**How to derive from research:** From your interviews, note areas where stakeholders disagreed, where users expressed uncertainty, or where you noticed gaps in the data. These are your open questions.

---

## Part 3: The Process — How to Build the Vision Document

### 3.1 Phase 1: Research Synthesis

Before writing a single word of the vision document, synthesize your existing research.

**Thematic Analysis Process:**
1. **Tag and code** your interview data — mark each observation with relevant codes (e.g., "scheduling pain," "mobile need," "trust concern")
2. **Cluster codes into themes** — group related codes into higher-level themes
3. **Name your themes** — give each cluster a concise, descriptive name (e.g., "Distrust in Automated Suggestions," "Friction in Team Collaboration")
4. **Prioritize themes** — rank by frequency, severity, and strategic importance
5. **Extract key quotes** — pull 2–3 powerful verbatim quotes per theme to anchor your vision in real voices

**Output:** A research synthesis document that becomes an input to the vision document. Key themes become the foundation for Sections 2.3 (Problems & Needs) and 2.5 (Principles).

### 3.2 Phase 2: Vision Framing Workshop

Conduct a collaborative workshop with key stakeholders (founders, product leads, design leads, engineering leads) to align on the vision's core elements.

**Workshop Agenda:**
1. **Share research synthesis** — Present top themes, quotes, and insights (30 min)
2. **Vision statement drafting** — Use the Geoffrey Moore template as a starting point; generate 3–5 candidate statements (30 min)
3. **Principles brainstorm** — Identify the tensions in the research and articulate principles that resolve them (30 min)
4. **Surface mapping** — Map user needs to surfaces; identify where each need is best served (30 min)
5. **North Star Metric discussion** — What single metric best captures our delivered value? (20 min)
6. **Dot-vote and converge** — Narrow options for vision statement, principles, and metric (20 min)

### 3.3 Phase 3: Draft and Iterate

1. **Draft the full document** using the anatomy in Part 2 as your outline
2. **Circulate for async feedback** — share with stakeholders for written comments
3. **Conduct a "red team" review** — assign someone to argue against the vision, find holes, and stress-test assumptions
4. **Iterate** — incorporate feedback, tighten language, resolve conflicts
5. **Ratify** — get explicit sign-off from decision-makers

### 3.4 Phase 4: Communicate and Embed

A vision only creates value when it's known, understood, and used.

**Embedding strategies:**
- Begin all-hands meetings by revisiting the vision
- Integrate it into onboarding and team documentation
- Align OKRs and roadmap themes to the vision
- Use storytelling to show real examples of the vision in action
- Make it the first page of every product spec and design brief
- Reference it in retrospectives: "Did this sprint's work move us toward our north star?"

---

## Part 4: Multi-Surface Platform Considerations

This section addresses the unique challenges of crafting a vision for a product that lives across multiple surfaces.

### 4.1 Platform Thinking Mindset

A platform is not just a product with multiple interfaces — it's a foundation upon which value can be created by your team, tenants, partners, and even users. Shift your thinking from a linear value model (you build → you sell → they use) to a multi-sided value network.

**Platform Thinking Maturity Model:**

| Stage | Description | Value Creation |
|---|---|---|
| **Feature-Focused Product** | Fixed functionality serving specific use cases | Exclusively by product team |
| **Extensible Product** | Core functionality + integration capabilities + limited APIs | Mostly product team, some user configuration |
| **Product Platform** | Robust API layer, developer tools, marketplace | Product team + developers/partners |
| **Ecosystem Platform** | Self-sustaining ecosystem with network effects | All participants contribute value |

Your vision document should explicitly state which stage you're at now and which stage you're targeting within the vision's time horizon.

### 4.2 The Multi-Surface Design Challenge

Users will traverse your platform across multiple surfaces — sometimes in sequence (start on desktop, continue on mobile), sometimes in parallel (check mobile notification while working in the admin app). The vision must account for this reality.

**Key principles for multi-surface design:**

- **Continuity**: Tasks started on one surface should be resumable on another without friction
- **Context-awareness**: Each surface should present information and actions appropriate to its context (location, device capabilities, user intent)
- **Consistent mental model**: Users should build one mental model of the system, not learn separate models per surface
- **Progressive capability**: Surfaces can offer different feature breadth, but the core value must be accessible everywhere
- **Graceful degradation**: If a surface has limitations, the experience should degrade gracefully, not break

### 4.3 Tenant Experience Considerations

In a multi-tenant SaaS platform, tenants are both users and customers. The vision must address:

- **Tenant onboarding**: The first experience for a new tenant admin — smooth, guided, confidence-building
- **Tenant customization**: What tenants can brand, configure, and control within guardrails
- **Tenant isolation**: How tenants are assured their data and experience is private and secure
- **Tenant tiers**: How different pricing tiers may unlock different capabilities or levels of service
- **Tenant lifecycle**: How the product supports tenants from trial through growth to renewal

### 4.4 Future-Proofing for Unknown Surfaces

Your vision document should explicitly acknowledge that new surfaces will emerge that you cannot predict today. The way to prepare is not to guess what those surfaces will be, but to build architectural and design principles that accommodate them:

- API-first design ensures any new surface can consume platform capabilities
- Design tokens ensure visual identity can be projected onto any rendering context
- Principles (not prescriptions) empower future teams to make contextually appropriate decisions
- Modular architecture means new surfaces don't require rearchitecting the core

---

## Part 5: Using This Document with NotebookLM

This guide is designed to serve as a **companion source** in a NotebookLM notebook alongside your stakeholder and pilot user interview vault.

### 5.1 Recommended Notebook Structure

Create a NotebookLM notebook with the following source categories:

1. **This guide** — as the methodological framework and structural template
2. **Interview transcripts / summaries** — your stakeholder and pilot user interviews
3. **Competitive analysis** — if available, documents analyzing alternatives
4. **Market research** — relevant industry data and trend reports
5. **Technical context** — any existing architecture documents or technical constraints

### 5.2 Suggested Prompts for NotebookLM

Once your sources are loaded, use these prompts to leverage NotebookLM's grounded synthesis:

**For Research Synthesis:**
- "Across all interview sources, what are the top 10 most frequently mentioned pain points? Cite specific interviews."
- "What are the main Jobs to Be Done that emerge from the user interviews? Frame each as a job statement."
- "Where do stakeholders disagree about product priorities? List the areas of misalignment with evidence."
- "What desired outcomes do pilot users describe when talking about what success looks like?"

**For Vision Drafting:**
- "Using the Geoffrey Moore elevator pitch template from the guide, draft 3 candidate vision statements based on the interview data."
- "Based on the interview themes, suggest 6 platform design principles following the format described in the guide."
- "Map the user needs from interviews to the surface types described in the guide (admin web, tenant web, mobile, API)."

**For Validation:**
- "What assumptions in the interview data have low confidence and should be validated? Format as the assumption table from the guide."
- "Are there any user needs expressed in interviews that contradict each other? How might a design principle resolve the tension?"

**For Completeness:**
- "Using the Product Vision Document anatomy in the guide, which sections have strong supporting evidence from interviews and which have gaps?"
- "Generate a briefing document summarizing the key themes that should inform the product vision."

### 5.3 Iterative Refinement Loop

The power of combining this guide with NotebookLM is the ability to iterate:

1. **Synthesize** → Use NotebookLM to extract themes from interviews
2. **Draft** → Use those themes to draft each section of the vision document
3. **Validate** → Ask NotebookLM to cross-reference your draft against the raw interview data
4. **Refine** → Update the draft based on gaps or contradictions
5. **Export** → Copy the refined vision document out of NotebookLM for team review and ratification

---

## Part 6: Anti-Patterns — What to Avoid

### 6.1 Common Vision Document Pitfalls

| Anti-Pattern | Why It Fails | What to Do Instead |
|---|---|---|
| **Too vague** ("Be the best platform") | Can't guide decisions; means nothing specific | Ground in a specific user transformation |
| **Feature-driven** ("Build AI scheduling") | Locks you into solutions; ignores evolving needs | Center on outcomes, not implementations |
| **Never revisited** | Becomes irrelevant as market shifts | Schedule vision retrospectives every 6–12 months |
| **No metrics** | Can't tell if you're making progress | Tie vision to a North Star Metric and input metrics |
| **Leadership doesn't reinforce** | Fades from daily consciousness | Make vision communication a leadership ritual |
| **Overcomplicated** | Too long to read, too complex to remember | Keep the core statement to 1–2 sentences; details live in supporting sections |
| **Surface-unaware** | Treats all surfaces the same; fails to account for context | Explicitly address each surface's unique role and experience |
| **Technology-driven** | Focuses on architecture over user value | Lead with user outcomes; let architecture follow |

### 6.2 Multi-Surface-Specific Anti-Patterns

- **Desktop-first bias**: Designing the web app first and "shrinking" it for mobile. Instead, define the core value independently and express it appropriately per surface.
- **Surface silos**: Different teams owning different surfaces with no shared principles. Instead, establish shared design principles and a unified design system.
- **API as afterthought**: Building the UI first and extracting an API later. Instead, build API-first so every surface is a consumer of the same services.
- **Ignoring transitions**: Assuming users stay on one surface. Instead, design for the seams — the moments users move between surfaces.

---

## Part 7: Templates and Worksheets

### 7.1 Vision Statement Worksheet

Complete each line, then synthesize into 1–2 sentences:

```text
FOR: _______________________________________________
     [Describe your target users in specific, behavioral terms]

WHO: _______________________________________________
     [Describe the core problem or unmet need they face]

THE: _______________________________________________ IS A _______________________________________________
     [Product name]                                       [Product category]

THAT: _______________________________________________
      [Key benefit — stated as a user outcome, not a feature]

UNLIKE: _______________________________________________
        [Primary alternative — could be a competitor or the status quo]

OUR PRODUCT: _______________________________________________
             [Statement of primary differentiation]
```

### 7.2 Product Vision Board (Roman Pichler Model)

| Section | Prompt | Your Answer |
|---|---|---|
| **Vision** | What is the reason for creating the product? What positive change should it create? | |
| **Target Group** | Which market segment does the product address? Who are the target customers and users? | |
| **Needs** | What problem does the product solve or which benefit does it offer? Prioritize. | |
| **Product** | What kind of product is it? What are its 3–5 standout features? Is it feasible? | |
| **Business Goals** | What are the desired business benefits? (Revenue, brand equity, cost savings, etc.) | |

### 7.3 Platform Principle Template

For each principle (aim for 5–8):

```text
PRINCIPLE NAME: _______________________________________________

STATEMENT: _______________________________________________
           [One sentence articulating the principle]

RATIONALE: _______________________________________________
           [Why this principle matters — reference user research if possible]

IMPLICATIONS:
  - WE WILL: _______________________________________________
  - WE WON'T: _______________________________________________

EXAMPLE SCENARIO: _______________________________________________
                  [A concrete situation showing the principle in action]
```

### 7.4 Surface Experience Brief Template

For each surface:

```text
SURFACE: _______________________________________________

PRIMARY USER(S): _______________________________________________

CONTEXT OF USE: _______________________________________________
                [When, where, and why they're on this surface]

OPTIMIZES FOR: _______________________________________________
               [The 2–3 qualities this surface prioritizes]

EXPERIENCE NARRATIVE:
[Write a 1–2 paragraph day-in-the-life scenario from the user's perspective]

KEY WORKFLOWS:
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

RELATIONSHIP TO OTHER SURFACES:
[How does this surface complement or hand off to other surfaces?]
```

### 7.5 Assumption Inventory Template

| # | Assumption | Confidence | Evidence Source | Validation Plan | Risk if Wrong |
|---|---|---|---|---|---|
| 1 | | High / Med / Low | | | |
| 2 | | High / Med / Low | | | |
| 3 | | High / Med / Low | | | |

### 7.6 North Star Metric Definition Template

```text
NORTH STAR METRIC: _______________________________________________

DEFINITION: _______________________________________________
            [Precise, measurable definition]

WHY THIS METRIC:
  - Expresses value delivered to users because: _______________
  - Connects to vision because: _______________
  - Is a leading indicator because: _______________

INPUT METRICS:
1. _______________________________________________ [Dimension it captures]
2. _______________________________________________ [Dimension it captures]
3. _______________________________________________ [Dimension it captures]

REVIEW CADENCE: _______________________________________________
```

---

## Part 8: Vision Document Maturity Model

Use this model to assess where your vision stands and what to work on next.

| Stage | Name | Description | Signs You're Here |
|---|---|---|---|
| 1 | **Declared** | A vision exists but isn't widely known | Leadership can state it; most team members cannot |
| 2 | **Cascaded** | Teams understand it but don't use it in decision-making | People know the vision; decisions aren't filtered through it |
| 3 | **Operationalized** | Vision connects to OKRs, metrics, and priorities | Teams reference the vision in planning; roadmap items trace to it |
| 4 | **Transformational** | Vision drives innovation and shapes company identity | The vision attracts talent, guides strategy pivots, and defines the brand |

The goal is to reach Stage 3 as quickly as possible, and to cultivate Stage 4 over time. The higher your maturity, the more your team acts with clarity and consistency.

---

## Appendix A: Recommended Reading & Frameworks Referenced

- **Crossing the Chasm** by Geoffrey Moore — Elevator Pitch / Vision Statement template
- **Working Backwards** by Colin Bryar & Bill Carr — Amazon's customer-obsessed product development process and PR/FAQ methodology
- **Inspired** by Marty Cagan — Product vision and product discovery practices
- **Atomic Design** by Brad Frost — Methodology for building hierarchical, component-based design systems
- **Jobs to Be Done** by Anthony Ulwick — Outcome-Driven Innovation framework for understanding customer needs
- **The Product Vision Board** by Roman Pichler — Lightweight canvas for capturing vision and strategy
- **North Star Framework** by Amplitude — Methodology for identifying and organizing around a single key metric

## Appendix B: Glossary

| Term | Definition |
|---|---|
| **North Star Metric** | The single metric that best captures the core value your product delivers to users |
| **JTBD (Jobs to Be Done)** | A framework that defines markets and customer needs around the "jobs" people are trying to get done |
| **Design Token** | A named, platform-agnostic variable that stores a design decision (color, spacing, type size) |
| **Multi-Tenancy** | An architecture where a single instance of software serves multiple tenant organizations |
| **Surface** | Any interface through which a user interacts with the platform (web app, mobile app, API, etc.) |
| **Tenant** | A customer organization that operates within the platform's multi-tenant environment |
| **Design System** | A comprehensive set of standards, documentation, and reusable components that unify product design |
| **Platform Thinking** | A strategic approach that views a product as a foundation for value creation by multiple participants |
| **OKR** | Objectives and Key Results — a goal-setting framework connecting aspirational objectives to measurable results |
| **PR/FAQ** | Amazon's "Press Release / Frequently Asked Questions" — a narrative document written as if the product has already launched |

---

*This guide is a living document. Revisit and refine it as your understanding of users, market, and platform capabilities deepens.*
