# Gazelle

Gazelle is an opionionated layer that sits between Azure and Github turning a raw Azure subscriptions into self-service, isolated environment - landing zones.

[!IMPORTANT]  
This is a public mirror of a live Azure platform — sanitized and published automatically on every merge to main.

## Guiding principles

- **No fixed cost** - Every platform component is free; if it can't be, it must be consumption-based — never a flat cost.

- **No human touch** - BigBang brings the platform alive. After that, code is the only path to production — and the proof it can always be rebuilt from scratch.

- **No platform ops** - The platform grows more self-sufficient, landing zones take on more ownership, and the platform team becomes less and less necessary.

- **No unapproved resources** - The allowed list starts empty. A resource type joins the platform only after its security controls, telemetry, and integration patterns are in place — once it is, app teams can use it freely within the boundaries Azure Policy guarantees.