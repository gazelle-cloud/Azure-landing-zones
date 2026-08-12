<!-- GENERATED FROM knowledge-graph/operations/ - DO NOT EDIT -->

# Operations

## add-automation-job

The platform recognizes a repeating operational pattern and eliminates it — no landing zone ever needs a human for that task again.

**Workflow:** platform-automation

**Decisions:**

- landing-zone-automation
- platform-exemptions-automation
- landing-zone-identity

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Read all design decisions in decisions[] to understand access, identity, and image constraints before writing any code.
2. Implement the job logic under landing-zones/automation/ — jobs must use the ARM API only; no data-plane or VNet-dependent calls.
3. Add a Dockerfile for the new image — base image must be pullable from a public registry without authentication.
4. Register the new job in landing-zones/bicep/modules/landingzone-automation.bicep following the existing job definition pattern.
5. Verify the job authenticates as the landing zone identity — no separate identity or secret.
6. Present a complete draft of all changes before implementing.

**Files:**

- `landing-zones/automation/`
- `landing-zones/bicep/modules/landingzone-automation.bicep`

## allow-resource-type

What was blocked is now validated and available to every landing zone at once.

**Workflow:** platform-Azure-Policy

**Decisions:**

- azure-policy-allowed-resources
- landing-zone-diagnostic-settings
- azure-policy-hard-deny
- job-function-scoped-roles
- self-service-policy-exemptions-defender-for-cloud
- azure-policy-custom-definition

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Read all design decisions in decisions[].
2. Add the resource type to allowedResources.json.
3. Use mcp__azure__documentation microsoft_docs_search to find the built-in diagnostic settings policy — add it to diagnosticSettings.bicepparam.
4. For each file in oases/, use mcp__azure__documentation microsoft_docs_search to find built-in policies with the required effect — add matching entries.
5. For each gap where no built-in policy provides the required effect, author a custom definition in customDefinitions/ and register it in policyDefinitions.bicepparam.
6. Check defenderForCloudExemptions.jsonc for paid-SKU recommendations specific to this resource type — add qualifying entries.
7. Check accessControl.bicepparam for custom role actions needed by this resource type.
8. Present a complete draft of all changes before implementing.

**Files:**

- `platform-management/policy/parameters/oases/`
- `platform-management/policy/parameters/diagnosticSettings.bicepparam`
- `platform-management/policy/parameters/customDefinitions/`
- `platform-management/access-control/parameters/accessControl.bicepparam`
- `landing-zones/defenderForCloudExemptions.jsonc`

## create-landing-zone

**Triggers:**

- create landing zone
- provision environment
- new environment
- add azure subscription

The platform hands over an isolated environment — from this point, the application team operates independently.

**Prerequisite:** register-platform-member

**Workflow:** requestNew-Landing-Zone

**Decisions:**

- landing-zone-lifecycle
- application-teams-own-the-cost
- landing-zone-ipam
- landing-zone-template
- deployment-branch-gated-promotion

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Confirm the application's file exists under platform-members/ — if not, the register-platform-member operation must be completed first.
2. Collect from the user: application name, environment (test or prod), management group name (oases-prod or oases-test), and budget (optional, default 100).
3. Auto-select the subscription ID: run `az account management-group subscription show-sub-under-mg --name subscription-bank --query "[0].name" -o tsv`.
4. Confirm the values with the user (including the auto-selected subscription ID), then trigger the workflow: gh workflow run requestNew-Landing-Zone.yml -f ApplicationName="{AppName}" -f Environment="{env}" -f ManagementGroupName="{mgmtGroup}" -f SubscriptionId="{subscriptionId}" -f Budget="{budget}" — this raises a pull request.
5. A platform engineer reviews and approves the pull request — approval is what triggers the automation to complete provisioning.

**Files:**

- `platform-members/`

## destroy-landing-zone

The platform reclaims what it gave — the subscription returns to the Subscription Bank.

**Workflow:** lz-flow-destroy-landing-zone

**Decisions:**

- deployment-declarative-lifecycle
- landing-zone-lifecycle
- application-teams-own-the-cost
- deployment-end-to-end

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Read all design decisions in decisions[] to understand what is being destroyed and what constraints apply.
2. Collect from the user: subscription ID of the landing zone to decommission.
3. Verify the bicepparam file exists at landing-zones/oases-prod/{app}/{env}.bicepparam and the lz workflow at .github/workflows/lz-oasis-{appName}-{env}.yml — do not proceed if either is missing.
4. Present to the user what will be permanently destroyed: deployment stack, resource groups, role assignments, budget, Defender settings. Confirm the subscription returns to the bank. Wait for explicit confirmation.
5. Trigger lz-flow-destroy-landing-zone via workflow_dispatch with the subscription ID. Do not manually delete files — the workflow resolves app name and env, creates the cleanup PR, and the merge triggers the Azure destroy sequence.

**Files:**

- `landing-zones/oases-prod/`
- `.github/workflows/`

## knowledge-candidate

**Triggers:**

- knowledge that doesn't fit the graph
- pattern across decisions
- explanatory context without a dependency

Observations worth preserving find a home without polluting the graph.

**Decisions:**

- graph
- knowledge

**Violations:**

- Creating the issue without user confirmation
- Observation that is actually a missing decision or link

**Steps:**

1. Confirm the observation does not fit as a decision, link, or violation — if it does, use update-knowledge-base instead.
2. Draft the issue title and body: title names the observation; body states the insight and references related decision IDs.
3. Present the draft to the user for confirmation.
4. Create the issue with the knowledge-candidate label: gh issue create --repo gazelle-cloud/azure-landing-zones --title "..." --body "..." --label knowledge-candidate

## register-platform-member

**Triggers:**

- register application
- new application team
- onboard team
- new team
- add application
- platform member
- join the platform

The platform registers a new application as a platform member — from this point, the application team can provision and manage its own landing zones.

**Workflow:** requestNew-Platform-Members

**Decisions:**

- landing-zone-platform-members

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Collect from the user: application name, owner email, and engineer email.
2. Confirm the values with the user, then trigger the workflow: gh workflow run requestNew-Platform-Members.yml -f ApplicationName="{AppName}" -f OwnerContact="{ownerEmail}" -f engineerContact="{engineerEmail}" — this raises a pull request that creates platform-members/{AppName}.json.
3. A platform engineer reviews and approves the pull request — approval triggers provisioning of the application repo, Entra group, billing scope, and repository variables.

**Files:**

- `platform-members/`

## update-knowledge-base

**Triggers:**

- add a decision
- update a decision
- add an operation
- update an operation
- refine reasoning
- add a link
- update knowledge graph

Every entry reduces the number of questions that need a human to answer.

**Violations:**

- writing a file before presenting a draft to the user
- adding a bidirectional link
- link note that does not answer 'how does this linked decision specifically affect or constrain this decision?'
- violation that restates the decision instead of describing a detectable breach

**Steps:**

1. Identify whether this is a new entry or an update to an existing one. For an update, read the existing file first.
2. Determine the type: decisions, or operations.
3. Draft the entry. For decisions: id matches filename; decision is a single clear statement; why explains the consequence of not following it; links are organic and unidirectional — each note answers 'how does this linked decision specifically affect or constrain this decision?'; violations are specific enough to detect in a code review; files list only files where a reviewer would look to verify the decision is respected.
4. For links: only add one if the note would change how someone implements or reviews this decision. Drop it if the relationship is obvious from context alone.
5. Present the complete draft to the user before writing any file.
6. Write the file.
7. Open a PR. CI runs static tests and LLM checks on changed decisions — the PR cannot merge until it passes.

**Files:**

- `knowledge-graph/foundations/`
- `knowledge-graph/decisions/`
- `knowledge-graph/operations/`

## update-landing-zone

**Triggers:**

- temporary policy exemption
- policy exclusion
- update budget
- cost alert

The application team reshapes their landing zone on demand — within the boundaries the parameter file defines.

**Prerequisite:** create-landing-zone

**Workflow:** lz-oasis-{appName}-{env}

**Decisions:**

- deployment-end-to-end
- deployment-declarative-lifecycle
- self-service-policy-exemptions
- azure-policy-reference

**Violations:**

- implementing before reading all decisions

**Steps:**

1. Read all design decisions in decisions[] to understand the constraints on tags, budget, and exemptions before proposing any change.
2. Verify the landing zone exists: the bicepparam file at landing-zones/oases-{env}/oases-{appName}-{env}.bicepparam and the workflow at .github/workflows/lz-oasis-{appName}-{env}.yml — do not proceed if either is missing, this is a create-landing-zone task.
3. Collect from the user the app/env to manage and which concern to change: cost, tags, or exemptions.
4. Cost: edit the single `budget` value only. Do not add actual-spend or additional thresholds — the budget drives a single Forecasted alert.
5. Tags: edit `subscriptionLevelTags` / `resourceLevelTags` keys and placement only. Keep ownerEmail and engineerEmail as readEnvironmentVariable references, never hardcoded values (landing-zone-tags, landing-zone-platform-members); keep ownerEmail at subscription level, never resource level.
6. Exemptions: ask the user whether the exemption is temporary or long-lived. Temporary -> trigger lz-flow-create-policy-exemption (8-hour expiry, break-glass, no PR record). Long-lived -> add an entry to the `exemptions` array referencing a policy-assignment-reference.json key, never a hardcoded ARM assignment id (self-service-policy-exemptions, azure-policy-reference). defenderRecommendationExemptions and diagSettingsExemption remain platform-managed booleans.
7. Present a complete draft of the bicepparam change before implementing.
8. For declarative changes (cost, tags, long-lived exemptions) open a PR; the merge triggers lz-oasis-{appName}-{env}.yml, redeploying the landing zone stack with deleteAll. No portal or out-of-band edits (end-to-end-deployment).

**Files:**

- `landing-zones/oases-prod/`
- `landing-zones/oases-test/`
- `landing-zones/managementGroup-AppName-environment.bicepparam`
- `.github/workflows/lz-flow-create-policy-exemption.yml`
