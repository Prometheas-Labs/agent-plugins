# Phase 4: BDD Scenarios

Scenarios are **living + self-verifying** artifacts (see `docs/METHODOLOGY.md`). They are tied to automated tests via step definitions. When behavior changes, the scenario is updated and the test suite validates that the specification matches reality. A failing scenario means the spec and the implementation have diverged.

## Inputs

- User stories at `docs/product/features/{feature}/stories/`
- TRD at `docs/product/features/{feature}/TRD.md` (for technical context on what is feasible)

## Output Locations

**Platform-level scenarios** (surface-neutral behavioral contracts):
```
docs/product/features/{feature}/scenarios/
├── {story-or-behavior-name}.feature
└── ...
```

**Surface-specific scenarios** (bound to an interaction model):
```
apps/{surface}/docs/features/{feature}/scenarios/
├── {interaction-name}.feature
└── ...
```

**Step definitions** (test automation, always app-local):
```
apps/{surface}/tests/features/{feature}/steps/
├── {scenario-name}.steps.ts
└── ...
```

## Boundary Rule

A scenario belongs at **platform level** if its Given/When/Then language holds true regardless of surface. The words should not reference any specific input mechanism, UI widget, or device capability.

> "Given the user has not consented to analytics, When an unhandled error occurs, Then the error report contains no persistent identifier"

A scenario belongs at **app level** if its language references a surface-specific interaction model.

> "Given I am on the BreathWork session screen, When I swipe down during an active round, Then haptic feedback fires and the session pauses"

**When in doubt:** Write it at platform level. Move to app level only when the scenario cannot be expressed without surface-specific language.

## Gherkin Conventions

### File naming

Use lowercase kebab-case matching the behavior being tested:
- `consent-opted-out-error-reporting.feature`
- `session-completion-tracking.feature`
- `swipe-pause-haptics.feature` (surface-specific)

### Feature block

```gherkin
Feature: {Feature name from PRD}
  {One-line description of the behavioral contract}

  Background:
    Given {common preconditions shared across scenarios}

  Scenario: {Specific behavior being verified}
    Given {context}
    When {action}
    Then {observable outcome}
```

### Writing guidelines

- **One behavior per scenario.** A scenario tests one thing. If there are multiple Then clauses, consider whether they are really separate behaviors.
- **Use domain language, not implementation language.** "the user consents to analytics" not "setAnalyticsConsent(true) is called."
- **Avoid UI details in platform scenarios.** "the user enables analytics" not "the user taps the Enable button." UI details belong in surface-specific scenarios.
- **Acceptance criteria map to scenarios.** Each acceptance criterion from a user story should have at least one corresponding scenario.
- **Tag surface-specific scenarios.** Use `@mobile`, `@tv`, `@web` tags at the Feature or Scenario level for surface-specific files.

### Example: Platform-level scenario

```gherkin
Feature: Consent-tiered error reporting
  Error reports are always sent but detail varies by consent state.

  Scenario: Error report for opted-out user contains no identifier
    Given the user has not consented to analytics
    When an unhandled error occurs
    Then an error report is sent to the error tracking service
    And the report contains a stack trace
    And the report contains no persistent user identifier

  Scenario: Error report for opted-in user includes anonymous ID
    Given the user has consented to analytics
    When an unhandled error occurs
    Then an error report is sent to the error tracking service
    And the report contains a stack trace
    And the report contains the user's anonymous identifier
```

### Example: Surface-specific scenario

```gherkin
@mobile
Feature: Session pause via gesture
  Mobile users can pause an active session with a swipe gesture.

  Scenario: Swipe down pauses active breathing round
    Given I am on the BreathWork session screen
    And a breathing round is active
    When I swipe down
    Then the session pauses
    And haptic feedback fires
```

## Traceability

Each `.feature` file should trace back to the user stories it verifies. Include a comment at the top of the file:

```gherkin
# Traces: US-001, US-003
Feature: ...
```

This makes it possible to audit which stories have scenario coverage and which do not.

## Quality Criteria

Scenarios are ready for Phase 5 (implementation planning) when:
- Every user story acceptance criterion has at least one corresponding scenario
- Platform-level and surface-specific scenarios are filed in the correct locations
- Scenarios use domain language, not implementation language
- Each scenario tests one behavior
- Surface-specific scenarios are tagged with the surface name
