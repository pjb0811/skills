---
name: repo-settings
description: "Check and align a GitHub repository's settings with the shared standard: squash-only merges, delete head branches on merge, auto-merge allowed, and a default-branch ruleset (no deletion, no force push, pull request required with zero approvals, no bypass actors, the CI jobs as required checks when the repository has CI, no automatic review rules such as Copilot code review). Compares the current settings with `gh api`, shows the differences, and applies them after the user confirms. Repository-agnostic: works for any repository the user owns, including a new one. Use when creating a repository, when a merge is refused ('Merge commits are not allowed', 'Auto merge is not allowed'), when repositories behave differently on merge, or when the user says '저장소 설정 맞춰줘', '보호 규칙', 'ruleset', 'auto-merge 켜줘', 'branch protection', 'align repo settings'."
---

# Repo Settings

저장소의 GitHub 설정을 전역 지침 "저장소 설정"의 표준과 비교하고, 어긋난 항목을 사용자 확인을 받은 뒤 맞춘다. 표준 자체(무엇으로 맞추는지)는 전역 지침이 정본이다. 이 스킬은 확인하고 고치는 순서만 둔다.

명령은 `gh api`로 쓴다. `gh repo edit`의 플래그는 `gh` 버전마다 다르다. 처음 쓰는 플래그는 `gh <명령> --help`로 지금 버전에 있는지 확인한다(전역 지침 "검증과 보고").

## 1. 표준 값

| 항목 | 값 | API 필드 |
| --- | --- | --- |
| squash 머지 | 허용 | `allow_squash_merge: true` |
| merge commit, rebase 머지 | 금지 | `allow_merge_commit: false`, `allow_rebase_merge: false` |
| 머지 후 head 브랜치 삭제 | 켬 | `delete_branch_on_merge: true` |
| auto-merge | 허용 | `allow_auto_merge: true` |
| 기본 브랜치 ruleset | 이름 `main`, 대상 `~DEFAULT_BRANCH`, `enforcement: active`, `bypass_actors: []` | `/rulesets` |
| ruleset 규칙 | `deletion`, `non_fast_forward`, `pull_request`(승인 0명), CI가 있으면 `required_status_checks` | |
| 자동 리뷰 규칙 | 두지 않음 | `copilot_code_review` 등이 없어야 한다 |

## 2. 현재 설정 확인

```bash
repo=<owner>/<repo>
gh api "repos/$repo" --jq '{allow_squash_merge, allow_merge_commit, allow_rebase_merge, delete_branch_on_merge, allow_auto_merge}'
gh api "repos/$repo/rulesets" --jq '.[] | {id, name, enforcement}'
gh api "repos/$repo/rulesets/<id>" --jq '{enforcement, conditions, bypass_actors, rules: [.rules[] | {type, parameters}]}'
```

ruleset이 하나도 없으면 새로 만든다(4단계). 이름이 다르거나 여러 개면 기본 브랜치에 걸린 것을 기준으로 보고, 무엇을 남길지 사용자에게 묻는다.

## 3. 필수 체크 이름 정하기

필수 체크는 **CI가 PR에서 실제로 보고하는 check run 이름**과 정확히 같아야 한다. 이름이 다르면 그 체크는 영원히 대기 상태로 남아 모든 PR이 머지되지 않는다.

```bash
ls .github/workflows/ 2>/dev/null          # CI가 있는지
gh pr list --repo "$repo" --state merged --limit 1 --json headRefOid --jq '.[0].headRefOid'
gh api "repos/$repo/commits/<sha>/check-runs" --jq '[.check_runs[] | "\(.name) app=\(.app.id)"] | unique'
```

- PR마다 도는 검사 job만 넣는다(lint·test·build, changesets 초안 봇 등). `main` push에서만 도는 배포·버전 job은 넣지 않는다.
- `integration_id`는 check run의 `app.id`다(GitHub Actions면 모든 저장소에서 같은 값).
- CI가 없거나 아직 한 번도 돌지 않았으면 필수 체크를 넣지 않는다. CI를 추가한 뒤 첫 실행에서 이름을 확인하고 넣는다.

## 4. 바꿀 내용을 보이고 확인받기

2단계 결과와 1단계 표준을 항목별로 비교한 표를 사용자에게 보인다. 바꾸면 생기는 영향도 함께 적는다.

- `pull_request` 규칙과 빈 `bypass_actors`를 적용하면 저장소 주인도 기본 브랜치에 직접 push할 수 없고 PR로만 반영된다.
- 지금 열린 PR의 머지 방식이 바뀐다(예: merge commit으로 머지하던 저장소는 squash만 가능해진다).
- 자동 리뷰 규칙을 지우면 그 리뷰가 더 이상 붙지 않는다.

사용자가 확인하기 전에는 바꾸지 않는다.

## 5. 적용

**저장소 설정**

```bash
gh api -X PATCH "repos/$repo" \
  -F allow_squash_merge=true -F allow_merge_commit=false -F allow_rebase_merge=false \
  -F delete_branch_on_merge=true -F allow_auto_merge=true
```

**ruleset 본문** (`ruleset.json`). CI가 없으면 `required_status_checks` 항목을 통째로 뺀다.

```json
{
  "name": "main",
  "target": "branch",
  "enforcement": "active",
  "bypass_actors": [],
  "conditions": { "ref_name": { "include": ["~DEFAULT_BRANCH"], "exclude": [] } },
  "rules": [
    { "type": "deletion" },
    { "type": "non_fast_forward" },
    {
      "type": "pull_request",
      "parameters": {
        "allowed_merge_methods": ["merge", "squash", "rebase"],
        "dismiss_stale_reviews_on_push": false,
        "require_code_owner_review": false,
        "require_extra_approval_for_unattributed_changes": true,
        "require_last_push_approval": false,
        "required_approving_review_count": 0,
        "required_review_thread_resolution": false,
        "required_reviewers": []
      }
    },
    {
      "type": "required_status_checks",
      "parameters": {
        "do_not_enforce_on_create": false,
        "strict_required_status_checks_policy": false,
        "required_status_checks": [{ "context": "<check run name>", "integration_id": <app id> }]
      }
    }
  ]
}
```

`allowed_merge_methods`는 세 가지를 모두 둔다. 실제로 쓸 수 있는 방식은 저장소 설정(squash만 허용)이 정한다.

```bash
gh api -X POST "repos/$repo/rulesets" --input ruleset.json          # 새로 만들 때
gh api -X PUT "repos/$repo/rulesets/<id>" --input ruleset.json      # 있는 것을 바꿀 때(규칙 목록 전체를 교체한다)
```

`PUT`은 규칙 목록을 통째로 바꾼다. 기존 ruleset에서 남겨야 할 규칙이 있으면 본문에 함께 넣는다.

## 6. 확인

2단계 명령을 다시 실행해 표준과 같아졌는지 본다. 여러 저장소를 맞췄으면 저장소별로 한 줄씩 요약해서 보고한다.

```bash
gh api "repos/$repo/rulesets/<id>" --jq '"\(.enforcement) \([.rules[].type] | sort | join(",")) checks=\([.rules[] | select(.type == "required_status_checks") | .parameters.required_status_checks[].context] | join("+"))"'
```

## 엣지 케이스

- **새 저장소**: 첫 커밋을 push한 뒤에 ruleset을 만든다. 먼저 만들면 PR 필수 규칙 때문에 첫 push가 막힐 수 있다. CI는 첫 PR에서 체크 이름을 확인한 뒤 필수 체크로 추가한다.
- **CI job 이름을 바꾸는 PR**: 필수 체크 이름도 같이 바꿔야 한다. 바꾸지 않으면 그 PR부터 머지가 막힌다. 순서는 사용자에게 알리고 정한다.
- **auto-merge를 켤 때**: 필수 체크가 없는 저장소에서는 PR이 처음부터 머지 가능한 상태라 auto-merge가 쓰이지 않는다. 그런 저장소에서는 체크를 기다리지 말고 바로 머지한다.
- **봇 커밋 뒤 `action_required`로 멈춘 실행**은 auto-merge로 풀리지 않는다. 승인 절차는 `changesets-release` 스킬 4단계.
