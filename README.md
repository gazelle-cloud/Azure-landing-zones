# Gazelle

Gazelle is an opinionated layer that sits between Azure and GitHub turning raw Azure subscriptions into self-service, isolated environments — landing zones.

> [!IMPORTANT]
> This is a mirror of a live Azure platform — sanitized and published automatically on every merge to main.

## What Gazelle is for

- You're building greenfield, cloud-native Azure workloads and want a hardened baseline instead of a blank subscription.
- Your teams build it and run it — they want their own subscription and take responsibility for their workloads.
- You want a diamond-shaped platform organization — a small platform team enabling many autonomous product teams, instead of growing central ops
- You want each landing zone to be self-contained — its own subscription, network, identity, telemetry, and cost, independent of every other team's.

## Gazelle foundations

- **No fixed cost** — Every platform component is free; if it can't be, it must be consumption-based — never a flat cost.
- **No human touch** — Big Bang brings the platform alive. After that, code is the only path to production — and the proof it can always be rebuilt from scratch.
- **No platform ops** — The platform grows more self-sufficient, landing zones take on more ownership, and the platform team becomes less and less necessary.
- **No unapproved resources** — The allowed list starts empty. A resource type joins the platform only after its security controls, telemetry, and integration patterns are in place — once it is, app teams can use it freely within the boundaries Azure Policy guarantees.


## What ready looks like

An application team joins the platform, requests a landing zone, and gets back an isolated, ready-to-use Azure subscription. A landing zone arrives with a `hello-world` app — verifying that GitHub runners can reach the data plane, federated identity is working, Microsoft Graph permissions are in place, and the Azure infrastructure holds together.

## Where to go next

The knowledge graph is the platform's single source of truth — every decision, every operation, explorable by humans and queryable by AI.

- **[Platform decisions](https://gazelle.cloud/knowledge-graph/)** — discover why Gazelle is built the way it is.
- **[Platform operations](https://gazelle.cloud/operations/)** — trace the decisions that constrain each operation.
- **[Big Bang](https://gazelle.cloud/bigbang/)** — follow how the platform rebuilds itself from nothing to working state.
