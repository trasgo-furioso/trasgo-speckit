# Trasgo Spec Kit

A [Spec Kit](https://github.com/github/spec-kit) preset that replaces the default workflow with a journey-driven, BDD/TDD pipeline. Every feature starts as a user problem, gets decomposed into testable journeys, and is implemented through red-green cycles gated by those journeys. A convergence loop ensures the deliverable matches the spec before the feature is considered done.

## The loop

```
specify  -->  plan  -->  tasks  -->  implement  -->  converge
   |            |           |            |              |
spec.md      plan.md    tasks.md     code + tests    pass? --> done
                                                      |
                                                     fail
                                                      |
                                                   tasks.md (appended)
                                                      |
                                                  implement  -->  converge  --> ...
```

The first four steps are a forward pass: define the problem, design the solution, break it into testable tasks, build it. **Converge** closes the loop. It compares the codebase against the spec, plan, and tasks, identifies gaps, and appends remaining work as new tasks to `tasks.md`. Then `implement` runs again, followed by another `converge`. The cycle repeats until converge finds nothing left to do.

This means the pipeline is not a waterfall -- it's a **spec-gated convergence loop**. You specify once, plan once, but you may implement and converge multiple times until the deliverable fully satisfies the spec.

Every step ends with a **human gate**. The agent produces the artifact, then the human reviews it before the next step begins. Nothing advances automatically -- you read the spec before planning, review the plan before generating tasks, inspect tasks before implementing, and approve the convergence result before looping or closing. The AI does the heavy lifting; you stay in control of what ships.

## How each step works

**Specify** creates `spec.md` using a Problem Requirements Document (PRD) template. It captures the pain point, affected personas, current alternatives, desired outcome, jobs to be done, and user journeys in Given/When/Then format. Every journey gets a numbered ID (J1, J2, ...) that all downstream documents reference. The command challenges vague statements -- it rejects "all users" as a persona, demands observable assertions in "then" clauses, and refuses implementation language in the spec.

**Plan** creates `plan.md` using the Repository Planning Graph (RPG) method from Microsoft Research. It separates functional decomposition (what the system does) from structural decomposition (where code lives), then connects them. Every capability feature must reference at least one journey. For each journey, it defines a **journey contract**: the test tier (API or Playwright), precondition setup, trigger action, and concrete assertion. Journey contracts are the bridge between the PRD and the test suite -- specific enough for an agent to write a test skeleton, not so detailed that they prescribe implementation.

**Tasks** creates `tasks.md` with BDD/TDD phases in dependency order. Each phase is tied to one or more journeys. The first task in every phase is always BDD: write the failing integration test from the journey contract. Subsequent tasks are TDD: each provides an input/output contract, the agent writes a failing unit test from it, implements until green, and commits. Every phase ends with a **runnable exit command** -- the actual shell command to run, not prose like "tests pass".

**Implement** executes phases sequentially. For each phase: write the failing BDD test (red), work through TDD tasks one by one (red-green-commit), then run the BDD test again. If the integration test passes, the phase is done. If not, debug the gap between passing unit tests and the failing integration test.

**Converge** assesses the current codebase against `spec.md`, `plan.md`, and `tasks.md`. It identifies unbuilt journeys, incomplete phases, and integration gaps. Any remaining work gets appended as new tasks to `tasks.md`, and the loop continues with another `implement` pass. When converge finds nothing left -- all journeys satisfied, all exit commands passing -- the feature is done.

## Install

Requires [Spec Kit](https://github.com/github/spec-kit) >= 0.15.0.

```bash
git clone https://github.com/trasgo-furioso/trasgo-speckit.git
specify bundle install ./trasgo-speckit/
```

Verify:

```bash
specify preset list  # shows trasgospec preset
```

## Commands

| Command | Invocation | What it produces |
|---------|------------|-----------------|
| Specify | `/speckit-specify <feature description>` | `spec.md` -- PRD with numbered user journeys |
| Plan | `/speckit-plan` | `plan.md` -- capability tree, journey contracts, architecture |
| Tasks | `/speckit-tasks` | `tasks.md` -- BDD/TDD phases with test contracts and exit commands |
| Implement | `/speckit-implement` | Code + tests, committed phase by phase |
| Converge | `/speckit-converge` | Gap analysis; appends remaining tasks or confirms completion |

## Templates

Three templates replace Spec Kit defaults:

**spec-template.md** -- Problem Requirements Document (PRD):
- Problem statement (pain point, who, current alternatives, desired outcome)
- Jobs to Be Done (When/Want/So format)
- User Journeys (Given/When/Then, numbered J1, J2, ...)
- Assumptions (falsifiable)
- Quality checklist (no solution language, specific personas, observable assertions)

**plan-template.md** -- Repository Planning Graph (RPG):
- Overview (problem, users, success metrics)
- Capability tree (functional decomposition, each feature linked to journeys)
- Journey contracts (tier, setup, action, assert -- one per journey)
- Structural decomposition (capabilities mapped to files and modules)
- Architecture (components, data models, tech stack, key decisions with trade-offs)
- Risks (technical, dependency, scope -- each with mitigation and fallback)

**tasks-template.md** -- BDD/TDD phases:
- Dependency chain (topological order, each module annotated with journey IDs)
- Development phases (BDD task first, TDD tasks with input/output contracts, runnable exit)
- Test strategy (frameworks, conventions, edge cases)

## Bundle contents

```
trasgo-speckit/
├── bundle.yml
├── preset/
│   ├── preset.yml
│   ├── commands/
│   │   ├── speckit.specify.md
│   │   ├── speckit.plan.md
│   │   ├── speckit.tasks.md
│   │   └── speckit.implement.md
│   └── templates/
│       ├── spec-template.md
│       ├── plan-template.md
│       └── tasks-template.md
```

## License

MIT
