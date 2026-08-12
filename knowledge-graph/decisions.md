<!-- GENERATED FROM knowledge-graph/decisions/ - DO NOT EDIT -->

# Decisions

## application-teams-own-the-cost

Every subscription an application provisions bills to that application's own invoice section.

**Why:** Without it, attribution falls back to tags — less precise, and allocation logic has to run.

**Links:**

- landing-zone-platform-members — The invoice section is created when the application joins the platform — billing has no scope before that.

**Violations:**

- Tags as primary cost attribution instead of invoice section isolation.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-new-platform-members.yml`
- `.github/workflows/template-landing-zones.yml`

## azure-native-services-only

A service can be adopted only if it is reachable through Azure Resource Manager.

**Why:** If a service isn't manageable through ARM, the platform cannot guarantee service integrity.

**Violations:**

- Service adopted with no ARM resource representation — invisible to Policy, RBAC, and diagnostics.

**Files:**

- `platform-management/policy/parameters/oases/allowedResources.json`

## azure-policy-allowed-resources

Every resource type is denied until the platform has validated its security controls, telemetry, and integration pattern.

**Why:** Without an approved list, the platform cannot guarantee that every resource follows its configuration rules.

**Links:**

- azure-policy-naming-convention — The allowed prefix is defined by the naming convention — the assignment won't be discoverable without it.
- landing-zone-diagnostic-settings — A diagnostic settings policy must exist for the type — approval without one leaves telemetry uncovered.
- job-function-scoped-roles — Some types expose non-standard RBAC actions beyond generic read — approval is incomplete without checking job-function role coverage.
- azure-policy-hard-deny — A type is approvable only once deny policies cover its misconfigurations — the allowlist assumes that coverage.
- azure-native-services-only — ARM-reachability is the prerequisite for allowlisting — types outside ARM are ineligible.
- self-service-policy-exemptions-defender-for-cloud — Defender for Cloud adds paid-SKU recommendations for some types — approval without reviewing them leaves unactionable noise on the dashboard.

**Violations:**

- Extending the allowed resources file without reviewing deny policies first.

**Files:**

- `platform-management/policy/parameters/oases/allowedResources.json`
- `platform-management/policy/bicep/oases.bicep`

## azure-policy-custom-definition

Every Deny or DeployIfNotExists gap with no built-in policy requires a custom definition.

**Why:** Without custom policies, Audit-only coverage looks like enforcement but the violation still occurs.

**Links:**

- azure-policy-naming-convention — The naming convention constrains custom definitions to Deny, DeployIfNotExists, or Modify effects — the effect determines the assignment prefix.

**Violations:**

- Resource type whitelisted with a known Deny gap and no custom definition to close it.

**Files:**

- `platform-management/policy/bicep/customPolicyDefinitions.bicep`
- `platform-management/policy/parameters/customDefinitions/policyDefinitions.bicepparam`
- `platform-management/policy/parameters/customDefinitions/*.json`

## azure-policy-hard-deny

Security controls are enforced through deny policies.

**Why:** Without deny policies, resources deploy in a non-compliant state, deviating from the security baseline.

**Links:**

- azure-policy-naming-convention — Without the naming convention's deny prefix rule, deny policy assignments have no consistent identity.
- azure-policy-custom-definition — Custom definitions provide the Deny effect where built-in policies don't — without them, deny coverage has gaps.

**Violations:**

- Azure resource with public network access enabled.
- Resource with local authentication enabled.
- Key Vault configured with Access Policies instead of RBAC.
- Resource with minimum TLS version below 1.2.
- Storage account with cross-tenant object replication enabled.

**Files:**

- `platform-management/policy/parameters/oases/*.json`
- `platform-management/policy/bicep/oases.bicep`

## azure-policy-naming-convention

Azure Policy assignment names are prefixed by effect — [deny|config|allowed] — followed by the requirement name.

**Why:** Without an effect prefix, reading an assignment name does not tell you whether it denies, configures, or allows.

**Violations:**

- Effect prefix outside deny, config, or allowed.
- Two policy names sharing their first 24 characters — both assignments resolve to one truncated name.

**Files:**

- `platform-management/policy/bicep/oases.bicep`
- `platform-management/policy/bicep/modules/assignment.bicep`

## azure-policy-reference

Policy exemptions resolve assignment IDs from a platform-generated reference.

**Why:** A hardcoded assignment ID silently breaks every exemption when the platform redeploys.

**Links:**

- azure-policy-naming-convention — The reference file is indexed by assignment name, so the name has to stay stable across redeployments.
- platform-test-environment — Test hierarchy requires its own reference file — without it, exemptions resolve the wrong assignment IDs.

**Violations:**

- Manually editing policy-assignment-reference.json.
- Exemption naming an assignment with a literal string instead of resolving it through the loaded reference.

**Files:**

- `.github/workflows/lz-flow-create-policy-exemption.yml`
- `landing-zones/*/policy-assignment-reference.json`
- `.github/utils/get-policyAssignmentsReference.ps1`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

## deployment-branch-gated-promotion

No platform change reaches production without passing through the test environment first.

**Why:** Without an enforced gate, a single push can change production infrastructure with no prior validation.

**Links:**

- platform-test-environment — Without the test environment, the promotion gate has no target to validate against.

**Violations:**

- Workflow deploying to prod from a non-main branch.

**Files:**

- `.github/workflows/platform-Azure-Policy.yml`
- `.github/workflows/platform-access-control.yml`
- `.github/workflows/platform-Management-Groups.yml`
- `.github/workflows/platform-automation.yml`

## deployment-config-in-repo

Every GitHub variable the platform uses is defined in the repo, never created ad hoc.

**Why:** BigBang destroys and recreates GitHub environments — without repo-committed variables, the platform state cannot be reproduced.

**Links:**

- landing-zone-platform-members — Member registration creates the initial repo variables — without it, landing zones have no baseline to drive from.
- platform-identity-azure — The app registration has distinct client IDs per environment — each must appear as a GitHub variable.

**Violations:**

- Bicep parameter with hardcoded tenant ID or location instead of readEnvironmentVariable().
- GitHub variable created in UI.

**Files:**

- `githubVariables.json`

## deployment-declarative-lifecycle

Within a deployment stack, what is not declared in code is deleted on the next deployment.

**Why:** Without this, resources removed from the stack's code persist in Azure — the code stops being the source of truth.

**Links:**

- platform-test-environment — 'deleteAll' in test verifies code produces the expected Azure state before promotion to prod.

**Violations:**

- Deployment Stack configured with detachAll — removed resources persist with no cleanup path.
- Resources created directly in Azure are not managed by the Deployment Stack.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-access-control.yml`
- `.github/workflows/template-Azure-Policy.yml`
- `.github/workflows/template-Management-Groups.yml`

## deployment-end-to-end

Each platform capability deploys through its own pipeline — no capability triggers another's deployment.

**Why:** Without isolation, changing one capability can trigger or break another's functionality.

**Violations:**

- Resource created or modified directly in Azure portal or CLI outside a Deployment Stack.
- Configuration value hardcoded in Bicep instead of injected from GitHub variables.

**Files:**

- `.github/workflows/platform-BigBang.yml`

## deployment-logic-reusable-workflow

Deployment logic lives in reusable workflows — each environment controls only when and with what inputs.

**Why:** Without reuse, a fix to deployment logic has to be repeated in every environment workflow.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-Azure-Policy.yml`
- `.github/workflows/template-access-control.yml`
- `.github/workflows/template-Management-Groups.yml`
- `.github/workflows/template-push-Docker-images.yml`
- `.github/workflows/template-GitHub-environment-variables.yml`
- `.github/workflows/template-calculate-vnet-address-space.yml`
- `.github/workflows/template-trigger-landingzone-workflows.yml`
- `.github/workflows/template-lz-template.yml`
- `.github/workflows/template-new-platform-members.yml`
- `.github/workflows/template-cancel-landing-zone.yml`
- `.github/workflows/template-destroy-landing-zone.yml`

## graph

A link exists only where the source is incomplete without the target — the note names the dependency.

**Why:** Without this, links accumulate from proximity — the graph shows what is related but not what depends on what.

**Violations:**

- Link added because decisions feel related, not because the source is incomplete without the target.
- Link note does not state which source behavior relies on which target constraint, fact, or output.
- Link added in both directions between two entries.

**Files:**

- `knowledge-graph/decisions/`
- `knowledge-graph/foundations/`
- `knowledge-graph/operations/`

## job-function-scoped-roles

Access is granted by job function, not by resource type — new resource types never require a new role.

**Why:** Without job-function scoping, every new allowed resource type forces team re-onboarding.

**Links:**

- landing-zone-platform-members — Joining the platform creates the Entra ID group that scopes engineer access — roles target the group.
- landing-zone-lifecycle — Reader on the 'Subscription Bank' is what allows engineers to discover subscriptions available for reuse.
- platform-break-glass — The wildcard violation holds only because break-glass names the single sanctioned exception.

**Violations:**

- Custom role with wildcard write permissions.

**Files:**

- `platform-management/access-control/parameters/accessControl.bicepparam`
- `platform-management/access-control/bicep/modules/customRoleDefinitions.bicep`

## knowledge

Each decision record states one constraint plainly.

**Why:** Without this, goal-shaped entries pass review but give no signal when the system drifts.

**Violations:**

- Decision statement that describes a goal rather than a constraint.
- Decision statement contains rationale, instead of a constraint
- Decision statement that describes a low-level implementation detail rather than a constraint.
- Multiple decisions collapsed into a single entry.
- Why field that does not describe the consequence of ignoring the decision.
- Why field that restates the decision instead of naming its consequence.
- Decision, why, violation, or note string exceeds twenty words.

**Files:**

- `knowledge-graph/decisions/`

## landing-zone-action-group

Alerts route through the landing zone's action group — never hardcoded to a person.

**Why:** Hardcoded contacts go stale — alerts fire to former members and incidents go unanswered.

**Links:**

- landing-zone-platform-members — Team contact details come from the platform member profile.

**Violations:**

- Budget alert without an action group.

**Files:**

- `landing-zones/bicep/modules/base/actionGroup.bicep`
- `landing-zones/bicep/modules/base/budget.bicep`
- `landing-zones/bicep/modules/monitor.bicep`

## landing-zone-allowed-public-ip

Data-plane operations from outside Azure must use the platform-trusted public IP.

**Why:** Without this, application teams cannot access Azure data-plane resources from their laptops.

**Links:**

- deployment-config-in-repo — There is one trusted IP because it lives in a platform variable rather than in each team's config.

**Violations:**

- Platform configuring PaaS firewall rules on behalf of the application team.

**Files:**

- `githubVariables.json`

## landing-zone-automation

Automation runs inside each landing zone's own subscription.

**Why:** Without isolation, all landing zones would share a runtime the platform has no subscription to host.

**Links:**

- platform-identity-graph — Automation jobs need to query Entra ID — Graph read permissions are what make that possible.

**Violations:**

- Automation job running from a resource outside the landing zone subscription.

**Files:**

- `landing-zones/bicep/modules/landingzone-automation.bicep`
- `landing-zones/bicep/modules/base/jobs-cron.bicep`
- `landing-zones/bicep/modules/base/managedEnvironments.bicep`

## landing-zone-diagnostic-settings

Diagnostic settings are defined by the platform — a landing zone never declares its own.

**Why:** Without a platform definition, each landing zone routes logs differently and some resources emit none.

**Links:**

- azure-native-services-only — Only ARM-reachable types can have diagnostic settings defined.
- deployment-config-in-repo — The landing zone's policy assignment points at the platform's definition by resource ID, passed in as a repo variable.
- landing-zone-automation — Resources that already exist are only fixed when the remediation job runs in the landing zone.

**Violations:**

- Resource type added to allowedResources.json without a diagnostic settings definition.

**Files:**

- `platform-management/policy/parameters/diagnosticSettings.bicepparam`
- `platform-management/policy/bicep/configDiagnosticSettings.bicep`
- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/bicep/modules/base/logAnalyticsWorkspace.bicep`

## landing-zone-getting-started

No application repo is created without deployable pipelines and modules from the template.

**Why:** Without them, teams must reverse-engineer platform patterns before they can deploy.

**Links:**

- landing-zone-repo — The application repo is what the pipelines and modules ship inside — without it there is nothing to seed.

**Violations:**

- Module template customized for a specific application instead of generic.

**Files:**

- `.github/workflows/template-new-platform-members.yml`

## landing-zone-github-runners

Every landing zone has its own private GitHub runners provisioned inside the landing zone VNet.

**Why:** Public runners have no network path to PaaS data plane once public access is denied.

**Links:**

- platform-identity-github — Runner registration requires the GitHub App — no other identity has the permissions to register runners to a repo.

**Violations:**

- Application team using a separate VNet for runner integration.
- Runner label that implies capability differences instead of network accessibility.

**Files:**

- `landing-zones/bicep/modules/base/virtualNetwork.bicep`
- `.github/utils/create-landingzone-gh-runners.ps1`
- `.github/workflows/template-landing-zones.yml`

## landing-zone-identity

Each landing zone has a single managed identity — shared across all its workflows, jobs, and service integrations.

**Why:** Without a single identity, every new capability multiplies the permission surface — RBAC and OIDC sprawl.

**Links:**

- landing-zone-repo — OIDC federation relies on the landing-zone repo and environment scope.

**Violations:**

- Managed identity shared across multiple landing zones.

**Files:**

- `landing-zones/bicep/modules/identity.bicep`
- `landing-zones/bicep/modules/base/appRoleAssignedTo.bicep`

## landing-zone-ipam

VNet address spaces are allocated by querying live Azure, not by maintaining an assignment registry.

**Why:** Without querying live state, address allocations drift and VNets cannot peer.

**Links:**

- single-region — VNet address space allocation relies on the platform-defined region.

**Violations:**

- VNet with a manually assigned address space.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-calculate-vnet-address-space.yml`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

## landing-zone-lifecycle

Landing zone provisioning draws from a subscription bank, returning the subscription to it when the landing zone is sunset.

**Why:** Azure subscription limit (MCA quota) counts cancelled subscriptions the same as active - it never frees up.

**Links:**

- application-teams-own-the-cost — Reused subscription must move to the application's invoice section before provisioning completes.

**Violations:**

- New subscription created when bank had an available empty subscription.

**Files:**

- `.github/workflows/template-landing-zones.yml`
- `.github/workflows/template-destroy-landing-zone.yml`
- `landing-zones/managementGroup-AppName-environment.bicepparam`
- `githubVariables.json`

## landing-zone-monitoring

No landing zone shares a Log Analytics workspace with another.

**Why:** A shared workspace merges ingestion costs across landing zones, which breaks the cost ownership model.

**Links:**

- application-teams-own-the-cost — Cost ownership is what requires a workspace per landing zone — a shared one would merge team bills.
- landing-zone-diagnostic-settings — Without diagnostic settings, the platform provisions a workspace but has no telemetry pipeline to fill it.

**Violations:**

- Centralized Log Analytics workspace for general purpose logs.
- Workspace retention raised beyond the period included at no charge.

**Files:**

- `landing-zones/bicep/modules/monitor.bicep`
- `landing-zones/bicep/modules/base/logAnalyticsWorkspace.bicep`
- `landing-zones/bicep/modules/base/ActivityLogAlerts.bicep`

## landing-zone-ownership

The platform owns exactly what the landing zone template declares — nothing more.

**Why:** Without a declared boundary, application teams cannot act in their own subscription without checking with the platform first.

**Links:**

- deployment-declarative-lifecycle — The ownership boundary relies on stack deletion to remove platform-declared resources when no longer defined in code.
- job-function-scoped-roles — Platform engineers are exempted from Deployment Stack deny assignments — they can modify platform-declared resources directly.

**Violations:**

- Management lock applied to a platform-owned resource preventing Deployment Stack teardown.

**Files:**

- `landing-zones/bicep/main.bicep`
- `.github/workflows/template-landing-zones.yml`

## landing-zone-platform-members

Joining the platform establishes the Entra ID group, billing scope, and GitHub repo.

**Why:** Without a platform member profile, the platform has no application to provision landing zones for.

**Links:**

- landing-zone-repo — The IDs created during platform member registration (Entra group, invoice section) live as GitHub Variables on the application repo.
- platform-identity-github — The GitHub App is used to create the application repo from the landingzone-template and seeds it with variables.

**Violations:**

- Landing zone bicepparam with hardcoded owner/engineer email instead of readEnvironmentVariable.

**Files:**

- `platform-members/template.json`
- `.github/workflows/requestNew-Platform-Members.yml`
- `.github/workflows/template-new-platform-members.yml`

## landing-zone-repo

Each application has its own GitHub repository — the single control and deployment plane for all its landing zones.

**Why:** Without a repo, the platform has no deployment mechanism and nowhere to write configuration for the application.

**Links:**

- platform-identity-github — Without the GitHub App, nothing can create the repo or seed its variables.

**Violations:**

- Bring-your-own-Repo for landing zone creation

**Files:**

- `.github/workflows/template-new-platform-members.yml`

## landing-zone-resource-group

Platform-managed landing zone resources live in a single dedicated resource group, separate from application resources.

**Why:** Without a dedicated group, platform resources mix with application resources and teams cannot tell which are theirs.

**Links:**

- landing-zone-ownership — The template decides which resources are the platform's — those are the ones that go in this resource group.

**Violations:**

- Platform resource deployed into an application-owned resource group.
- Second platform-managed resource group created in a landing zone.

**Files:**

- `landing-zones/bicep/main.bicep`

## landing-zone-tags

Tag values on every landing zone must be sourced from the platform member profile.

**Why:** Hand-typed tags drift from the member profile, so a resource stops showing who actually owns it.

**Links:**

- landing-zone-automation — Tag remediation has no runtime without the automation capability.
- landing-zone-platform-members — Engineer and owner emails come from the platform enrollment.

**Violations:**

- Introducing a tag that does not apply to all application landing zones

**Files:**

- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

## landing-zone-template

Each landing zone has its own parameter file and dedicated trigger workflow.

**Why:** Acting on one landing zone would risk triggering another team's redeployment.

**Links:**

- landing-zone-platform-members — Without the platform member profile, the bicepparam file has no initial values to populate.
- deployment-logic-reusable-workflow — Without the reusable workflow, per landing-zone triggers cannot share centralized deployment logic.
- platform-identity-azure — Without the app registration's credentials, the template cannot deploy landing zone resources.
- landing-zone-repo — Without the application repo, environment-scoped variables have no destination after provisioning.

**Violations:**

- Generated workflow name not matching lz-* prefix — breaks fan-out discovery.

**Files:**

- `landing-zones/managementGroup-AppName-environment.bicepparam`
- `.github/workflows/template-lz-template.yml`
- `.github/workflows/requestNew-Landing-Zone.yml`

## landing-zone-vnet

Each landing zone has its own isolated VNet with no connectivity to other landing zones or on-premises networks.

**Why:** A shared networking solution would introduce fixed costs, breaking the no-fixed-cost principle.

**Links:**

- azure-policy-hard-deny — Deny policies enforce PaaS firewall restrictions — without them, VNet is accessible from public endpoints.
- landing-zone-ipam — IPAM allocates the VNet's address space, defaulting to a /24.
- landing-zone-github-runners — Github runners is what requires a dedicated subnet to exist in the VNet.
- landing-zone-ownership — The stack's deny settings lock the VNet but exclude subnet actions — subnet configuration belongs to the application team.

**Violations:**

- VNet provisioned outside the landing-zone-resources stack.
- Private Link/endpoint configuration on platform managed services.

**Files:**

- `landing-zones/bicep/modules/base/virtualNetwork.bicep`

## platform-break-glass

Break-glass is used only when automation cannot execute the change.

**Why:** An unrestricted role with no usage boundary becomes the fast path, and the repository stops being the record.

**Links:**

- deployment-declarative-lifecycle — Stack deny assignments override role actions — break-glass reaches platform resources only if excluded from them.
- azure-policy-hard-deny — Policy denies apply regardless of role actions — break-glass cannot deploy an unapproved resource type.

**Violations:**

- Break-glass used for a change that a pull request could have made.

**Files:**

- `platform-management/access-control/parameters/accessControl.bicepparam`
- `platform-management/access-control/bicep/accessControl.bicep`
- `.github/workflows/template-landing-zones.yml`

## platform-exemptions-automation

Platform automation Docker images are hosted outside the landing zones.

**Why:** Without an external registry, each landing zone needs persistent image hosting — adding always-on cost before any workload exists.

**Links:**

- azure-native-services-only — GitHub Container Registry is a deliberate exception to azure-native-services-only — its cost profile outweighs the native-services preference here.

**Violations:**

- Automation job that accumulates cost for a task that could run free.

**Files:**

- `landing-zones/bicep/modules/landingzone-automation.bicep`
- `landing-zones/bicep/modules/base/jobs-cron.bicep`
- `landing-zones/bicep/modules/base/managedEnvironments.bicep`

## platform-identity-azure

The platform uses an app registration rather than a managed identity.

**Why:** The platform has no subscription to host a managed identity.

**Links:**

- platform-identity-graph — Assigning Graph roles to landing zone identities requires the app registration to hold write-level Graph permissions.

**Violations:**

- Platform app registration shared with non-platform workloads.

**Files:**

- `githubVariables.json`
- `landing-zones/bicep/modules/identity.bicep`

## platform-identity-claude

Agentic GitHub workflows authenticate via a Claude Pro OAuth token.

**Why:** Without the token, every agentic workflow requires a paid API key.

**Violations:**

- Agentic workflow step using ANTHROPIC_API_KEY instead of CLAUDE_CODE_OAUTH_TOKEN.

**Files:**

- `.github/workflows/validate-knowledge-graph.yml`

## platform-identity-github

All platform and landing zone workflows authenticate to GitHub using a single, shared GitHub App identity.

**Why:** Without a shared GitHub App, the platform has no mechanism to provision and configure application repos and environments.

**Violations:**

- GITHUB_TOKEN used to write org-level variables or trigger other workflows.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-landing-zones.yml`

## platform-identity-graph

Landing zone identities receive granular Microsoft Graph read permissions — never broad directory access.

**Why:** Without them, applications cannot resolve tenant identities — user lookup and group-based authorization fail.

**Links:**

- landing-zone-identity — The single shared identity is what makes one permission grant sufficient to cover every workload in the landing zone.

**Violations:**

- Landing zone identity granted write permissions to Microsoft Graph
- Landing zone identity granted Directory.Read.All instead of granular read permissions.

**Files:**

- `landing-zones/bicep/entra.bicep`
- `landing-zones/bicep/modules/base/appRoleAssignedTo.bicep`

## platform-test-environment

Every platform capability exists in the test environment exactly as it does in production.

**Why:** If the copy differs from production, a change that passes there can still break production.

**Links:**

- deployment-logic-reusable-workflow — Test and production stay identical because the same reusable workflows deploy both.
- deployment-end-to-end — Test is updated one capability at a time, because no capability's deployment touches another.
- platform-identity-azure — Without its own dedicated app registration, the test environment cannot authenticate to deploy platform resources.
- platform-identity-graph — Without the same Graph permissions on the test identity, Graph-dependent workflows can't be validated here.

**Violations:**

- Application landing zone created in platforms test environment.

**Files:**

- `.github/workflows/platform-Azure-Policy.yml`
- `.github/workflows/platform-access-control.yml`
- `.github/workflows/platform-Management-Groups.yml`
- `.github/workflows/platform-automation.yml`
- `.github/workflows/platform-BigBang.yml`

## self-service-policy-exemptions-defender-for-cloud

Defender for Cloud recommendations with no free remediation path must be pre-exempted by the platform.

**Why:** An unactionable recommendation left on the dashboard erodes confidence in the rest of the data.

**Links:**

- application-teams-own-the-cost — Paid-SKU recommendations impose cost on the application team's subscription, breaking the zero-cost principle.

**Violations:**

- Defender for Cloud exemption list containing a recommendation with a free remediation path.

**Files:**

- `landing-zones/defenderForCloudExemptions.jsonc`
- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/managementGroup-AppName-environment.bicepparam`

## self-service-policy-exemptions

Application teams can exempt themselves from any policy assignment via Pull Request.

**Why:** A deny policy without an exemption path gets worked around rather than enforced — teams find other routes when blocked.

**Links:**

- azure-policy-reference — Exemptions reference a JSON file to look up the policy assignment ID — never a hardcoded ARM ID.
- azure-policy-naming-convention — Self-service policy exemptions rely on predictable policy assignment names.

**Violations:**

- Exemption description that does not name the reason for the exemption.

**Files:**

- `landing-zones/bicep/modules/base/policyExemption.bicep`
- `landing-zones/bicep/modules/azurePolicy.bicep`
- `landing-zones/managementGroup-AppName-environment.bicepparam`
- `.github/workflows/lz-flow-create-policy-exemption.yml`

## single-region

All landing zones deploy to a single region — the platform owns the region decision.

**Why:** Without a single region, service parity depends on each engineer's choice rather than a platform default.

**Links:**

- deployment-config-in-repo — The region is a platform variable, not a team parameter — that is what makes the platform own it.
- landing-zone-github-runners — The region decision depends on runner VNet integration being available there.

**Violations:**

- bicepparam with hardcoded location overrides workflow-injected region.
- Platform region set to a region where GitHub runners VNet integration is unavailable.

**Files:**

- `githubVariables.json`
- `.github/workflows/template-landing-zones.yml`
