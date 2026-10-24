---
name: pr
description: "Draft a pull request title and body from the branch's final diff, the repository's PR template and its recent merged PRs, then push and open the PR with `gh` (or update an open PR's description). The body is English, follows the common Summary / Changes / How to test structure in every repository, lists only the checks that ran, and carries no AI attribution footer. Every repository uses this one global skill; repository differences live only in its templates. Use when the user says 'PR 올려줘', 'PR 만들어줘', 'PR 본문 써줘', '/pr', 'open a PR', 'update the PR description'."
---

# PR

브랜치의 최종 변경을 바탕으로 PR 제목과 본문을 쓰고, push한 뒤 `gh`로 PR을 연다. 이미 열린 PR이면 본문을 최신 상태로 고친다.

본문은 대화를 보지 않은 리뷰어가 읽는다고 가정하고 쓴다. 섹션 구성은 모든 저장소에서 아래 4단계의 기본 구성으로 통일하고, 저장소의 PR 템플릿은 그 구성에 맞춰 둔다(환경 의존, 2026-10 확인: PR 템플릿이 있는 pjb0811 저장소들은 이 4개 섹션으로 시작한다. 2단계에서 템플릿을 읽을 때 다시 확인된다).

## 0. 저장소별 스킬을 두지 않는다

모든 저장소가 이 전역 스킬 하나를 따른다. 저장소에 같은 이름의 스킬을 만들어 덮어쓰지 않는다. 저장소마다 다른 부분은 그 저장소의 PR 템플릿(체크박스, 필수 항목 등)으로만 둔다.

## 1. 사전 확인

```bash
git status --short
git branch --show-current
base=$(gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git fetch origin "$base"
git log --oneline "origin/$base..HEAD"
```

`origin/HEAD`는 clone 방식에 따라 설정돼 있지 않을 수 있어서 기본 브랜치를 `gh`로 읽는다.

- 기본 브랜치(`main` 등)에 있으면 멈추고 작업 브랜치를 만들지 묻는다.
- 커밋되지 않은 변경이 있으면 PR에 들어갈 것인지 확인한다. 범위를 임의로 넓혀 `git add -A`/`git add .`를 쓰지 않는다.
- 커밋 작성자가 의도한 계정인지 확인한다(`git log --format='%an <%ae>' "origin/$base..HEAD"`).

## 2. 참고 자료 읽기

모두 **지금 새로** 읽는다. 이전 대화의 결과를 재사용하지 않는다.

1. **PR 템플릿**: `.github/pull_request_template.md`, `.github/PULL_REQUEST_TEMPLATE/`, `docs/` 아래 템플릿 등.
2. **최근 머지된 PR 약 5개**:
   ```bash
   gh pr list --state merged --limit 15 --json number,title,body,url,mergedAt,author \
     -q '[.[] | select(.author.is_bot | not) | select(.title | test("^chore: version packages") | not)][:5]'
   ```
   봇이 만든 PR(Version Packages, Renovate 등)은 사람이 쓴 본문이 아니므로 뺀다. 분량과 자세함의 수준, 템플릿 체크박스를 실제로 어떻게 채우는지를 본다. 최근 PR의 섹션 이름이 기본 구성과 달라도 그 이름은 따르지 않는다(예전 형식일 수 있다). 5개보다 적으면 있는 만큼 쓴다. 원격 기록을 못 읽으면 템플릿과 로컬 근거만으로 쓰고, 예시를 지어내지 않는다.
3. **저장소 지침**: `AGENTS.md`, `CLAUDE.md`, `CONTRIBUTING.md`의 PR·언어·changeset 규칙.
4. **최종 변경 내용**: `git diff <base>...HEAD --stat`, `git diff <base>...HEAD`, 관련 이슈 본문(`gh issue view <n>`), 실제로 돌린 검증 결과.

참고한 PR의 문장, 수치, 검증 결과를 그대로 옮기지 않는다. 지금 변경에 맞지 않는 섹션도 넣지 않는다. 형제 저장소에서는 이 과정을 저장소마다 따로 한다.

## 3. 제목

- 커밋 컨벤션과 같은 `type(scope): summary` 형식이다. gitmoji는 붙이지 않는다.
- 호환성을 깨는 변경(공개 API 제거, 지원 범위 축소 등)은 타입 뒤에 `!`를 붙인다(`refactor(api)!: …`, `chore(deps)!: …`).
- 커밋이 하나면 보통 그 커밋 제목과 같다. 여러 개면 전체를 대표하는 한 줄로 쓴다.
- 영어 명령문, 소문자 시작, 마침표 없음.

## 4. 본문 구성

**섹션 구성**: 아래 기본 구성을 쓴다. 저장소 템플릿이 있으면 기본 구성 뒤에 템플릿 고유의 섹션(체크박스, Breaking Changes 등)을 붙인다. 템플릿이 기본 구성과 다른 섹션 이름(예: Validation, What was wrong)을 쓰고 있으면, 기본 구성 이름으로 쓰고 템플릿을 맞추자고 사용자에게 제안한다.

템플릿 체크박스는 목록의 성격에 따라 다르게 다룬다.

- **검증 목록**(How to test의 검사 항목, Checklist): 항목을 모두 남기고, 실제로 한 것만 체크한다. 체크되지 않은 항목이 하지 않은 일을 그대로 보여 준다. 대신 다른 검사를 했으면 항목 옆에 적는다(`` — root build not run; UI and website builds passed ``).
- **선택 목록**(Type of Change, Scope 등): 해당하는 항목만 체크해서 남기고 나머지 줄은 지운다.
- 해당 없는 선택 섹션(UI 변경이 없을 때의 Screenshots / Demo 등)은 섹션째 지운다.
- 템플릿의 안내 주석(`<!-- … -->`)은 지운다.

기본 구성. Google의 CL 설명 가이드와 React, Next.js, Kubernetes, Angular의 PR 템플릿에서 공통으로 쓰는 구성이다.

```markdown
## Summary

<!-- 무엇을 왜 바꾸는지. 해결하는 문제나 동기.
     버그: 무엇을 하면(트리거) 어떻게 되는지, 수정 전/후 동작.
     기능: 무엇이 빠져 있었고, 그래서 무엇을 못 했는지. -->

Closes #123.

## Changes

<!-- 최종 구현이 실제로 바꾼 것. 공개 API/동작 변경, 문서, 릴리스 영향(changeset 등). -->

## How to test

<!-- 어떻게 검증했는지. 실제로 돌린 검사와 결과, 리뷰어가 직접 확인하는 방법. -->

## Notes for reviewers

<!-- 선택: 설계 선택의 이유, 이슈 제안과 다르게 한 부분, 한계, 남은 범위. 있을 때만. -->
```

- **첫 줄과 Summary**: 나중에 이 PR을 검색해서 읽을 사람이 무엇을 왜 했는지 바로 알 수 있게 쓴다. "Fix bug", "Phase 1"처럼 막연한 요약은 쓰지 않는다.
- **이슈 연결**: 이 PR로 이슈가 실제로 해결될 때만 `Closes #N`을 쓴다(Summary 안이나 바로 아래). 일부만 다루면 `Part of #N`으로 쓰고 남은 범위를 적는다. 다른 저장소 이슈는 `owner/repo#N`으로 쓴다.
- **Summary의 근거**: 가능한 한 구체적으로 쓴다. 재현한 입력과 결과, 측정값, 수정 전 코드에서 실패하는 테스트 등이다. 짐작은 짐작이라고 쓴다.
- **Changes**: 파일 나열이 아니라 동작 단위로 쓴다. 바뀌지 않은 동작은 범위를 정하거나 사용자에게 영향이 있을 때만 쓴다. diff가 의도보다 커 보이는 부분(포매터가 표 전체를 재정렬함 등)은 이유를 적는다. 변경이 많으면 굵은 글씨 머리말(`**Docs.**`, `**Tests.**`)로 묶는다. 릴리스를 관리하는 저장소(changesets 등)면 마지막 항목에 릴리스 영향을 쓴다(`**Changeset:** patch.`). major이거나 비어 있으면 이유를 붙인다(`**Changeset:** empty (comments only).`).
- **How to test**: 단위 테스트(무엇을 확인하는지, 수정 전에는 실패하는지), 전체 테스트/lint/타입/빌드 결과, 브라우저나 Storybook 확인을 쓴다. **확인하지 못한 것은 확인하지 못했다고 쓴다.** 템플릿에 검사 체크박스가 있으면:
  1. 체크박스에는 실제로 돌린 것만 체크한다. 다른 명령이 대신 돌렸으면 그렇게 적는다(`` `pnpm check-types` (run by `pnpm build`) ``). 수동 확인 항목은 직접 확인했을 때만 체크하고, 무엇을 어떤 환경(브라우저, 뷰포트 등)에서 봤는지 아래에 쓴다.
  2. 체크박스 아래 목록에 나머지를 쓴다: 추가하거나 바꾼 테스트와 그 테스트가 확인하는 것, 수정 전 코드에서 그 테스트가 실패하는지, 전체 테스트와 그 밖의 검사 결과(파일·테스트 수 등 수치). 항목이 많으면 굵은 머리말(`**Unit tests.**`, `**Browser test.**`, `**Other checks.**`)로 묶고, 결과만 나열할 때는 `Also ran, all passing:` 목록으로 써도 된다. 실패가 있었으면 "all passing"이라고 쓰지 않는다.
  3. 하지 않은 검사는 마지막에 따로 쓴다(`Not run: …`, `**Not checked yet.** …`). 리뷰에 필요하면 이유도 쓴다.
- **Notes for reviewers**: 리뷰어가 판단하는 데 필요한 것만 쓴다. 검토했다 기각한 대안과 그 이유, 이슈 제안 중 하지 않은 것과 그 이유(다른 이슈로 미뤘으면 `#N`), 다른 PR과의 머지 순서나 의존 관계, 머지했을 때의 릴리스 영향(예: major changeset이 main에 들어가 다음 릴리스가 메이저가 됨)이 있으면 여기에 쓴다. 비어 있으면 섹션째 뺀다.
- 화면이 바뀌면 스크린샷이나 데모 섹션을 추가하거나(템플릿에 있으면 그 섹션), 못 붙였다는 사실을 적는다.

## 5. 작성 규칙

- **언어**: 저장소 지침이 따로 정하지 않으면 제목과 본문 전체를 영어로 쓴다(사용자와의 대화 언어와 무관).
- **분량은 변경 크기에 맞춘다.** 한 줄 수정이면 몇 줄로 끝낸다. 표나 코드 블록은 이해를 돕는 경우에만 쓴다. 다만 버그·성능 PR의 근거(재현 결과, 측정값)는 덜어내지 않는다. 측정했으면 before/after 표로 넣는다.
- 대화 경위("처음엔 ~했다가")는 쓰지 않는다. 최종 브랜치 내용만 설명한다. 검토했다 기각한 대안은 경위가 아니라 설계 근거이므로 이유와 함께 `Notes for reviewers`에 쓴다.
- `🤖 Generated with ...` 같은 AI 표기 문구나 생성 도구 표기를 넣지 않는다. 마지막 실제 섹션으로 끝낸다.
- 링크는 실제로 존재하는 이슈, PR, 문서만 건다.

## 6. 확인

- 사용자가 "PR 올려줘"처럼 생성을 명시적으로 요청했으면 바로 7단계로 간다.
- "PR 본문 써줘"처럼 초안만 요청했거나 범위가 애매하면, 제목과 본문을 먼저 보여 주고 승인을 받는다.

## 7. push와 생성

본문은 임시 파일(작업용 scratch 디렉터리)에 써서 넘긴다. 셸 따옴표 문제를 피하기 위해서다.

```bash
git push -u origin <branch>
gh pr create --base <default-branch> --title "<title>" --body-file <file>
```

- 생성된 PR URL을 사용자에게 알린다.
- 생성 직후 AI 표기 문구가 남지 않았는지 확인한다. 출력이 비어 있어야 한다. 남아 있으면 지우고 8단계의 `gh pr edit`으로 고친다.
  ```bash
  gh pr view <number> --json body --jq .body | grep -i -E 'generated (with|by)|co-authored-by'
  ```
- force push는 사용자가 요청한 경우에만 한다.

## 8. 이후 갱신

PR을 연 뒤 커밋이 추가되거나 범위가 바뀌면, 제목과 본문을 최종 내용에 맞게 고친다. 낡은 검증 결과가 남지 않게 한다.

```bash
gh pr edit <number> --title "<title>" --body-file <file>
```
