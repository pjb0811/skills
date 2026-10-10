---
name: issue
description: "Draft and file a GitHub issue with `gh`: check for duplicates, follow the repository's issue template and recent issues, verify the facts against the code, then write an English body shaped by type (bug: description / steps to reproduce / expected / actual / environment; feature: problem / proposed solution / alternatives). Separates confirmed facts from guesses and carries no AI attribution footer. Every repository uses this one global skill; repository differences live only in its templates. Use when the user says '이슈 등록해줘', '이슈 만들어줘', '이슈로 남겨줘', '/issue', 'file an issue', 'open an issue'."
---

# Issue

GitHub 이슈를 작성하고 `gh`로 등록한다. 이슈는 나중에 이 대화를 모르는 사람이나 에이전트가 읽고 작업을 시작하는 문서다. 혼자 읽어도 무엇이 문제이고 무엇을 하면 끝나는지 알 수 있어야 한다.

## 0. 저장소별 스킬을 두지 않는다

모든 저장소가 이 전역 스킬 하나를 따른다. 저장소에 같은 이름의 스킬을 만들어 덮어쓰지 않는다. 저장소마다 다른 부분은 그 저장소의 이슈 템플릿(체크박스, 필수 항목 등)으로만 둔다.

## 1. 어느 저장소에 등록할지

- 문제가 실제로 고쳐질 곳에 등록한다. 공유 UI나 훅 문제는 쓰는 쪽 앱이 아니라 `ui-kit`/`use-hooks` 같은 라이브러리 저장소에 낸다.
- 대상 저장소가 현재 디렉터리와 다르면 `gh ... --repo owner/repo`로 지정한다.

## 2. 참고 자료와 중복 확인

모두 **지금 새로** 읽는다.

```bash
gh issue list --state all --search "<키워드>" --limit 20
gh issue list --state all --limit 5 --json number,title,body,labels
gh label list
```

- **중복**: 같은 내용의 열린 이슈가 있으면 새로 만들지 않는다. 그 이슈에 코멘트를 달지 사용자에게 묻는다. 닫힌 이슈와 관련 있으면 본문에서 링크한다.
- **템플릿**: `.github/ISSUE_TEMPLATE/`(md나 yml 폼)이 있으면 그 섹션과 필수 항목을 따른다.
- **최근 이슈**: 제목 형식, 섹션 이름, 분량을 맞춘다. 문장을 그대로 옮기지는 않는다.
- **라벨**: 이미 있는 라벨만 붙인다. 새 라벨은 만들지 않는다.

## 3. 사실 확인

- 코드 위치, 동작, 원인은 직접 확인한 뒤에 쓴다. 저장소 상태는 작업 트리 대신 최신 ref를 기준으로 읽는다(`ref-verification` 스킬).
- 가능하면 재현한다. 재현했으면 입력과 결과를 그대로 적는다. 못 했으면 못 했다고 쓴다.
- 확인한 사실과 추정을 문장에서 구분한다("Confirmed on `main` at abc1234: …", "Likely cause: …").

## 4. 제목

- 저장소 관례를 따른다. 따로 없으면 커밋과 같은 `type(scope): summary` 형식이다(`fix(frame): …`, `feat(panel): …`). gitmoji는 붙이지 않는다.
- 해결책이 아니라 문제나 필요를 한 줄로 쓴다.

## 5. 본문 구성

템플릿이 없을 때의 기본값이다. React, Next.js, Vue, Angular, Node.js의 이슈 템플릿에서 공통으로 쓰는 구성이다. 해당 없는 섹션은 지운다.

**버그**

```markdown
## Description

<!-- 한두 문장 요약. 사용자에게 어떤 영향이 있는지. -->

## Steps to reproduce

1.
2.

<!-- 최소 재현 코드나 링크가 있으면 함께. -->

## Expected behavior

## Actual behavior

<!-- 에러 메시지, 측정값, 스크린샷. 코드 위치는 `path/to/file.ts:42`. -->

## Environment

<!-- 버전/커밋, 브라우저, OS 등 재현에 영향이 있는 것만. -->

## Additional context

<!-- 선택: 추정 원인(추정이라고 명시), 관련 이슈/PR, 우회 방법. -->
```

**기능 / 개선**

```markdown
## Problem

<!-- 이 기능이 해결할 문제. 지금 무엇을 못 하는지, 누가 왜 필요로 하는지. 현재 코드에서 관련 위치. -->

## Proposed solution

<!-- 제안하는 API나 동작. 기존 동작과 호환되는지. -->

## Alternatives considered

<!-- 검토한 다른 방법과 고르지 않은 이유. 없으면 섹션째 뺀다. -->

## Additional context

<!-- 선택: 관련 이슈/PR, 일부러 범위에서 뺀 것. -->

## Acceptance criteria

- <!-- 선택: 끝났다고 판단할 수 있는 확인 항목. 테스트로 옮길 수 있게 구체적으로. -->
```

`Acceptance criteria`는 오픈소스 이슈 템플릿에는 드물다. 이슈를 다른 사람이나 에이전트가 이어받아 작업할 때 완료 조건을 분명히 하려고 넣는 선택 섹션이다.

리팩터링, 문서, 작업성 이슈는 `Problem` 대신 `Context`로 바꾸고, 같은 흐름(배경 → 할 일 → 완료 조건)으로 쓴다.

## 6. 작성 규칙

- **언어**: 저장소 지침이 따로 정하지 않으면 제목과 본문을 영어로 쓴다(사용자와의 대화 언어와 무관).
- **분량은 문제 크기에 맞춘다.** 작은 버그는 몇 줄이면 된다.
- 관련 이슈와 PR은 링크한다. 다른 저장소는 `owner/repo#N`으로 쓴다. 실제로 존재하는 것만 건다.
- 코드 위치는 `path:line`으로 쓰고, 줄 번호가 바뀔 수 있으면 기준 커밋을 함께 적는다.
- 대화 경위는 쓰지 않는다. 이 대화에서 처음 나온 사실이면, 왜 문제인지를 이슈 안에서 설명한다.
- 비공개 정보(토큰, 개인 데이터, 내부 URL)는 넣지 않는다.
- `🤖 Generated with ...` 같은 AI 표기 문구나 생성 도구 표기를 넣지 않는다.

## 7. 확인

이슈 등록은 외부에 공개되는 작업이다.

- 사용자가 "이슈 등록해줘"처럼 등록을 명시적으로 요청했고 내용이 대화에서 이미 정해졌으면 바로 등록한다.
- 그 외(초안 요청, 범위나 대상 저장소가 애매함, 중복 가능성)에는 제목과 본문을 먼저 보여 주고 승인을 받는다.

## 8. 등록

본문은 임시 파일(작업용 scratch 디렉터리)에 써서 넘긴다.

```bash
gh issue create --title "<title>" --body-file <file> [--label <label>] [--repo owner/repo]
```

- 생성된 이슈 URL을 사용자에게 알린다.
- 등록 후 내용을 고칠 때는 `gh issue edit <n> --body-file <file>`을 쓰고, 큰 변경이면 코멘트로 무엇을 바꿨는지 남긴다.
