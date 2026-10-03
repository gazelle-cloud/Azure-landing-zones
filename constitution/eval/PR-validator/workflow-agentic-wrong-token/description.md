Adds a new agentic workflow that auto-labels PRs using claude -p.
The step authenticates with ANTHROPIC_API_KEY instead of CLAUDE_CODE_OAUTH_TOKEN.
Tests whether the validator includes platform-identity-claude in the regulative
layer and marks it fail, rather than silently omitting the rule because the rest
of the workflow looks structurally normal.
