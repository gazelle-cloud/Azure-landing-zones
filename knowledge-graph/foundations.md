<!-- GENERATED FROM knowledge-graph/foundations/ - DO NOT EDIT -->

# Foundations

## no-fixed-cost

Every platform component is free; if it can't be, it must be consumption-based — never a flat cost.

**Decisions:**

- application-teams-own-the-cost
- landing-zone-automation
- single-region
- platform-exemptions-automation

**Violations:**

- Platform-provisioned service with a fixed monthly cost adopted.
- Applying no-fixed-cost constraints to application team.

## no-human-touch

BigBang initializes the platform. After that, code is the only path to production — proof it can always be rebuilt from scratch.

**Decisions:**

- deployment-end-to-end
- deployment-declarative-lifecycle
- deployment-config-in-repo
- landing-zone-template
- deployment-logic-reusable-workflow
- platform-test-environment
- deployment-branch-gated-promotion
- platform-identity-azure
- platform-identity-github
- platform-break-glass

**Violations:**

- Configuration value set manually instead of sourced from the repo.
- Deployment that bypasses the branch-gated promotion flow.

## no-platform-ops

The platform grows more self-sufficient, landing zones take on more ownership, and the platform team becomes less and less necessary.

**Decisions:**

- landing-zone-platform-members
- landing-zone-lifecycle
- landing-zone-ipam
- landing-zone-diagnostic-settings
- landing-zone-vnet
- landing-zone-resource-group
- landing-zone-monitoring
- landing-zone-github-runners
- landing-zone-tags
- landing-zone-action-group
- landing-zone-identity
- job-function-scoped-roles
- platform-identity-graph
- landing-zone-repo
- landing-zone-getting-started
- landing-zone-allowed-public-ip

**Violations:**

- Platform team operating resources inside a landing zone on behalf of the application team.

## no-unapproved-resources

The allowed list starts empty. A resource type joins the platform only after its security controls, telemetry, and integration patterns are in place — once it is, app teams can use it freely within the boundaries Azure Policy guarantees.

**Decisions:**

- azure-policy-allowed-resources
- azure-native-services-only
- azure-policy-custom-definition
- azure-policy-hard-deny
- self-service-policy-exemptions
- self-service-policy-exemptions-defender-for-cloud
- azure-policy-naming-convention
- azure-policy-reference

**Violations:**

- Resource type added to the allowed list before Deny policies and diagnostic settings are wired.
