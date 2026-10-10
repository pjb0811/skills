# skills

Personal [Claude Code skills](https://docs.claude.com/en/docs/claude-code/skills) shared by every pjb0811 repository. This repository is the source of truth; `~/.claude/skills/<name>` links here.

## Skills

| Skill | Use it for |
| --- | --- |
| [`commit`](commit/SKILL.md) | Drafting a conventional commit message from the staged diff, then committing |
| [`pr`](pr/SKILL.md) | Writing and opening a pull request (Summary / Changes / How to test) |
| [`issue`](issue/SKILL.md) | Filing a GitHub issue that follows the repository's templates |
| [`ref-verification`](ref-verification/SKILL.md) | Reading repository state from git refs instead of a possibly stale worktree |
| [`coding-style`](coding-style/SKILL.md) | Following a repository's conventions, bulk renames, comments, boolean names, braces, subcomponent file layout |
| [`changesets-release`](changesets-release/SKILL.md) | The changesets release flow, npm publish checks, approving `action_required` runs |
| [`publish-check`](publish-check/SKILL.md) | Pre-release checks for an npm package: publish status, type check, build, version, `exports` vs entries |
| [`shared-library-first`](shared-library-first/SKILL.md) | Building reusable UI in `ui-kit` and hooks in `use-hooks` before using them in an app |

Repository-specific skills stay in their repositories, for example `version-management` (package path, npm publish status), `component-naming` audits and the `new-component` / `new-story` commands in `ui-kit`, `ast` in `live-editor` and `add-hook` in `use-hooks`.

## Install

```bash
git clone git@github.com:pjb0811/skills.git ~/github/skills
~/github/skills/install.sh
```

`install.sh` links each skill directory into `~/.claude/skills` (override with `CLAUDE_SKILLS_DIR`). An existing directory with the same name is moved to `~/.claude/skills-backup/<timestamp>/` first, outside the skills directory so it isn't loaded twice. Run it again after adding a skill.

## Third-party skills

These are used in some repositories but are maintained upstream, so they are not copied here. Install them from the source:

| Skill | Source | Used in |
| --- | --- | --- |
| `vercel-react-best-practices` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | live-editor, use-hooks |
| `vercel-composition-patterns` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | live-editor |
| `deploy-to-vercel` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | use-hooks |
| `web-design-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | live-editor, use-hooks |
| `writing-guidelines` | [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) | live-editor |
