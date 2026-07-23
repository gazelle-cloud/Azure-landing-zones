# Gazelle AzurePlatform

Gazelle sets the rules and writes down why. Teams build in Azure, ship through GitHub with AI assistance — Claude always consults the rules first, drafts the change as a PR, a platform engineer reviews, and GitHub Actions deploys it.

# Knowledge Graph

`knowledge-graph/` is the authoritative source of truth. Decisions outweigh code — if they conflict, flag it to the user before proceeding.

| Directory | Path pattern | Content |
|---|---|---|
| guiding-principles | `knowledge-graph/guiding-principles/<id>.json` | Non-negotiable platform values |
| decisions | `knowledge-graph/decisions/<id>.json` | Design decisions and reasoning |
| operations | `knowledge-graph/operations/<id>.json` | Workflow definitions |
| github | `.github/workflows/<name>.yml` | GitHub Actions workflows — platform triggers, reusable templates, per-landing-zone generated workflows, and self-service flows |
| platform members | `platform-members/<AppName>.json` | One file per registered application; binds Entra ID group, GitHub repo, and billing scope |
| landing zones | `landing-zones/oases-<env>/oases-<appName>-<env>.bicepparam` | Per-landing-zone parameter file; the file an application team edits to manage their landing zone |
| platform management | `platform-management/<capability>/parameters/` | Policy definitions and assignments, custom roles, and management group hierarchy |
| visualization | [`gazelle-cloud.github.io`](https://github.com/gazelle-cloud/gazelle-cloud.github.io) | Interactive force-directed graphs of the knowledge graph, operations, and deployment workflows |

# Claude instructions

- Always consult the knowledge graph first. It is already loaded in context — cite the relevant decision(s) before reading any file.
- Never write, edit, or delete any file until the user explicitly says to proceed.
- For any task that matches a platform operation, read the relevant `knowledge-graph/operations/<id>.json` file first and follow its steps exactly. Do not explore the codebase or use intuition — the operation defines the procedure.
- Start every response with a single inline source indicator, and repeat it after every agent result before continuing: `Code [█░░░░] · knowledge [░░░░░] · ∿ [████░]` — 5 blocks each, filled proportionally. Code = number of codebase files read in this response; knowledge = number of knowledge graph nodes actively cited; ∿ = reliance on training/intuition for everything else.