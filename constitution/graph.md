<!-- GENERATED FROM constitution/vocabulary/, constitution/foundations/, constitution/constitutive/, constitution/regulative-entity/, constitution/regulative-process/ - DO NOT EDIT -->

# Knowledge Graph

## Vocabulary

### Terms

| term |
| --- |
| gazelle |
| constitution |
| platform |
| platform-test-environment |
| oases |
| landing-zone |
| platform-member |
| eval |
| bigbang |
| guardrail |

### Relations

| relation | definition |
| --- | --- |
| governed-by | Points at a rule the process respects while it runs. |
| depends-on | The source is incomplete without the target, and the note names which target constraint the source relies on. |
| constrains | The source narrows where the target applies, and the note names what falls outside it. |

## Foundations

### no-fixed-cost

Every platform component is free; if it can't be, it must be consumption-based — never a flat cost.

**Violations:**

- Platform-provisioned service with a fixed monthly cost adopted.
- Applying no-fixed-cost constraints to application team.

### no-human-touch

BigBang initializes the platform. After that, code is the only path to production — proof it can always be rebuilt from scratch.

**Violations:**

- Configuration value set manually instead of sourced from the repo.
- Deployment that bypasses the branch-gated promotion flow.

### no-platform-ops

The platform grows more self-sufficient, landing zones take on more ownership, and the platform team becomes less and less necessary.

**Violations:**

- Platform team operating resources inside a landing zone on behalf of the application team.

### no-unapproved-resources

The allowed list starts empty. A resource type joins the platform only after its security controls, telemetry, and integration patterns are in place — once it is, app teams can use it freely within the boundaries Azure Policy guarantees.

**Violations:**

- Resource type added to the allowed list before Deny policies and diagnostic settings are wired.

## Constitutive

### bigbang

**Subject:** bigbang (entity)

platform-BigBang.yml counts as BigBang when its jobs call every workflow in properties.requiredWorkflows.

**Anchor:** no-human-touch

**Evidence:**

- `.github/workflows/platform-BigBang.yml`

**Properties:**

- requiredWorkflows: ./.github/workflows/template-GitHub-environment-variables.yml ./.github/workflows/template-Management-Groups.yml ./.github/workflows/template-access-control.yml ./.github/workflows/template-Azure-Policy.yml ./.github/workflows/template-push-Docker-images.yml ./.github/workflows/template-trigger-landingzone-workflows.yml

### constitution

**Subject:** constitution (entity)

A valid JSON file under a graph node directory counts as constitution.

**Anchor:** no-human-touch

**Evidence:**

- `constitution/foundations/*.json`
- `constitution/constitutive/*.json`
- `constitution/regulative-entity/*.json`
- `constitution/regulative-process/*.json`
- `constitution/vocabulary/*.json`

**Violations:**

- graph.md edited by hand.
- Constitutive rule depending on a regulative one.
- A constitutive criterion written or judged against anything but repository files.

### eval

**Subject:** eval (entity)

A test case counts as an eval when its expected.json matches properties.fixturePattern for one of properties.kinds.

**Anchor:** no-human-touch

**Evidence:**

- `constitution/eval/*/*/expected.json`

**Links:**

- depends-on → constitution — Each fixture names a node the constitution holds.

**Properties:**

- fixturePattern: constitution/eval/<kind>/<case>/expected.json
- kinds: PR-validator semantic

### gazelle

**Subject:** gazelle (entity)

An Azure tenant counts as Gazelle when its ID matches properties.path in properties.file.

**Anchor:** no-human-touch

**Evidence:**

- `githubVariables.json`

**Links:**

- depends-on → bigbang — BigBang builds its platform.
- depends-on → constitution — The constitution governs it.

**Properties:**

- file: githubVariables.json
- path: AzurePlatformVariables.repositoryVariables.AZURE_TENANT_ID

### guardrail

**Subject:** guardrail (entity)

An Azure Policy assignment counts as a guardrail when its module's params.policyName or params.name value is listed in properties.assignmentNames.

**Anchor:** no-unapproved-resources

**Evidence:**

- `platform-management/policy/bicep/oases.bicep`
- `landing-zones/bicep/modules/azurePolicy.bicep`

**Properties:**

- assignmentNames: allowedResources allowedLocations denyLocalAuthentication denyPublicNetworkAccess denyWeakTLS denyCrossTenantReplication config-diagnosticSettings

### landing-zone

**Subject:** landing-zone (entity)

An Azure subscription counts as a landing zone when a file matching properties.parameterFilePattern declares its subscriptionId.

**Anchor:** no-human-touch

**Evidence:**

- `landing-zones/*/oases-*.bicepparam`

**Links:**

- depends-on → platform-member — Deployed in a member's name.

**Properties:**

- parameterFilePattern: landing-zones/*/oases-*.bicepparam

### oases

**Subject:** oases (entity)

A management group counts as oases when properties.file declares it as a child of properties.parentParameter, named properties.childManagementGroupName.

**Anchor:** no-platform-ops

**Evidence:**

- `platform-management/management-groups/bicep/managementGroups.bicep`

**Links:**

- depends-on → platform — Oases is a child of the platform management group.

**Violations:**

- Test landing zones assumed to belong to the test management group hierarchy.

**Properties:**

- file: platform-management/management-groups/bicep/managementGroups.bicep
- parentParameter: topLevelManagementGroupName
- childManagementGroupName: oases-${environment}

### platform-member

**Subject:** platform-member (entity)

A product team counts as a platform member when a file matching properties.memberFilePattern, other than properties.excludedFiles, declares its application with each of properties.requiredFields.

**Anchor:** no-platform-ops

**Evidence:**

- `platform-members/<AppName>.json`

**Links:**

- depends-on → gazelle — Membership is held in Gazelle's tenant.

**Properties:**

- memberFilePattern: platform-members/<AppName>.json
- excludedFiles: platform-members/template.json
- requiredFields: applicationName ownerEmail engineerEmail

### platform-test-environment

**Subject:** platform-test-environment (entity)

A management group counts as the platform-test-environment when its name matches properties.path in properties.file.

**Anchor:** no-human-touch

**Evidence:**

- `githubVariables.json`

**Links:**

- depends-on → gazelle — Gazelle confers the status.

**Violations:**

- Test change validated against a management group other than the configured one.

**Properties:**

- file: githubVariables.json
- path: AzurePlatformVariables.environmentVariables.TOP_LEVEL_MANAGEMENT_GROUP_NAME.test

### platform

**Subject:** platform (entity)

A management group counts as the platform when its name matches properties.path in properties.file.

**Anchor:** no-human-touch

**Evidence:**

- `githubVariables.json`

**Links:**

- depends-on → gazelle — The platform carries Gazelle's authority.

**Violations:**

- Platform capability hosted in a subscription rather than assigned at a management group.

**Properties:**

- file: githubVariables.json
- path: AzurePlatformVariables.environmentVariables.TOP_LEVEL_MANAGEMENT_GROUP_NAME.prod

## Regulative - entity

### application-teams-own-the-cost

A subscription must bill to the owning application's invoice section.

**Why:** Without it, attribution falls back to tags, which is less precise and requires allocation logic to run.

**Anchor:** no-fixed-cost

**Implements:** platform-member

**Violations:**

- Cost attributed through tags rather than invoice section isolation.
- Subscription billing to a shared invoice section.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-new-platform-members.yml`
- `.github/workflows/template-landing-zones.yml`

### azure-native-services-only

Only a service reachable through Azure Resource Manager may be adopted.

**Why:** If a service isn't manageable through ARM, the platform cannot guarantee service integrity.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Service adopted with no ARM resource representation, leaving it invisible to Policy, RBAC, and diagnostics.

**Files:**

- `platform-management/policy/parameters/oases/allowedResources.json`

### azure-policy-allowed-location

Azure Policy must allow only the approved location.

**Why:** Without this, the platform cannot prove that landing-zone resources stay in the single region.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Links:**

- depends-on → deployment-config-in-repo — The approved location is a platform boundary because the repository names it in githubVariables.json.

**Violations:**

- Multi-region deployment treated as supported by the platform.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-Azure-Policy.yml`
- `platform-management/policy/bicep/oases.bicep`

### azure-policy-allowed-resources

Azure Policy must allow only the approved resource types.

**Why:** Without an allow list, the platform cannot distinguish intended resource capabilities from accidental drift before guardrails deny or exempt them.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Resource type added to the allowed-resources list for proof-of-concept use only.

**Files:**

- `platform-management/policy/parameters/oases/allowedResources.json`

### azure-policy-config-diagnostic-settings

Azure Policy must configure diagnostic settings for every allowed resource.

**Why:** Without this, the platform cannot guarantee a consistent telemetry flow from approved resources to the landing-zone workspace.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Diagnostic settings not configured by logs category group.

**Files:**

- `platform-management/policy/bicep/configDiagnosticSettings.bicep`
- `platform-management/policy/parameters/diagnosticSettings.bicepparam`

### azure-policy-custom-definition

An Azure Policy gap must be closed by a custom definition when built-in policies do not support the desired effect.

**Why:** Without that, new Azure resources can enter the platform with security gaps Azure policies do not close.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Links:**

- depends-on → azure-policy-effect-declaration — The effect a custom definition carries determines the effect its Azure Policy control must declare.

**Violations:**

- Use Audit or AuditIfNotExist mode for Azure Policies that must have more restrictive effect.

**Files:**

- `platform-management/policy/bicep/customPolicyDefinitions.bicep`
- `platform-management/policy/parameters/customDefinitions/policyDefinitions.bicepparam`
- `platform-management/policy/parameters/customDefinitions/*.json`

### azure-policy-deny-cross-tenant-data-replication

Azure Policy must deny cross-tenant data replication.

**Why:** Without this, data can leave the tenant over Microsoft's backbone without crossing a network boundary the platform can observe.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- A data replication capability is approved before the platform can prove replicated data remains inside the Gazelle tenant.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/parameters/oases/denyCrossTenantReplication.json`

### azure-policy-deny-local-authentication

Azure Policy must deny local authentication methods such as SAS tokens, access keys, or password.

**Why:** Without this, the platform cannot guarantee that authentication flows through Entra ID and Azure RBAC.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Azure resource is approved even though it lets product teams operate outside Entra ID and RBAC.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/parameters/oases/denyLocalAuthentication.json`

### azure-policy-deny-public-network

Azure Policy must deny public network access for every allowed resource.

**Why:** Without this, the platform can't guarantee that data plane access stays inside the landing zone network boundary.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Links:**

- depends-on → landing-zone-github-runners — Denying public network access relies on landing zones having private GitHub runners inside the VNet for data-plane access.

**Violations:**

- Private endpoint connectivity proposed where service endpoint access from the landing zone VNet is supported.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/parameters/oases/denyPublicNetworkAccess.json`
- `platform-management/policy/parameters/customDefinitions/*`

### azure-policy-deny-weak-tls

An approved resource must refuse clients connecting below TLS 1.2.

**Why:** Without it, traffic to approved resources can fall back to protocol versions with known breaks, exposing data in transit.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- An approved resource permits non-HTTPS transport.
- Minimum-TLS policy assigned with audit instead of deny.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/parameters/oases/denyWeakTLS.json`

### azure-policy-effect-declaration

An Azure Policy must declare exactly one effect: deny, config, or allowed.

**Why:** Without this, landing-zone users cannot tell whether a policy modifies resources on their behalf, weakening code as the source of truth.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Azure Policy name prefix does not contain approved verb.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/bicep/modules/assignment.bicep`

### azure-policy-reference

An exemption must resolve its assignment ID through the platform-generated reference file.

**Why:** A hardcoded assignment ID silently breaks every exemption when the platform redeploys.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Links:**

- depends-on → azure-policy-effect-declaration — The reference file is indexed by assignment name, so the name stays stable across redeployments.

**Violations:**

- Manually editing policy-assignment-reference.json.
- Exemption naming an assignment with a literal string instead of resolving it through the loaded reference.

**Files:**

- `.github/workflows/lz-flow-create-policy-exemption.yml`
- `landing-zones/*/policy-assignment-reference.json`
- `.github/scripts/get-policyAssignmentsReference.ps1`

### deployment-config-in-repo

Platform configuration must be defined in the repository, never set outside it.

**Why:** BigBang destroys and recreates GitHub environments, so configuration held outside the repo cannot be reproduced.

**Anchor:** no-human-touch

**Implements:** bigbang

**Violations:**

- GitHub variable created in the UI.
- Bicep parameter with a hardcoded tenant ID or location instead of readEnvironmentVariable().

**Files:**

- `githubVariables.json`

### deployment-declarative-lifecycle

A deployment stack must be configured with deleteAll, so what its code stops declaring is removed from Azure.

**Why:** Without this, resources removed from the stack's code persist in Azure and the code stops being the source of truth.

**Anchor:** no-human-touch

**Implements:** bigbang

**Violations:**

- Deployment Stack configured with detachAll, leaving removed resources with no cleanup path.
- Resource created outside the stack treated as temporary because the next pipeline run is expected to delete it.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-access-control.yml`
- `.github/workflows/template-Azure-Policy.yml`
- `.github/workflows/template-Management-Groups.yml`

### deployment-logic-reusable-workflow

Deployment logic must live in a reusable workflow; an environment workflow supplies inputs and nothing more.

**Why:** Without reuse, a fix to deployment logic has to be repeated in every environment workflow, and environments drift apart.

**Anchor:** no-human-touch

**Implements:** bigbang

**Violations:**

- Deployment steps duplicated in an environment workflow instead of called from a template.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-Azure-Policy.yml`
- `.github/workflows/template-access-control.yml`
- `.github/workflows/template-Management-Groups.yml`
- `.github/workflows/template-lz-template.yml`

### diagnostic-settings-parameter-contract

The main diagnostic initiative must define shared defaults; parameter files may override only policy-specific values.

**Why:** Without a single owner for shared defaults, diagnostic behavior can drift when parameter files repeat or replace values inconsistently.

**Anchor:** no-human-touch

**Implements:** guardrail

**Violations:**

- A shared diagnostic default is hardcoded in a parameter file instead of the main initiative.
- A parameter file passes an outer-initiative parameter that the child policy does not declare.
- A policy-specific value is omitted or overridden without review.

**Files:**

- `platform-management/policy/bicep/configDiagnosticSettings.bicep`
- `platform-management/policy/parameters/diagnosticSettings.bicepparam`

### eval-PR-validator

The PR validator must be tested against a fixed eval set at least weekly.

**Why:** An untested graph change can silently break how a rule is interpreted, and nothing would show that until a PR is wrongly passed or wrongly failed.

**Anchor:** no-human-touch

**Implements:** eval

**Links:**

- depends-on → validate-codebase-rules — The eval fixtures exercise the graph through the exact prompt validate-codebase-rules runs, so there's nothing to grade a verdict against until that process defines what one looks like.

**Violations:**

- Eval workflow not scheduled to run at least weekly.
- FAIL fixture with an empty must_fail.
- must_fail entry naming an id with no matching node in the graph.

**Files:**

- `constitution/eval/PR-validator/`
- `.github/workflows/eval-pr-validate-codebase-rules.yml`
- `.github/scripts/build-combined-eval-prompt.sh`
- `.github/scripts/check-combined-eval.sh`

### eval-semantic

A semantic eval must test a constitutive rule against its own fixture files.

**Why:** Without fixed files, the expected count drifts with the repository and a failure stops pointing at the rule.

**Anchor:** no-human-touch

**Implements:** eval

**Violations:**

- Expected count read from the live repository.
- Semantic eval run with the full graph in context.

**Files:**

- `constitution/eval/semantic/`

### functionality-named-in-graph

Functionality the codebase carries must be named by a knowledge graph node.

**Why:** Functionality the graph doesn't name is functionality the constitution can't govern, and the graph stops describing what the code actually does.

**Anchor:** no-human-touch

**Implements:** constitution

**Links:**

- depends-on → update-knowledge-base — An uncovered-functionality finding has no closure path until update-knowledge-base exists to add the missing entry.

**Violations:**

- New platform functionality merged with no corresponding graph entry.

### graph-evidence

A constitutive rule's evidence must name the exact file or pattern a check would read to test it.

**Why:** Without this a violation can sit unnoticed indefinitely.

**Anchor:** no-human-touch

**Implements:** constitution

**Violations:**

- Evidence field left empty on a published constitutive rule.
- Evidence naming a directory or general area instead of a specific file or pattern a check reads.

**Files:**

- `constitution/constitutive/*.json`

### graph-violations

A rule's violations must each describe a detectable breach distinct from the rule's own criterion.

**Why:** A violation that mirrors the rule gives no additional signal for recognizing failure in practice, it's the same check written twice, once as an obligation and once as its reflection.

**Anchor:** no-human-touch

**Implements:** constitution

**Violations:**

- A violation entry restates the rule's decision or criterion rather than naming a new failure mode.
- A violation entry describes a scenario indistinguishable from the rule passing.
- Two violation entries on the same node describe the same failure mode with different wording.

**Files:**

- `constitution/constitutive/*.json`
- `constitution/regulative-entity/*.json`
- `constitution/regulative-process/*.json`

### graph-why

A regulative rule's why must name the consequence of the rule's absence, not restate the decision or describe the rule's purpose in the abstract.

**Why:** A why that restates the decision gives no test for whether the rule is load-bearing, a rule can look justified while nothing would actually change if it were removed.

**Anchor:** no-human-touch

**Implements:** constitution

**Violations:**

- Why restates the decision instead of naming what breaks without it.
- Why describes a benefit of the rule existing rather than a failure if it didn't.
- Why is generic enough to paste onto a different node unchanged.

**Files:**

- `constitution/regulative-entity/*.json`
- `constitution/regulative-process/*.json`

### job-function-scoped-roles

A role must be scoped to a job function and assigned to the application's Entra ID group, never to an individual or a resource type.

**Why:** Without job-function scoping, every new allowed resource type forces team re-onboarding.

**Anchor:** no-platform-ops

**Implements:** platform-member

**Violations:**

- Custom role with wildcard write permissions.
- Role scoped to a resource type rather than a job function.

**Files:**

- `platform-management/access-control/parameters/accessControl.bicepparam`
- `platform-management/access-control/bicep/modules/customRoleDefinitions.bicep`

### landing-zone-action-group

Alerts must route through the landing zone's action group, addressed from the platform member profile rather than to a person.

**Why:** Hardcoded contacts go stale, so alerts fire to former members and incidents go unanswered.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Violations:**

- Budget alert without an action group.
- Action group holding a hand-typed email address.

**Files:**

- `landing-zones/bicep/modules/base/actionGroup.bicep`
- `landing-zones/bicep/modules/base/budget.bicep`
- `landing-zones/bicep/modules/monitor.bicep`

### landing-zone-allowed-public-ip

Data-plane access from outside Azure must originate from the platform-trusted public IP.

**Why:** Without a trusted source address, application teams cannot reach Azure data-plane resources from their laptops.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Links:**

- depends-on → deployment-config-in-repo — Teams read the trusted IP from a committed platform variable.

**Violations:**

- Platform configuring PaaS firewall rules on behalf of the application team.
- IP address hardcoded in an application pipeline instead of read from the platform variable.

**Files:**

- `githubVariables.json`

### landing-zone-automation

Automation jobs must run inside the landing zone's own subscription.

**Why:** Without isolation, all landing zones would share a runtime the platform has no subscription to host.

**Anchor:** no-fixed-cost

**Implements:** landing-zone

**Links:**

- depends-on → platform-identity-graph — Jobs query Entra ID, so the Graph read permissions are what make that call possible.

**Violations:**

- Automation job running from a resource outside the landing zone subscription.

**Files:**

- `landing-zones/bicep/modules/landingzone-automation.bicep`
- `landing-zones/bicep/modules/base/jobs-cron.bicep`
- `landing-zones/bicep/modules/base/managedEnvironments.bicep`

### landing-zone-getting-started

An application repo must be seeded with deployable pipelines and modules from the template at creation.

**Why:** Without them, teams reverse-engineer platform patterns before they can deploy anything.

**Anchor:** no-platform-ops

**Implements:** platform-member

**Violations:**

- Module template customized for a specific application instead of generic.
- Repo created without pipelines, leaving the team no deployment path.

**Files:**

- `.github/workflows/template-new-platform-members.yml`

### landing-zone-github-runners

A landing zone's pipelines must reach its data plane from inside the landing zone's own network.

**Why:** Public runners have no network path to the PaaS data plane once public access is denied.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Links:**

- depends-on → platform-identity-github — Runner registration needs the GitHub App, as no other identity can register runners to a repo.

**Violations:**

- Application team using a separate VNet for runner integration.
- Runner label implying capability differences instead of network accessibility.
- Pipeline enabling public network access on a resource to reach it from a GitHub-hosted runner.

**Files:**

- `landing-zones/bicep/modules/base/virtualNetwork.bicep`
- `.github/scripts/create-landingzone-gh-runners.ps1`
- `.github/workflows/template-landing-zones.yml`

### landing-zone-identity

Every workflow, job, and service integration in a landing zone must act under one shared set of permissions.

**Why:** Without one shared permission set, every new capability multiplies the permission surface through RBAC and OIDC sprawl.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Links:**

- depends-on → landing-zone-repo — OIDC federation is scoped to the landing zone repo and environment.

**Violations:**

- Managed identity shared across multiple landing zones.
- Second identity introduced for a new capability.
- Role assignment granted to a system-assigned identity of a resource inside the landing zone.

**Files:**

- `landing-zones/bicep/modules/identity.bicep`
- `landing-zones/bicep/modules/base/appRoleAssignedTo.bicep`

### landing-zone-monitoring

Telemetry a landing zone produces must be stored, queried, and billed within that landing zone.

**Why:** A shared workspace merges ingestion costs across landing zones, which breaks the cost ownership model.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Links:**

- depends-on → azure-policy-config-diagnostic-settings — The landing zone receives telemetry through platform-defined Azure Policy.

**Violations:**

- Centralized Log Analytics workspace for general purpose logs.
- Diagnostic setting in a landing zone sending logs to a workspace in another subscription.

**Files:**

- `landing-zones/bicep/modules/monitor.bicep`
- `landing-zones/bicep/modules/base/logAnalyticsWorkspace.bicep`
- `landing-zones/bicep/modules/base/ActivityLogAlerts.bicep`

### landing-zone-repo

Every landing zone must be deployed and configured from its application's repository.

**Why:** Without a repo, the platform has no deployment mechanism and nowhere to write configuration for the application.

**Anchor:** no-platform-ops

**Implements:** platform-member

**Violations:**

- Bring-your-own-repo for landing zone creation.
- Landing zone configuration held outside the application repo.

**Files:**

- `.github/workflows/template-new-platform-members.yml`

### landing-zone-resource-group

Resources the landing zone template declares must live in a single dedicated resource group.

**Why:** Without a dedicated group, resources the template declares mix with resources it does not, and a team cannot tell which of them it owns.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Violations:**

- A resource the template does not declare, deployed into the landing zone's dedicated resource group.

**Files:**

- `landing-zones/bicep/main.bicep`

### landing-zone-tags

Tag values on a landing zone must be sourced from the platform member profile.

**Why:** Hand-typed tags drift from the member profile, so a resource stops showing who actually owns it.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Links:**

- depends-on → landing-zone-automation — Tag remediation has no runtime without the automation capability.

**Violations:**

- Tag introduced that does not apply to all application landing zones.
- ownerEmail or engineerEmail hardcoded instead of read from the profile.

**Files:**

- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

### landing-zone-template

Each landing zone must have its own parameter file and its own trigger workflow.

**Why:** A shared trigger means acting on one landing zone risks redeploying another team.

**Anchor:** no-human-touch

**Implements:** landing-zone

**Links:**

- depends-on → deployment-logic-reusable-workflow — Per landing zone triggers share centralized deployment logic through the reusable workflow.
- depends-on → platform-identity-azure — The platform Azure identity's credentials are what let the template deploy landing zone resources.

**Violations:**

- Generated workflow name not matching the lz-* prefix, which breaks fan-out discovery.
- One parameter file covering more than one landing zone.

**Files:**

- `landing-zones/managementGroup-AppName-environment.bicepparam`
- `.github/workflows/template-lz-template.yml`
- `.github/workflows/requestNew-Landing-Zone.yml`

### oases-ipam

VNet address spaces must be allocated by querying live Azure, not by reading an assignment registry.

**Why:** Without querying live state, address allocations drift and VNets cannot peer.

**Anchor:** no-platform-ops

**Implements:** oases

**Violations:**

- VNet with a manually assigned address space.
- Allocation recorded in a registry file and trusted without a live check.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-calculate-vnet-address-space.yml`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

### oases-lifecycle

A landing zone must draw its subscription from the Subscription Bank, and must return it there when sunset rather than cancelling it.

**Why:** The Azure subscription limit counts cancelled subscriptions the same as active ones, so quota is not released by cancelling.

**Anchor:** no-platform-ops

**Implements:** oases

**Links:**

- depends-on → application-teams-own-the-cost — A reused subscription moves to the application's invoice section before provisioning completes.

**Violations:**

- New subscription created while the bank held an available empty one.
- Sunset subscription cancelled rather than returned to the bank.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-destroy-landing-zone.yml`
- `githubVariables.json`

### oases-placement

The platform must not restrict landing zone placement to the production environment.

**Why:** Without it, early adopters cannot test new platform features.

**Anchor:** no-platform-ops

**Implements:** oases

**Violations:**

- Placement restricted to the production management group hierarchy.

**Files:**

- `.github/workflows/requestNew-Landing-Zone.yml`

### platform-break-glass

Break-glass must be used only where automation cannot execute the change.

**Why:** An unrestricted role with no usage boundary becomes the fast path, and the repository stops being the record.

**Anchor:** no-human-touch

**Implements:** platform

**Links:**

- depends-on → deployment-declarative-lifecycle — Stack deny assignments override role actions, so break-glass reaches platform resources by being excluded from them.

**Violations:**

- Break-glass used for a change a pull request could have made.

**Files:**

- `platform-management/access-control/parameters/accessControl.bicepparam`
- `platform-management/access-control/bicep/accessControl.bicep`
- `.github/workflows/template-landing-zones.yml`

### platform-exemptions-automation

Platform automation Docker images must be hosted outside the landing zones.

**Why:** Without an external registry, each landing zone needs persistent image hosting, adding always-on cost before any workload exists.

**Anchor:** no-fixed-cost

**Implements:** platform

**Links:**

- constrains → azure-native-services-only — GitHub Container Registry sits outside ARM, so it is a dependency the platform consumes rather than a service it adopts.

**Violations:**

- Automation image pulled from a registry the platform pays to host.
- Registry provisioned inside a landing zone to host platform images.

**Files:**

- `landing-zones/bicep/modules/landingzone-automation.bicep`
- `landing-zones/bicep/modules/base/jobs-cron.bicep`

### platform-identity-azure

Platform must use an Entra ID app registration as its identity

**Why:** A managed identity needs an existing Azure resource to attach to, but BigBang's first run has none — so there is nothing to authenticate as.

**Anchor:** no-human-touch

**Implements:** platform

**Violations:**

- Platform deployment authenticates through a managed identity.
- Platform Azure identity is shared with non-platform workloads.

### platform-identity-claude

Agentic workflows must authenticate with the Claude Pro OAuth token.

**Why:** Without the token, every agentic workflow requires a paid API key.

**Anchor:** no-human-touch

**Implements:** constitution

**Violations:**

- Agentic workflow step using ANTHROPIC_API_KEY instead of CLAUDE_CODE_OAUTH_TOKEN.

### platform-identity-github

Platform and landing zone workflows must authenticate to GitHub through the platform GitHub identity.

**Why:** Without a shared GitHub App, the platform has no mechanism to provision and configure application repos and environments.

**Anchor:** no-human-touch

**Implements:** platform

**Violations:**

- GITHUB_TOKEN used to write org-level variables or trigger other workflows.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-landing-zones.yml`

### platform-identity-graph

A landing zone identity must hold granular Microsoft Graph read permissions and no broad directory access.

**Why:** Without them, applications cannot resolve tenant identities, so user lookup and group-based authorization fail.

**Anchor:** no-platform-ops

**Implements:** platform

**Links:**

- depends-on → landing-zone-identity — One shared identity per landing zone is what makes a single permission grant cover every workload in it.

**Violations:**

- Landing zone identity granted write permissions to Microsoft Graph.
- Landing zone identity granted Directory.Read.All instead of granular read permissions.

**Files:**

- `landing-zones/bicep/entra.bicep`
- `landing-zones/bicep/modules/base/appRoleAssignedTo.bicep`

### self-service-policy-exemptions-defender-for-cloud

Defender for Cloud recommendations with no free remediation path must be pre-exempted by the platform.

**Why:** An unactionable recommendation left on the dashboard erodes confidence in the rest of the data.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Defender for Cloud exemption list containing a recommendation with a free remediation path.

**Files:**

- `landing-zones/defenderForCloudExemptions.jsonc`
- `landing-zones/bicep/modules/azurePolicy.bicep`

### self-service-policy-exemptions

An exemption must be granted through a merged pull request against the landing zone's parameter file.

**Why:** A deny policy without an exemption path gets worked around rather than enforced, as teams find other routes when blocked.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Violations:**

- Exemption applied in the portal rather than through a merged pull request.
- Exemption description that does not name the reason for the exemption.

**Files:**

- `landing-zones/bicep/modules/base/policyExemption.bicep`
- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

## Regulative - process

### add-automation-job

A new automation job must run as the landing zone identity, against the ARM API, from a publicly pullable image.

**Why:** A job needing its own identity, a data-plane path, or an authenticated base image cannot run unattended in every landing zone.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Trigger:**

- add automation job
- recurring platform task
- automate remediation

**Workflow:** platform-automation

**Steps:**

1. Read the rules this process is governed by, to understand access, identity, and image constraints before writing any code.
2. Implement the job logic under landing-zones/automation/, using the ARM API alone with no data-plane or VNet-dependent calls.
3. Add a Dockerfile whose base image is pullable from a public registry without authentication.
4. Register the job in landing-zones/bicep/modules/landingzone-automation.bicep, following the existing job definition pattern.
5. Verify the job authenticates as the landing zone identity, with no separate identity or secret.
6. Present a complete draft of all changes before implementing.

**Links:**

- governed-by → landing-zone-automation
- governed-by → platform-exemptions-automation
- governed-by → landing-zone-identity

**Violations:**

- Automation job authenticating with its own secret instead of the landing zone identity.
- Job image hosted in a registry requiring authentication.

**Files:**

- `landing-zones/automation/`
- `landing-zones/bicep/modules/landingzone-automation.bicep`

### allow-resource-type

A resource type must clear deny coverage, diagnostic settings, and job-function role review before it joins the allowed list.

**Why:** A type listed ahead of its controls is available to every landing zone with nothing enforcing how it is configured.

**Anchor:** no-unapproved-resources

**Implements:** guardrail

**Trigger:**

- allow resource type
- approve resource type
- add resource to allowed list

**Workflow:** platform-Azure-Policy

**Steps:**

1. Read the rules this process is governed by.
2. Add the resource type to allowedResources.json.
3. Find the built-in diagnostic settings policy and add it to diagnosticSettings.bicepparam.
4. For each file in oases/, find built-in policies with the required effect and add matching entries.
5. For each gap where no built-in provides the required effect, author a custom definition and register it in policyDefinitions.bicepparam.
6. Check defenderForCloudExemptions.jsonc for paid-SKU recommendations specific to this resource type.
7. Check accessControl.bicepparam for custom role actions needed by this resource type.
8. Present a complete draft of all changes before implementing.

**Links:**

- governed-by → azure-policy-allowed-location
- governed-by → azure-policy-config-diagnostic-settings
- governed-by → azure-policy-deny-cross-tenant-data-replication
- governed-by → azure-policy-deny-local-authentication
- governed-by → azure-policy-deny-public-network
- governed-by → azure-policy-deny-weak-tls
- governed-by → azure-policy-custom-definition
- governed-by → self-service-policy-exemptions-defender-for-cloud
- governed-by → job-function-scoped-roles

**Violations:**

- Entry added to allowedResources.json before its deny policies were reviewed.
- Resource type listed with no diagnostic settings definition.

**Files:**

- `platform-management/policy/parameters/oases/`
- `platform-management/policy/parameters/diagnosticSettings.bicepparam`
- `platform-management/policy/parameters/customDefinitions/`

### create-landing-zone

A landing zone must be provisioned through requestNew-Landing-Zone workflow.

**Why:** Provisioning outside the workflow leaves the subscription unaccounted for in the bank and off the application invoice section.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Trigger:**

- create landing zone
- provision environment
- new environment
- add azure subscription

**Workflow:** requestNew-Landing-Zone

**Steps:**

1. Confirm the application file exists under platform-members/. If not, register-platform-member completes first.
2. Collect from the user: application name, environment (test or prod), management group name (oases-prod or oases-test), and budget (optional, default 100).
3. Auto-select the subscription ID: az account management-group subscription show-sub-under-mg --name subscription-bank --query "[0].name" -o tsv
4. Confirm the values with the user, including the auto-selected subscription ID, then trigger the workflow, which raises a pull request.
5. A platform engineer reviews and approves the pull request, and that approval triggers the automation to complete provisioning.

**Links:**

- depends-on → register-platform-member — Provisioning has no application to target until the member profile, group, and billing scope exist.
- governed-by → application-teams-own-the-cost
- governed-by → oases-ipam
- governed-by → oases-placement
- governed-by → landing-zone-template
- governed-by → deployment-branch-gated-promotion

**Violations:**

- Landing zone provisioned for an application with no platform member file.
- Subscription created new while the bank held an empty one.

**Files:**

- `platform-members/`
- `.github/workflows/requestNew-Landing-Zone.yml`

### deployment-branch-gated-promotion

A platform change must pass the test environment before it reaches production.

**Why:** Without an enforced gate, a single push can change production infrastructure with no prior validation.

**Anchor:** no-human-touch

**Implements:** platform

**Links:**

- depends-on → platform-test-environment — The gate has no target to validate against without the test environment.

**Violations:**

- Workflow deploying to prod from a non-main branch.
- Production change with no corresponding test deployment.

**Files:**

- `.github/workflows/platform-Azure-Policy.yml`
- `.github/workflows/platform-access-control.yml`
- `.github/workflows/platform-Management-Groups.yml`
- `.github/workflows/platform-automation.yml`

### destroy-landing-zone

A landing zone must be decommissioned through lz-flow-destroy-landing-zone, which returns its subscription to the bank.

**Why:** Deleting resources by hand cancels the subscription instead of returning it, and the quota is not released.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Trigger:**

- destroy landing zone
- decommission landing zone
- sunset environment

**Workflow:** lz-flow-destroy-landing-zone

**Steps:**

1. Read the rules this process is governed by, to understand what is being destroyed and what constraints apply.
2. Collect from the user: subscription ID of the landing zone to decommission.
3. Verify the bicepparam file and the lz-oasis-{appName}-{env} workflow both exist. Stop if either is missing.
4. Present what will be permanently destroyed: deployment stack, resource groups, role assignments, budget, Defender settings. Confirm the subscription returns to the bank. Wait for explicit confirmation.
5. Trigger lz-flow-destroy-landing-zone via workflow_dispatch with the subscription ID. Leave the file deletions to the workflow.

**Links:**

- governed-by → deployment-declarative-lifecycle
- governed-by → application-teams-own-the-cost

**Violations:**

- Landing zone resources deleted by hand instead of through the workflow.
- Subscription cancelled rather than returned to the bank.

**Files:**

- `landing-zones/oases-prod/`
- `.github/workflows/`

### knowledge-candidate

An observation that does not fit as a rule, a link, or a violation must be recorded as a knowledge-candidate issue rather than forced into the graph.

**Why:** Forcing an observation into a node shape produces an entry that passes review but gives no signal when the system drifts.

**Anchor:** no-human-touch

**Implements:** constitution

**Trigger:**

- knowledge that doesn't fit the graph
- pattern across decisions
- explanatory context without a dependency

**Steps:**

1. Confirm the observation does not fit as a rule, a link, or a violation. If it does, update-knowledge-base is the process instead.
2. Draft the issue title and body. The title names the observation, and the body states the insight and references related entry ids.
3. Present the draft for confirmation.
4. Create the issue with the knowledge-candidate label.

**Links:**

- depends-on → update-knowledge-base — An observation reaches this path after that process establishes it does not fit the graph as an entry.

**Violations:**

- Issue created without confirmation.
- Observation recorded as a candidate when it is actually a missing rule or link.

### register-platform-member

An application must be registered through requestNew-Platform-Members before any landing zone is provisioned for it.

**Why:** Without the profile there is no Entra ID group, invoice section, or repo for a landing zone to attach to.

**Anchor:** no-platform-ops

**Implements:** platform-member

**Trigger:**

- register application
- new application team
- onboard team
- new team
- add application
- platform member
- join the platform

**Workflow:** requestNew-Platform-Members

**Steps:**

1. Collect from the user: application name, owner email, and engineer email.
2. Confirm the values with the user, then trigger the workflow, which raises a pull request creating platform-members/{AppName}.json.
3. A platform engineer reviews and approves the pull request, and that approval provisions the application repo, Entra group, billing scope, and repository variables.

**Violations:**

- Platform member file created by hand instead of through the workflow.

**Files:**

- `platform-members/`
- `.github/workflows/requestNew-Platform-Members.yml`

### update-knowledge-base

A knowledge graph entry must be drafted and presented before any file is written.

**Why:** An entry written without review enters the graph unchallenged, and the graph is what every later change is read against.

**Anchor:** no-human-touch

**Implements:** constitution

**Trigger:**

- add a decision
- update a decision
- add an operation
- update an operation
- refine reasoning
- add a link
- update knowledge graph

**Steps:**

1. Identify whether this is a new entry or an update to an existing one. For an update, read the existing file first.
2. Determine the type: vocabulary, constitutive, or regulative. Constitutive states what counts as something; regulative states what has to happen inside that.
3. Draft the entry. The id matches the filename, the subject names a vocabulary term, the anchor names a foundation, and the why states the consequence of ignoring the rule rather than restating it.
4. For links: add one where the source is incomplete without the target, and let the note say which source behaviour relies on which target constraint, fact, or output. Drop it if the relationship is obvious from context alone.
5. For a regulative rule, name the constitutive rule it upholds in implements. Omit implements where the rule serves its foundation directly.
6. Present the complete draft before writing any file.
7. Write the file.
8. Open a pull request.

**Violations:**

- File written before a draft was presented.
- Link added in both directions between two entries.
- Violation that restates the rule instead of describing a detectable breach.
- A decision field combining two different concerns into one rule.

**Files:**

- `constitution/vocabulary/`
- `constitution/constitutive/`
- `constitution/regulative/`

### update-landing-zone

A landing zone must be reshaped by editing its parameter file and merging a pull request, which redeploys the stack.

**Why:** An out-of-band edit is removed on the next deployment, because the stack deletes what the code no longer declares.

**Anchor:** no-platform-ops

**Implements:** landing-zone

**Trigger:**

- temporary policy exemption
- policy exclusion
- update budget
- cost alert

**Workflow:** lz-oasis-{appName}-{env}

**Steps:**

1. Read the rules this process is governed by, to understand the constraints on tags, budget, and exemptions.
2. Verify the landing zone exists: the bicepparam file and the lz-oasis-{appName}-{env} workflow. If either is missing this is a create-landing-zone task.
3. Collect from the user the app and environment to manage, and which concern to change: cost, tags, or exemptions.
4. Cost: edit the single budget value. The budget drives one forecasted alert, so additional thresholds are out of scope.
5. Tags: edit subscriptionLevelTags and resourceLevelTags keys and placement. Keep ownerEmail and engineerEmail as readEnvironmentVariable references, and keep ownerEmail at subscription level.
6. Exemptions: ask whether the exemption is temporary or long-lived. Temporary triggers lz-flow-create-policy-exemption with an 8-hour expiry. Long-lived adds an entry to the exemptions array referencing a policy-assignment-reference.json key.
7. Present a complete draft of the bicepparam change before implementing.
8. Open a pull request. The merge redeploys the landing zone stack with deleteAll.

**Links:**

- depends-on → create-landing-zone — There is no parameter file to edit until the landing zone has been provisioned.
- governed-by → azure-policy-reference
- governed-by → landing-zone-tags
- governed-by → deployment-declarative-lifecycle

**Violations:**

- Budget, tag, or exemption changed in the portal instead of the parameter file.
- Exemption entry naming a literal ARM assignment ID.

**Files:**

- `landing-zones/oases-prod/`
- `landing-zones/oases-test/`
- `.github/workflows/lz-flow-create-policy-exemption.yml`

### validate-codebase-rules

Every pull request must be validated against the knowledge graph rules and checked for functionality the graph doesn't yet name, and a FAIL result must block merge.

**Why:** Without automated validation, rule violations reach the codebase unchallenged and the graph stops describing what the code actually does; without blocking merge, a FAIL carries no enforcement and is only a comment a reviewer can ignore.

**Anchor:** no-human-touch

**Implements:** constitution

**Trigger:**

- validate codebase rules
- pr rules check
- constitution validation

**Steps:**

1. On pull_request opened or synchronize, check out the repo at the PR head with full history.
2. Collect the full diff (git diff origin/<base>...HEAD) and the full content of every non-deleted changed file. Cap total injected content at 50 KB; truncate with a note beyond that.
3. Run claude -p with the diff and file contents from the repo root so CLAUDE.md context loads automatically. Ask Claude to check every rule in all three layers - foundations, constitutive, regulative - and return a verdict for every single one, including rules that do not apply.
4. Ask Claude to separately identify any functionality, capability, or resource type the diff introduces that no vocabulary, constitutive, or regulative node names - regardless of whether it violates an existing rule.
5. Ask Claude to return JSON: {"result": "PASS"|"FAIL", "summary": {"what": "...", "why": "..."}, "foundations": [...], "constitutive": [...], "regulative": [...], "uncovered": [...]}, where uncovered holds one entry per gap found, each with a description of the new functionality and the evidence (file/line) that introduced it.
6. Parse the JSON output. Render each layer as a section: failed rules listed with violation and evidence, passed rules collapsed under a details toggle. Render uncovered findings as their own section. result is FAIL if any rule in any layer has status fail or uncovered contains one or more entries, and a FAIL result must fail the workflow job so GitHub Actions visibly reports advisory findings.
7. Post the formatted findings as a pull request comment, prefixed with the what/why summary and suffixed with model, token count, and cost in EUR.
8. Configure the check as a required status check on the default branch, with no admin-bypass exemption, so a FAIL cannot be merged past.

**Links:**

- governed-by → platform-identity-claude
- governed-by → functionality-named-in-graph

**Violations:**

- graph.md included in the injected file content.

**Files:**

- `.github/workflows/pr-validate-codebase-rules.yml`
