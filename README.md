# skills

Personal [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) shared by every pjb0811 repository. This repository is the source of truth; `~/.claude/skills/<name>` links here.

## Skills

| Skill | Use it for |
| --- | --- |
| [`commit`](commit/SKILL.md) | Drafting a conventional commit message from the staged diff, then committing |
| [`pr`](pr/SKILL.md) | Writing and opening a pull request (Summary / Changes / How to test) |
| [`issue`](issue/SKILL.md) | Filing a GitHub issue that follows the repository's templates |
| [`ref-verification`](ref-verification/SKILL.md) | Reading repository state from git refs instead of a possibly stale worktree |
| [`coding-style`](coding-style/SKILL.md) | Following a repository's conventions, bulk renames, comments, boolean names, braces, subcomponent file layout, blank lines, order of code inside a component, feature subfolders |
| [`changesets-release`](changesets-release/SKILL.md) | The changesets release flow, npm publish checks, approving `action_required` runs |
| [`publish-check`](publish-check/SKILL.md) | Pre-release checks for an npm package: publish status, type check, build, version, `exports` vs entries |
| [`shared-library-first`](shared-library-first/SKILL.md) | Building reusable UI in `ui-kit` and hooks in `use-hooks` before using them in an app |
| [`repo-settings`](repo-settings/SKILL.md) | Checking and aligning a repository's GitHub settings: squash-only merges, auto-merge, the default-branch ruleset |

Repository-specific skills stay in their repositories, for example `version-management`, which records a repository's package path and whether it publishes to npm.

## Install

```bash
git clone https://github.com/pjb0811/skills.git ~/github/skills
~/github/skills/install.sh
```

`install.sh` links each skill directory into `~/.claude/skills` (override with `CLAUDE_SKILLS_DIR`) and [`global/CLAUDE.md`](global/CLAUDE.md) to `~/.claude/CLAUDE.md` (override with `CLAUDE_MD_PATH`). An existing directory or file with the same name is moved to `~/.claude/skills-backup/<timestamp>/` first, outside the skills directory so it isn't loaded twice. Run it again after adding a skill.

## Global instructions

[`global/CLAUDE.md`](global/CLAUDE.md) holds the decisions every pjb0811 repository shares: how to work and report, file naming and barrels, code style defaults, commit language and trailers, and the issue/PR language and evidence rules. The procedures live in the skills above, and `CLAUDE.md` points to them instead of repeating them. It lives under `global/` rather than at the root so it doesn't load as this repository's own project instructions.

## Third-party skills

These are used in some repositories but are maintained upstream, so they are not copied here. Install them from the source.

| Skill | Source |
| --- | --- |
| `react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
| `composition-patterns` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
| `deploy-to-vercel` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
| `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
| `writing-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) |
