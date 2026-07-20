# Gazelle

Gazelle is an opinionated layer that sits between Azure and GitHub turning raw Azure subscriptions into self-service, isolated environments — landing zones.

> [!IMPORTANT]
> This is a mirror of a live Azure platform — sanitized and published automatically on every merge to main.

## How it works

An application team joins the platform, requests a landing zone, and gets back an isolated Azure subscription — ready to use, no manual configuration needed:
- Azure Policy enforces the guardrails — exceptions through a pull request.
- Every operation follows the same pattern: a pull request, a merge, done.

## How it's built

- **No fixed cost** — Every platform component is free; if it can't be, it must be consumption-based — never a flat cost.
- **No human touch** — BigBang brings the platform alive. After that, code is the only path to production — and the proof it can always be rebuilt from scratch.
- **No platform ops** — The platform grows more self-sufficient, landing zones take on more ownership, and the platform team becomes less and less necessary.
- **No unapproved resources** — The allowed list starts empty. A resource type joins the platform only after its security controls, telemetry, and integration patterns are in place — once it is, app teams can use it freely within the boundaries Azure Policy guarantees.

## Where to go next

- **Interactive graph** — click on any dot to get a helicopter view from that entry point at [gazelle.cloud](https://gazelle.cloud)
- **AI assistant** — copy `https://gazelle.cloud/llms-full.txt` into Claude or any other AI assistant.
