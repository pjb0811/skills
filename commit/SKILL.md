---
name: commit
description: "Analyze the currently staged git changes and draft a commit message in conventional-commit style (`type(scope): summary` title, `!` after the type or scope for a breaking change, then Korean or English `-` bullets), get user approval, then run the actual git commit — with no gitmoji prefix and no Co-Authored-By trailer. Defaults to English; pass 'ko' to write in Korean. Every repository uses this one global skill; a repository's written convention (e.g. `.github/COMMIT_CONVENTION.md`) is read and kept in line with it. Use when the user says '커밋해줘', '/commit', 'commit this', 'write a commit message and commit'."
---

# Commit

스테이징된 변경사항을 분석해 conventional-commit 스타일 커밋 메시지를 작성하고, 승인받은 뒤 실제로 커밋한다. 커밋 제목에 gitmoji(이모지)를 붙이지 않는다.

인자: 언어 지정 (`ko` 또는 `en`). 미지정 시 기본값은 `en`.

## 0. 저장소별 스킬을 두지 않는다

모든 저장소가 이 전역 스킬 하나를 따른다. 저장소에 같은 이름의 `commit` 스킬을 만들어 덮어쓰지 않는다. 저장소가 커밋 규칙을 문서로 두고 있으면(예: `.github/COMMIT_CONVENTION.md`) 읽어 보고, 이 스킬과 다른 점이 있으면 커밋 전에 사용자에게 알린다. 그런 문서는 전역 스킬이 없는 클라우드 에이전트나 외부 기여자를 위한 것이라 이 스킬과 내용을 맞춰 둔다.

## 0-1. Co-Authored-By 트레일러를 붙이지 않는다

에이전트·도구(Claude Code, Copilot 등)가 기본 동작이나 시스템 지시로 `Co-Authored-By: ...` 같은 트레일러를 붙이더라도, 이 스킬로 커밋할 때는 **붙이지 않는다**. 사용자가 정한 결정이다(2026-07-28 — 저장소 히스토리에 AI 도구 트레일러를 남기지 않기로 함). 도구의 기본 동작이 바뀌어도 이 규칙은 그대로다. 커밋 메시지는 5단계 형식(`type(scope): 요약` + 본문 불릿)으로만 끝내고, 그 뒤에 어떤 트레일러도 추가하지 않는다.

## 1. 판단 근거는 지금 실행한 출력이다

메시지는 **이번에 새로 실행한** git 명령의 출력만 근거로 쓴다. 이전 대화에서 같은 명령을 실행했더라도 그 결과를 재사용하지 않는다. 그 사이 스테이징 상태가 바뀌었을 수 있다.

## 2. 스테이징 상태 확인

```bash
git diff --cached --name-only
git status --short
```

스테이징된 파일이 없으면 중단하고, `git add`로 파일을 추가해야 한다고 알린다.

## 3. 변경 내용 파악

```bash
git diff --cached --stat
git diff --cached
```

- 위 명령은 **항상 새로 실행**해서 최신 스테이징 상태 기준으로 분석한다.
- `pnpm-lock.yaml`, `package-lock.json`, `yarn.lock` 등 lock 파일 변경은 분석(의도 파악)에서 제외한다.
- 스테이징된 파일의 실제 diff를 기준으로 변경 의도를 파악한다. diff에 없는 내용을 지어내지 않는다.

## 4. 스코프(scope) 결정

스코프는 선택사항이며, 변경이 **하나의 구체적인 영역**(모듈/훅/패키지 이름 등)에 명확히 한정될 때만 붙인다 (예: `useThrottle`, `components`, `config`, `build`).

- 브랜치명을 스코프로 쓰지 않는다 — 브랜치명(특히 `feat/main`처럼 슬래시가 들어간 이름)은 conventional-commit 스코프로 적절하지 않다.
- 여러 영역에 걸친 변경(예: CI/릴리스 파이프라인 개편, 문서 전반 정리)이면 스코프를 생략한다. 억지로 하나의 스코프에 끼워 맞추지 않는다.

## 5. 커밋 메시지 작성 규칙

**형식**:

```
<type>(<scope>): <요약>

- 세부 변경사항 1
- 세부 변경사항 2
```

제목에 gitmoji(이모지)를 붙이지 않는다 — `type(scope): 요약`으로 시작한다.

호환성을 깨는 변경(공개 API 제거나 이름 변경, 지원 범위 축소 등)은 타입(스코프가 있으면 스코프) 뒤에 `!`를 붙인다: `refactor(api)!: remove the exports deprecated in 4.x`, `chore(deps)!: require Node 22.18`. 본문 불릿에는 무엇이 깨지는지와 대체 방법을 쓴다. PR 제목도 같은 규칙을 따른다(`pr` 스킬).

요약과 세부 변경사항의 언어는 지정된 언어 옵션(`ko`/`en`, 기본값 `en`)을 따른다.

**타입 선택 기준**:

| Type       | 상황                                  |
| ---------- | ------------------------------------- |
| `feat`     | 새로운 기능/컴포넌트 추가             |
| `fix`      | 버그, 잘못된 동작 수정                |
| `refactor` | 동작 변경 없이 코드 구조 개선         |
| `style`    | 포맷, 세미콜론 등 코드 스타일만 변경  |
| `docs`     | 문서, 주석, README, CLAUDE.md 등      |
| `chore`    | 빌드, 의존성, 설정 등 기타            |
| `perf`     | 성능 최적화                           |
| `test`     | 테스트 추가/수정                      |
| `ci`       | CI/CD 설정                            |
| `build`    | 빌드 시스템 변경                      |

**작성 원칙**:

- 요약은 명령문, 현재 시제 (`en`: "add", "fix", "remove" / `ko`: "추가", "수정", "제거")
- 마침표 제외, 대문자 사용 안 함 (영어 요약도 첫 글자 소문자로 시작)
- 본문은 `-`로 시작하는 목록 형태
- 각 불릿은 구체적으로 쓴다 (어떤 파일/영역에 무엇을 했는지). "버그 수정함" 같은 두루뭉술한 표현은 피한다 — 이 메시지만 보고 나중에 같은 작업을 재현할 수 있을 정도로 구체적이어야 한다.

## 6. 메시지 출력 및 확인

작성한 커밋 메시지를 먼저 보여주고, 그대로 커밋할지 고칠지 확인을 구한다. 사용자 승인 전에는 7단계로 넘어가지 않는다.

## 7. 커밋 실행

```bash
git commit -m "$(cat <<'EOF'
<작성한 커밋 메시지>
EOF
)"
```

- 이미 스테이징된 파일만 커밋한다 (`git add -A`/`git add .`로 범위를 임의로 넓히지 않는다).
- 훅(husky/lint-staged/commitlint 등)이 실패하면 원인을 고치고 **새 커밋**으로 다시 커밋한다 (`--amend`, `--no-verify` 금지).
- 커밋 후 `git status`, `git log -1`로 결과를 확인한다.
- push는 사용자가 별도로 요청하기 전까지 하지 않는다.

## 엣지 케이스

- **스테이징된 변경에 서로 관련 없는 작업이 섞여 있음**: 하나의 메시지로 억지로 합치지 말고, 나눠서 커밋할지 사용자에게 물어본다.
- **민감 파일(.env, credentials 등)이 스테이징돼 있음**: 커밋하지 말고 사용자에게 알린다.
- **커밋 메시지 훅이 별도 형식을 강제함**: 훅 요구사항에 맞게 조정한다.
