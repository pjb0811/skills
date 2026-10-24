---
name: coding-style
description: "Repo-agnostic coding-conventions toolkit — a growing set of procedures for working consistently within any codebase. Currently covers: (A) discovering and following a project's existing directory structure and coding conventions before writing/editing code (checks CLAUDE.md/AGENTS.md, README/CONTRIBUTING, formatter/linter configs, and neighboring files); (B) safely renaming directories/files to a different naming convention (e.g. PascalCase to kebab-case) across a codebase without breaking imports or losing git history; (C) writing and rewriting code comments: lead with what the code does, keep a reason only as a present-tense constraint, and replace history with an issue number; (D) naming booleans: `is`/`has`/`can` on boolean values and state, a bare adjective on props, `isX(value)` for predicates, and no `_`/`xProp` alias for a prop that collides with its state; (E) always wrapping `if`/`else` bodies in braces, even single statements; (F) laying out a component with subcomponents as sibling files plus a pure `index.ts` barrel that attaches them with an explicit intersection-type cast; (G) putting one blank line at statement-group boundaries (after declarations, between guard clauses, before `return`); (H) ordering code inside a function component or custom hook: external hooks, state and refs, derived values, handlers, effects, early returns, then the returned JSX; (I) splitting a folder whose files have piled up flat into subfolders by screen area or user feature, not by file type (`hooks/`, `utils/`). Use when the user says '주석 정리', '주석 다시 써줘', 'rewrite the comments', or whenever writing a code comment; 'boolean 이름', 'is 접두사', or whenever naming a boolean value, state, prop or predicate; '서브컴포넌트 구조', '배럴 파일', 'compound component', or when adding a component with subcomponents; '컴포넌트 내부 순서', '훅 순서', or whenever writing or restructuring a function component or custom hook; '폴더 정리', '하위 폴더로 나눠줘', '파일이 너무 평평해', 'split this folder', or when a folder's files no longer show its structure at a glance; also when the user says '코딩 스타일대로', '컨벤션 맞춰줘', '이 프로젝트 스타일로', 'follow the project conventions', 'match the existing style', '케밥 케이스로 바꿔줘', '폴더명 리네임', 'rename directories to kebab-case', or before creating/editing a file in an unfamiliar repo without already having its conventions in context."
---

# Coding Style

저장소 전반에서 일관된 방식으로 코드를 다루기 위한 절차 모음. 여러 개의 독립된 하위 절차로 구성되며, 새로운 상황이 생기면 이 파일에 섹션을 추가해서 계속 확장한다.

> **이 파일의 명령어·스니펫(perl 변환식, Node 치환 정규식 등)은 예시다.** 더 나은 도구·방법이 있으면 그걸 쓴다. 바꿀 수 없는 것은 **지켜야 할 결과와 검증 기준**이다 — deepest-first 순서, `git mv` 로 히스토리 보존, 경로 세그먼트 경계를 지키는 치환, typecheck/lint/build 로 확인. 반대로 **취향 규칙**(명명·배럴·주석·boolean 이름·중괄호·빈 줄·서브컴포넌트 구조·컴포넌트 내부 순서·기능 단위 하위 폴더)은 사용자가 정한 결정이므로 "더 나은 방법"으로 대체하지 않는다.

- **A. 기존 컨벤션 파악하고 따르기** — 코드를 작성/수정하기 전에 항상 먼저 확인
- **B. 네이밍 컨벤션 일괄 변경** — 디렉토리/파일명 케이스 컨벤션을 바꿔야 할 때
- **C. 주석 작성** — 코드 주석을 새로 쓰거나 기존 주석을 다시 쓸 때
- **D. boolean 이름 짓기** — boolean 값·상태·prop·판별 함수의 이름을 정할 때
- **E. 조건문은 항상 중괄호 블록으로** — `if`/`else`를 새로 쓰거나 고칠 때
- **F. 서브컴포넌트가 있는 컴포넌트의 파일 구조** — 서브컴포넌트를 가진 컴포넌트를 만들거나 정리할 때
- **G. 문장 덩어리 사이 빈 줄** — 함수·블록 안에 문장을 새로 쓰거나 고칠 때
- **H. 컴포넌트 내부 코드 순서** — 함수 컴포넌트·커스텀 훅을 새로 쓰거나 구조를 고칠 때
- **I. 커진 폴더를 기능 단위 하위 폴더로 나누기** — 한 폴더에 파일이 평평하게 쌓여 구조가 안 보일 때

---

## A. 기존 컨벤션 파악하고 따르기

새 코드를 작성하거나 기존 코드를 수정하기 전에, 이 저장소가 실제로 쓰고 있는 디렉토리 구조·코딩 컨벤션을 먼저 파악하고 그것을 따른다. 일반적으로 "옳다"고 알려진 스타일이나 다른 프로젝트에서 익힌 습관보다 **이 저장소의 기존 패턴이 항상 우선**한다.

### A1. 컨벤션 문서 탐색

작업 대상 저장소 루트(또는 서브패키지 루트)에서 아래를 순서대로 확인한다:

- `CLAUDE.md`, `AGENTS.md` — 있으면 최우선 소스. 명시적으로 작성된 규칙이므로 그대로 따른다. 단, 실제 코드와 어긋나면 낡은 것이므로 A4 를 따른다.
- `README.md` / `CONTRIBUTING.md`의 "Development" / "코딩 컨벤션" 관련 섹션
- `docs/` 하위의 스타일 가이드 (`STYLE_GUIDE.md`, `CONVENTIONS.md` 등)
- `.cursor/rules`, `.windsurfrules` 같은 다른 AI 툴용 규칙 파일 (있다면 이 프로젝트에 실제로 통용되는 규칙일 가능성이 높음)

이미 세션 컨텍스트에 CLAUDE.md 등이 로드돼 있다면 이 단계는 건너뛰고 그 내용을 바로 쓴다.

### A2. 포매터/린터 설정 확인

문서에 없는 세부 규칙(따옴표, 세미콜론, 들여쓰기, trailing comma 등)은 추측하지 말고 설정 파일에서 확인한다:

- `.prettierrc*`, `.editorconfig`, `eslint.config.*`/`.eslintrc*`
- 단, **중괄호(`curly`)·빈 줄(`padding-line-between-statements`, `newline-before-return`)은 ESLint 설정만 근거로 본다.** Prettier 는 이 항목을 강제하지 않으므로(중괄호를 넣지 않고, 빈 줄은 보존만 한다) Prettier 설정만 있으면 "설정 없음"이다.
- `package.json`의 `prettier`/`eslint` 필드

### A3. 이웃 파일로 패턴 추론

문서화되지 않은 부분(디렉토리 배치, 네이밍, export 방식, 함수/컴포넌트 작성 패턴 등)은 같은 종류의 기존 파일 2~3개를 열어 실제 패턴을 확인한다:

- 같은 계층/카테고리의 다른 컴포넌트·모듈·훅 파일
- 최근에 추가된 파일일수록 현재 컨벤션을 더 잘 반영할 가능성이 높음 (git log로 최신 파일 확인 가능)
- 파일 배치(어느 디렉토리에 두는지), import 순서, 네이밍 컨벤션, 주석 스타일, 에러 처리 패턴까지 함께 관찰

### A4. 충돌 시 우선순위

1. 이 세션에서 사용자가 명시적으로 준 지시
2. 저장소의 컨벤션 문서 (CLAUDE.md 등)
3. 포매터/린터 설정
4. 이웃 파일에서 관찰한 실제 패턴
5. (위 어느 것도 없을 때만) 언어/프레임워크의 일반적인 관용 스타일 — 이 경우 어떤 근거로 그 스타일을 골랐는지 짧게 언급한다

문서와 실제 코드가 서로 다르면(문서가 오래됨) 실제 코드 쪽을 따르고, 문서가 낡았다는 점을 근거(`path:line`, 설치 버전, `git log` 날짜)와 함께 사용자에게 짚어준다. 코드 컨벤션뿐 아니라 저장소에 커밋된 라이브러리 사용법 스킬(설치 버전과 대조)·경로·절차에도 같은 기준을 적용한다. "오래돼 보인다"는 인상만으로 문서를 무시하지 않고, 요청 없이 문서를 고치지 않는다. 대조 기준은 전역 지침의 "저장소 문서·스킬이 낡았을 때"에 있다.

**예외 — 중괄호와 빈 줄:** 저장소 ESLint 설정이나 스타일 문서가 정하지 않았으면 4번(이웃 파일)보다 **섹션 E·G 의 기본값이 우선**한다. 이웃 파일이 `if (!el) return;` 처럼 중괄호를 생략하고 있어도 새로 쓰거나 고친 코드에는 중괄호를 넣는다. 저장소가 그 룰을 끄도록 명시했으면(`'curly': 'off'` 등) 저장소 결정을 따른다. 손대지 않은 주변 코드는 스타일만 이유로 고치지 않는다.

### A5. 적용

파악한 컨벤션을 코드 작성/수정에 그대로 적용한다. 새로운 스타일을 도입하지 않는다 — 같은 목적을 기존 패턴으로 달성할 수 있으면 그쪽을 택한다.

### A 엣지 케이스

- **저장소에 해당 종류의 파일이 전혀 없음(이 카테고리의 첫 파일)**: 억지로 흉내 낼 기존 패턴이 없으므로, 컨벤션 문서의 일반 원칙(네이밍, 포맷 등)만 적용하고 언어/프레임워크의 표준 관용구를 따른다.
- **문서와 이웃 파일의 패턴이 서로 다름**: 더 최근에 수정된 쪽(git log 기준)을 우선하고, 필요하면 사용자에게 어느 쪽이 맞는지 확인한다.
- **모노레포에서 서브패키지마다 컨벤션이 다름**: 루트 문서와 서브패키지 자체 문서(예: `packages/foo/CLAUDE.md`)가 둘 다 있으면 서브패키지 쪽이 더 구체적이므로 우선한다.

---

## B. 네이밍 컨벤션 일괄 변경 (예: PascalCase → kebab-case)

디렉토리(또는 파일)명을 다른 케이스 컨벤션으로 안전하게 일괄 변환하는 절차. import가 깨지지 않고, git 히스토리(rename 추적)도 보존한 채로 진행한다.

### B0. 사전 확인

- **무엇을 바꾸는지 범위를 명확히 한다**: 디렉토리명만 바꾸는지, 파일명도 포함하는지. 기존 코드가 `{name}/index.ts` 구조라면 파일명(`index.ts`)은 안 바뀌고 디렉토리명만 바뀐다. 폴더명과 같은 이름의 파일(`{name}/{name}.tsx`)이면 파일명도 함께 바꾼다.
- **export/식별자 이름은 그대로 둔다**: 폴더명 변경과 그 폴더가 export하는 JS/TS 식별자(컴포넌트명, 함수명 등)는 별개다. 바꾸는 대상은 **경로 문자열**뿐이지 `export default Foo`의 `Foo` 자체가 아니다 (다른 케이스 컨벤션 규칙이 명시적으로 있지 않는 한).
- **public API 표면 확인**: `package.json`의 `exports` 필드처럼 외부에 노출된 subpath가 있다면, 그 키(`"./Foo"`)까지 바꾸면 breaking change가 된다. 내부 경로 값만 바꾸고 키는 유지할지, 아니면 키까지 포함해 의도적으로 breaking change를 낼지 사용자에게 확인한다.

### B1. 대상 디렉토리 목록화 (깊이 내림차순)

중첩된 디렉토리가 있으면 **가장 깊은 것부터** 처리해야 한다. 얕은 디렉토리를 먼저 리네임하면 그 하위 경로가 통째로 바뀌어서 이후 처리 대상 경로가 무효화된다.

```bash
find <root> -mindepth <N> -type d | awk -F'/' '{print NF, $0}' | sort -rn | cut -d' ' -f2-
```

### B2. 케이스 변환 함수

PascalCase/camelCase → kebab-case 예시:

```bash
to_kebab() {
  echo "$1" | perl -pe 's/([a-z0-9])([A-Z])/$1-$2/g; $_ = lc($_);'
}
```

`FloatButton` → `float-button`, `TextArea` → `text-area`, `ColorPicker` → `color-picker` 처럼 동작한다. 변환 결과가 원본과 같으면(이미 목표 컨벤션이면) 스킵한다. 다른 방향의 변환(kebab→camel 등)이 필요하면 같은 자리에 해당 변환 로직으로 바꿔 쓴다.

### B3. 대소문자만 다른 리네임은 2단계로 처리 (필수)

**Windows(NTFS)와 macOS(APFS 기본값)는 대소문자를 구분하지 않는 파일시스템**이라, `git mv Button button`처럼 대소문자만 다른 리네임은 "Permission denied" 또는 "이미 존재함" 에러로 실패하거나, 파일시스템 레벨에서 무시될 수 있다. 임시 이름을 경유해서 2번 이동한다:

```bash
git mv "$dir" "$parent/__tmprename__${base}"
git mv "$parent/__tmprename__${base}" "$parent/$kebab"
```

이걸 대소문자 변경이 포함된 모든 리네임에 일괄 적용하면 안전하다 (하이픈 추가만으로 이름이 달라지는 경우는 1단계로도 되지만, 구분해서 처리하느니 전부 2단계로 통일하는 게 간단하고 안전하다).

### B4. import/export 경로 일괄 수정

디렉토리를 다 옮기고 나면 상대 경로로 그 디렉토리를 참조하던 모든 `import`/`export ... from`/`require()` 문자열이 깨진다. 이름 기반 치환은 위험하다 — 예를 들어 `Button`을 아무 데서나 치환하면 `FloatButton`처럼 그 이름을 포함하는 **다른** 이름까지 잘못 건드릴 수 있다.

**경로 세그먼트 경계를 지키는 치환**을 쓴다: 슬래시(`/`)나 따옴표(`'`/`"`) 사이에 정확히 그 이름 하나만 있을 때만 바꾼다. Node 스크립트로 처리하는 걸 권장한다 (정규식 하나로 모든 `from '...'` / `require('...')`을 찾아, 경로를 `/`로 split한 뒤 각 세그먼트를 매핑 테이블과 정확히 일치할 때만 치환):

```js
const importRe = /(from\s+|require\()(['"])(\.[^'"]*)\2/g;
// 매치된 specifier를 '/'로 split → 각 세그먼트가 매핑 테이블에 있으면 교체 → 재조합
```

이 방식이면 이름 충돌(같은 leaf 이름이 여러 부모 아래 중복되는 경우 등)이나 부분 문자열 오염(`Button` vs `FloatButton`) 걱정 없이 안전하게 처리된다.

**주의**: 매핑 테이블은 이번에 실제로 리네임한 디렉토리 이름만 포함해야 한다. 우연히 같은 이름을 가진, 리네임 범위 밖의 다른 디렉토리(예: 컴포넌트 트리 밖의 provider 폴더)까지 잘못 바뀔 수 있으니, 스크립트 실행 후 typecheck에서 나오는 에러를 반드시 하나하나 확인한다.

### B5. 흩어진 하드코딩 경로 확인

`import`문 말고도 빌드 설정(`tsdown.config.ts`, `vite.config.ts`, `rollup` entry 등), `package.json`의 `exports`/`main`/`types`, 코드 제너레이터 템플릿에 리네임 대상 경로가 하드코딩돼 있을 수 있다. 저장소 전체에서 검색해서 놓친 게 없는지 확인한다.

### B6. 검증

- typecheck (`tsc -b` 등) — 대소문자 전용 파일시스템에서는 "Already included file name ... differs ... only in casing" (TS1261) 에러로 남은 불일치를 정확히 잡아준다. 이 에러 목록이 곧 안 고친 곳의 체크리스트다.
- lint, build까지 전체 실행해서 최종 확인한다.
- 스토리북 등 glob 기반 설정(`stories: ['../stories/**/*.stories.tsx']`)은 와일드카드라 대소문자 변경에 영향받지 않는다 — 별도 수정 불필요.

### B 엣지 케이스

- **같은 leaf 이름이 여러 부모 아래 중복됨** (예: `Item`이 `Menu/Item`, `List/Item`에 각각 존재): 이름 기반 매핑이라도 세그먼트 경계를 지키면 문제없다 — 어차피 같은 변환 함수를 적용하므로 결과가 항상 일관된다.
- **범위 밖인데 이름이 겹치는 디렉토리가 있음**: 매핑 테이블에 포함하지 말고, 혹시 스크립트가 잘못 건드렸으면 typecheck 에러로 발견해서 되돌린다.
- **public export 이름까지 바꿔야 하는지 애매함**: 추측하지 말고 사용자에게 breaking change 여부를 확인한다.

---

## C. 주석 작성

주석은 **지금 코드를 처음 읽는 사람**을 위해 쓴다. 이 코드를 고친 당시의 리뷰어가 아니다. 과거에 무엇이 잘못됐고 어떻게 고쳤는지는 git 기록과 이슈에 이미 남아 있다. 영어가 모국어가 아닌 사람이나 번역 도구로 읽는 사람도 바로 이해할 수 있어야 한다.

### C1. 규칙

1. **무엇을 하는지 먼저** 1~2문장으로 쓴다. 이름과 코드만 봐도 분명하면 주석을 달지 않는다.
2. **이유는 코드만 보면 잘못 고치기 쉬울 때만** 쓴다. 과거 이야기가 아니라 지금 지켜야 할 제약을 현재형으로 쓴다 ("Don't add `onChange` here: a callback must come from the current render (#336).").
3. **과거 이야기는 이슈 번호 하나로** 대신한다. "used to", "previously", "the previous implementation", "before #N", "no longer", "any more" 같은 표현을 쓰지 않는다. `(#450)`이면 충분하다.
4. **평이한 단어와 짧은 문장**을 쓴다. 관용 표현("funnelled", "churn", "dead end", "for free")은 피한다.
5. **공개 API 주석은 완전하게 둔다.** props, 공개 인터페이스의 필드, 반환 타입 설명은 사용자를 위한 계약이므로 값, 기본값, 상호작용을 빠짐없이 쓴다. 과거 이야기만 뺀다.
6. **벤치마크 수치, 검토했다 버린 대안, 다른 파일의 옛 버전 이야기**는 주석에 남기지 않고 PR이나 이슈에 쓴다.

### C2. 예시

```ts
// 전: 과거 이야기가 대부분이다
// Uncontrolled usage (`<Live.Dnd />` with no `value`) used to read
// nothing but DEFAULT_TEMPLATE forever: every edit committed through
// useSectionDocument writes into PreviewContext, but this component
// never read `code` back — so the section a reader just dragged in
// vanished on the very next render. ...
const value = _value === undefined ? code : _value;

// 후: 지금 무엇을 하는지
// The host's `value` when it passes one (controlled), otherwise the
// provider's code. An empty string counts as a value, as in `Live.Preview`.
const value = _value === undefined ? code : _value;
```

```ts
// 전: 이유를 이야기로 설명한다
// Deliberately no `onChange`: a callback belongs to the render that made
// it, not to the parse. Keeping the two in one memo is what caused #336 —
// editing another section leaves `selectedCode` ... identical, so the memo
// was reused and handed back callbacks still bound to the previous document ...

// 후: 지켜야 할 제약과 이슈 번호
// One entry per bound property, from `fields` alone. Don't add `onChange`
// here: a callback must come from the current render, and this memo can
// outlive it (#336).
```

### C3. 기존 주석을 다시 쓸 때

- **코드는 바꾸지 않는다.** 주석만 바꾸는 PR에 동작 변경을 섞지 않는다.
- **코드가 그대로인지 확인한다.** 수정 전후 파일을 주석 없이 트랜스파일해서 비교한다(예: TypeScript `transpileModule`에 `removeComments: true`). 출력이 같아야 한다.
- **실제 코드와 어긋난 주석은 이번에 고친다.** 다시 쓰다 보면 예전 버전을 설명하는 주석이 나온다. 코드를 읽고 지금 동작에 맞게 쓴다.
- **줄 수와 과거 이야기 표현 수를 전후로 세어** PR에 적는다.
- **영역 단위로 PR을 나눈다.** 한 PR에 리뷰할 수 있는 만큼만 넣는다.

### C 엣지 케이스

- **우회 코드(workaround)**: 외부 라이브러리 버그 때문에 이상해 보이는 코드는 이유를 남긴다. 다만 "무엇을 우회하는지"와 "없애도 되는 조건"을 현재형으로 쓰고, 발견 경위는 이슈로 보낸다.
- **이슈 번호가 없는 과거 이야기**: 이야기를 지우고 제약만 남긴다. 제약도 없다면 주석을 지운다.
- **저장소 언어**: 주석 언어는 저장소 관례(기존 주석)를 따른다. 판단할 주석이 없으면 영어로 쓴다. 한국어 설명이 필요하면 코드가 아니라 문서(`README.ko.md`, `ARCHITECTURE.ko.md` 등)에 둔다. 한국어 주석을 쓰는 저장소에도 C1의 규칙을 같은 취지로 적용한다("예전에는", "이제는" 같은 과거 이야기 표현 금지).

---

## D. boolean 이름 짓기

boolean은 쓰이는 자리에 따라 이름 짓는 방식이 다르다. React 문서, React와 주요 라이브러리가 돌려주는 값(`useTransition`의 `isPending`, TanStack Query의 `isLoading`, dnd-kit의 `isOver`), HTML 속성이 모두 이 방식을 따른다. 저장소에 다른 규칙이 문서로 정해져 있으면 그쪽을 따른다(섹션 A).

### D1. 규칙

| 자리                       | 형태                                    | 예                                                  |
| -------------------------- | --------------------------------------- | --------------------------------------------------- |
| 값, 상태, 반환 객체의 필드 | `is`/`has`/`can`/`should` + 형용사·분사 | `const [isOpen, setIsOpen]`, `isMobile`, `hasError` |
| 컴포넌트 prop, HTML 속성   | 접두사 없는 형용사                      | `open`, `disabled`, `checked`, `autoHeight`         |
| 판별 함수                  | `isX(value)`, `hasX(value)`             | `isPlainObject(value)`, `isVisuallyHidden(style)`   |

- prop은 `open`, 그 prop으로 만든 내부 상태는 `isOpen`으로 둔다. 이름이 겹치지 않으니 `_open`, `openProp` 같은 별칭이 필요 없다.
- prop이 처음 한 번만 쓰이는 초기값이면 `defaultOpen`처럼 `default` 접두사를 붙인다(React의 `defaultValue`, `defaultChecked`).
- `_`로 시작하는 이름은 "쓰지 않는 변수"로 남겨 둔다. ESLint `no-unused-vars`는 흔히 `^_`를 무시하도록 설정하므로, 쓰는 변수에 `_`를 붙이면 나중에 안 쓰게 됐을 때 경고가 나오지 않는다.

### D 엣지 케이스

- **공개 API 이름은 바꾸지 않는다.** 규칙과 다른 공개 이름이 있어도 메이저 버전 전에는 그대로 두고, 내부 변수만 규칙을 따른다.
- **외부 라이브러리가 정한 이름**은 그대로 쓴다.
- **접두사 없는 이름이 boolean으로 읽히지 않을 때**(`empty`, `primitive`, `quoted`)는 특히 `is`를 붙인다. 값인지 boolean인지 이름만으로 알 수 있어야 한다.
- **기존 이름을 이 규칙에 맞추려고 일괄 변경하지 않는다.** 새로 쓰거나 고치는 코드에 적용한다. 일괄 변경은 사용자가 요청할 때만 한다.

---

## E. 조건문은 항상 중괄호 블록으로 작성

사용자가 명시적으로 정한 개인 전역 규칙: **중괄호 없는 한 줄짜리 `if`/`else`를 쓰지 않고, 문장이 하나뿐이어도 항상 `{ }` 블록으로 감싼다.** 이 규칙은 A4의 "저장소 기존 패턴 우선" 원칙보다 우선한다 — 저장소에 중괄호 없는 `if`가 섞여 있어도 새로 쓰거나 직접 고치는 조건문에는 이 규칙을 적용한다.

### E1. 적용 범위

- 새로 작성하는 `if` / `else if` / `else` 블록:

  ```ts
  // 지양
  if (!user) return null;

  // 지향
  if (!user) {
    return null;
  }
  ```

- 기존 코드를 고치면서 그 조건문 자체(조건식이나 분기 로직)를 건드리면 함께 중괄호로 정리한다.
- 조건문은 그대로 두고 근처 코드만 고칠 때는 이 규칙 때문에 diff를 넓히지 않는다. 일괄 정리 PR은 사용자가 요청할 때만 만든다.

### E2. 대상이 아닌 것

- 삼항 연산자 (`cond ? a : b`)
- 논리 연산자 단축 평가 (`cond && doSomething()`)
- `switch`의 `case` 라벨

### E3. 저장소 린트 규칙과 충돌할 때

저장소 린트 설정(예: ESLint `curly`를 다른 옵션으로 설정)이 이 스타일을 에러로 잡으면 저장소 설정을 따르고, 충돌한다는 사실을 사용자에게 알린다.

---

## F. 서브컴포넌트가 있는 컴포넌트의 파일 구조

`Checkbox.Group`, `Error.Boundary`처럼 서브컴포넌트를 갖는 컴포넌트는 서브컴포넌트마다 **파일 하나만 감싼 중첩 폴더**(`group/index.tsx`)를 만들지 않고 **같은 depth의 형제 파일**로 두며, `index.ts`는 로직 없는 **순수 배럴**로 둔다. 컴포넌트 폴더가 커져 여러 기능이 섞이면 기능 단위 하위 폴더로 나눈다(섹션 I) — 이 절은 그것을 막지 않는다. 저장소마다 이 구조를 이미 쓰는지가 다르므로, 작업 전에 대상 저장소의 기존 서브컴포넌트 폴더를 보고 지금 상태를 확인한다(섹션 A3). 저장소에 다른 규칙이 문서로 있으면 그쪽을 따른다(섹션 A).

### F1. 구조

```
checkbox/
├── checkbox.tsx  # 메인 구현 (서브컴포넌트 부착 로직 없음)
├── group.tsx     # 서브컴포넌트 — 원래 export 이름 그대로 (Group)
└── index.ts      # 순수 배럴, 구현 없음
```

- 폴더·파일명은 kebab-case, export 식별자(컴포넌트·Props)는 PascalCase를 유지한다. 둘은 별개다.
- 서브컴포넌트 파일명은 접두어 없이 짧은 이름을 쓴다(`group.tsx`). `checkbox/group.tsx`와 `radio/group.tsx`처럼 겹쳐도 폴더 경로가 구분해 준다.
- 서브컴포넌트가 없는 단순 컴포넌트는 폴더 없이 `{kebab-name}.tsx` 파일 하나로 둔다.
- 서브컴포넌트에 또 서브컴포넌트가 있으면 같은 규칙을 재귀 적용한다(`menu/item/item.tsx` + `menu/item/label.tsx` + `menu/item/index.ts`).

### F2. 배럴은 교차 타입 캐스팅으로 부착한다

import한 바인딩에 `Main.Sub = Sub`를 바로 대입하면 `TS2339: Property 'Sub' does not exist` 에러가 난다. TypeScript의 expando property 지원은 같은 파일에서 선언한 함수에만 적용되기 때문이다:

```ts
// checkbox/index.ts
import CheckboxImpl, { type Props } from './checkbox';
import Group from './group';

type CheckboxComponent = typeof CheckboxImpl & { Group: typeof Group };

const Checkbox = CheckboxImpl as CheckboxComponent;

Checkbox.Group = Group;

export default Checkbox;
export type { Props };
```

- 구현 파일(`checkbox.tsx`)의 export 식별자는 그대로 둔다. 배럴에서 붙이는 `CheckboxImpl` 별칭은 합성용 변수 `const Checkbox`와 이름이 겹치지 않게 하려는 것뿐이다.
- 정적 합성이 없으면 배럴은 재export 한 줄이면 된다: `export { default, type FrameProps } from './frame';`
- 내부에서만 쓰이거나 subpath로 직접 import되는 하위 파일은 억지로 배럴에 재export하지 않는다.

이 구조를 쓰는 이유:

- 서브컴포넌트를 `group/index.tsx`처럼 중첩 폴더에 두면 부모를 `import Checkbox from '..'`로 역참조하게 되어 폴더 이동에 약하고 순환 참조처럼 보인다. 형제 파일은 `./checkbox`로 참조한다.
- `index.tsx`가 구현까지 맡으면 에디터 탭과 스택 트레이스에 `index.tsx`만 여러 개 떠서 구분이 안 된다.

### F3. 기존 중첩 구조를 이 구조로 옮길 때

섹션 B 절차(깊은 것부터, `git mv`, 경로 세그먼트 치환, typecheck 검증)를 따르고 그룹마다 다음을 더한다:

1. `git mv Parent/SubPart/index.tsx Parent/sub-part.tsx`로 서브컴포넌트를 부모 레벨로 올리면서 kebab-case로 바꾼다.
2. `git mv Parent/index.tsx Parent/parent-name.tsx`로 부모 구현을 옮긴다.
3. 옮긴 부모 구현에서 합성 대입문(`X.Y = Z;`)과 그 재export만 지운다. **렌더링에 실제로 쓰는 import는 남긴다**(예: `editor.tsx`가 `<Core />`를 렌더링하거나, `Layout`이 `child.type === Sider`로 타입을 확인하는 경우).
4. F2 패턴으로 새 `index.ts`를 쓴다.
5. 그룹 안의 상대 경로를 고친다. 부모 관계(`..`, `../field`)가 형제 관계(`./error`, `./field`)로 바뀐다.
6. 마지막으로 그룹 디렉토리 이름을 kebab-case로 바꾼다.
7. typecheck/lint/test/build 후, 각 `index.ts`를 직접 읽어 원래 합성되던 정적 프로퍼티와 재export 타입이 모두 남아 있는지 확인한다.

### F 엣지 케이스

- **JSX가 없는 하위 모듈**(`createContext`만 있는 파일 등)은 확장자를 `.ts`로 바꿔도 된다.
- **`.astro` 컴포넌트**는 배럴 재export 문법이 달라서 F2 패턴을 그대로 쓰지 않는다. `.tsx`/`.ts` 컴포넌트에만 적용한다.
- **기존 코드를 소급해서 일괄 변경하지 않는다.** 범위(컴포넌트 하나인지 전체 재정렬인지)를 사용자에게 확인한 뒤 F3를 따른다.

---

## G. 문장 덩어리 사이 빈 줄

사용자가 정한 개인 전역 규칙(ESLint `padding-line-between-statements`, `newline-before-return` 에 해당): 의미가 바뀌는 경계에 빈 줄을 넣어 덩어리를 끊는다. 섹션 E 와 마찬가지로 A4의 "이웃 파일 우선"보다 우선한다.

### G1. 빈 줄을 넣는 경계

- 선언·계산 → 그 값을 쓰는 코드
- 연속된 가드절 사이
- 블록 안의 부수효과(로그 등) → `return`
- `return` 문 앞 (블록의 첫 문장이면 제외)

```ts
// 지양
const handler = handlers[eventName];
if (typeof handler !== 'function') {
  console.warn(`No handler for "${eventName}"`);
  return;
}

// 지향
const handler = handlers[eventName];

if (typeof handler !== 'function') {
  console.warn(`No handler for "${eventName}"`);

  return;
}
```

### G2. 지킬 것

- 빈 줄은 1줄만 쓴다(2줄 이상은 Prettier 가 압축한다).
- **한 덩어리로 읽히는 문장들은 붙여 둔다.** 모든 문장 사이에 빈 줄을 넣으면 경계 표시가 의미를 잃는다.
- 적용 범위는 섹션 E 와 같다. 새로 쓰거나 고친 코드에만 적용하고, 손대지 않은 주변 코드는 이 규칙 때문에 diff 를 넓히지 않는다. 저장소 린트 설정과 충돌하면 저장소 설정을 따르고 사용자에게 알린다.

---

## H. 컴포넌트 내부 코드 순서

사용자가 정한 개인 전역 규칙이다. React 공식 규칙([Rules of Hooks](https://react.dev/reference/rules/rules-of-hooks))은 훅을 최상위에서 early return 보다 먼저 호출하라는 것만 정하고, `eslint-plugin-react` 의 `react/sort-comp` 는 클래스 컴포넌트의 메서드 순서에만 적용된다. 함수 컴포넌트 안의 순서를 정하는 표준 린트 규칙은 없으므로(2026-10 확인) 아래 순서를 기본값으로 쓴다. 저장소 린트 설정이나 스타일 문서가 다른 순서를 정했으면 그쪽을 따른다(섹션 A4).

### H1. 순서

1. **외부 훅** — context, router, 데이터 조회, 커스텀 훅
2. **상태·ref** — `useState`, `useReducer`, `useRef`
3. **파생 값** — 계산 값, `useMemo`
4. **함수** — 이벤트 핸들러, `useCallback`
5. **이펙트** — `useEffect`, `useLayoutEffect`
6. **early return**
7. **JSX 반환**

그룹 사이에는 빈 줄을 한 줄 넣는다(섹션 G 의 "선언 → 그 값을 쓰는 코드" 경계).

```tsx
export function SearchPanel({ initialQuery, onSelect }: Props) {
  const router = useRouter();
  const { data: items = [] } = useSearchItems();

  const [query, setQuery] = useState(initialQuery);
  const inputRef = useRef<HTMLInputElement>(null);

  const filtered = useMemo(
    () => items.filter((item) => item.name.includes(query)),
    [items, query],
  );

  const handleSelect = useCallback(
    (id: string) => {
      onSelect(id);
      router.push(`/items/${id}`);
    },
    [onSelect, router],
  );

  useEffect(() => {
    inputRef.current?.focus();
  }, []);

  if (filtered.length === 0) {
    return <EmptyState />;
  }

  return (
    <SearchList
      inputRef={inputRef}
      items={filtered}
      query={query}
      onQueryChange={setQuery}
      onSelect={handleSelect}
    />
  );
}
```

### H2. 순서보다 먼저 지킬 것

순서는 취향이지만 아래 둘은 동작 조건이라 순서와 충돌하면 이쪽이 우선이다.

- **모든 훅 호출은 early return 보다 앞에 둔다.** Rules of Hooks 위반이며, 렌더마다 훅 호출 수가 달라져 React 가 에러를 낸다.
- **쓰기 전에 선언한다.** 이펙트·`useMemo`·`useCallback` 의 의존성 배열은 렌더 중에 평가되므로, 거기 넣는 값과 함수는 그보다 위에 선언해야 한다(아래에 있으면 `const` 가 초기화되기 전이라 ReferenceError). 커스텀 훅이 상태를 인자로 받는 경우처럼 그룹 순서와 데이터 의존이 어긋나면, 의존하는 쪽을 뒤로 보낸다.

### H 엣지 케이스

- **적용 범위**: 새로 쓰거나 구조를 크게 고치는 컴포넌트에 적용한다. 손대지 않은 컴포넌트를 순서만 이유로 재정렬하지 않는다(diff 와 blame 을 흐린다). 일괄 재정렬은 사용자가 요청할 때만 하고, 동작 변경과 같은 커밋에 섞지 않는다.
- **커스텀 훅**: 같은 순서를 쓰고, 마지막 반환이 JSX 대신 값이다.
- **클래스 컴포넌트**: 이 절 대신 `react/sort-comp` 의 기본 순서를 따른다.

---

## I. 커진 폴더를 기능 단위 하위 폴더로 나누기

사용자가 정한 개인 전역 규칙이다. 한 폴더에 컴포넌트·훅·유틸·테스트가 평평하게 쌓여 한눈에 구조가 보이지 않으면, **화면 영역이나 사용자 기능 단위**로 하위 폴더를 만든다. 기술 유형(`components/`, `hooks/`, `utils/`, `types/`)으로 나누지 않는다 — 한 기능을 고칠 때 여러 폴더를 오가게 되고, 폴더 이름이 무엇을 하는 코드인지 말해 주지 않는다(FSD 가 `hooks`·`types` 같은 세그먼트명을 피하는 것과 같은 이유). 저장소에 다른 구조 규칙이 문서로 있으면 그쪽을 따른다(섹션 A).

섹션 F 의 "서브컴포넌트는 형제 파일로"는 **파일 하나만 감싼 폴더**(`group/index.tsx`)를 만들지 말라는 규칙이다. 이 절의 기능 폴더는 여러 파일을 묶으므로 그 규칙과 충돌하지 않는다.

### I1. 나눌 때

- 폴더 안에 **서로 다른 화면 영역이나 기능이 두 개 이상** 섞여 있다. 파일 이름의 공통 접두어(`item-*`, `use-dnd-items`, `items-*`)나 서로만 import 하는 파일 묶음이 단서다.
- 점검 신호(규칙이 아니다): 테스트를 뺀 소스 파일이 10개를 넘으면 위 조건에 해당하는지 본다. 개수만으로 나누지 않는다 — 한 기능만 있는 폴더는 커도 그대로 둔다.

### I2. 나누는 기준과 이름

- **하위 폴더 하나 = 화면 영역 하나 또는 사용자 기능 하나.** 그 영역의 컴포넌트와, 그 영역에서만 쓰는 훅·유틸·타입·테스트를 함께 넣는다.
- **이름은 그 영역·기능의 이름**을 kebab-case 로 쓴다(`items/`, `fields/`, `selection/`). 그 영역을 대표하는 컴포넌트가 있으면 폴더명과 같은 이름으로 둔다(`items/items.tsx`, 전역 지침의 "폴더명 = 파일명 반복"). 훅·유틸 묶음처럼 대표 파일이 없는 폴더(`state/`)는 그대로 둔다.
- **테스트는 대상 파일과 같은 폴더**로 옮긴다. 여러 영역을 함께 검증하는 테스트는 부모 폴더에 남긴다.
- **부모 폴더 루트에 남기는 것**: 진입 컴포넌트(`panel.tsx`), 공개 배럴 `index.ts`, 여러 하위 폴더가 함께 쓰는 타입·유틸.
- **파일이 하나뿐인 영역은 폴더를 만들지 않는다**(배럴 규칙의 "단일 파일만 감싸는 폴더 금지"). 루트에 두고, 같은 영역 파일이 생기면 그때 폴더로 묶는다.

### I3. import 와 배럴

- **하위 폴더에 `index.ts` 를 둘지는 저장소 관례를 따른다.** 같은 저장소에 이미 나뉜 하위 폴더가 있으면 그 방식을 본다(섹션 A3).
- 관례가 없으면 **하위 폴더 배럴을 두지 않고 파일을 직접 import 한다**(`./items/use-dnd-items`). 부모 폴더 안에서만 쓰이는 묶음에 배럴을 두면 파일 수와 순환 참조 위험만 늘어난다.
- 하위 폴더에 배럴을 두는 저장소라면, 폴더 밖에서 쓰는 것만 재export 하고, 폴더 안 파일끼리는 자기 `index.ts` 를 거치지 않고 파일을 직접 import 한다(자기 배럴을 거치면 순환 참조가 생기기 쉽다).
- **하위 폴더끼리의 의존은 한 방향**으로 둔다. 두 폴더가 서로를 import 하면, 함께 쓰는 부분을 부모 루트로 올린다.
- 부모 폴더의 `index.ts` 가 공개하는 것은 바꾸지 않는다. 배치만 바뀌고 공개 API 는 그대로여야 한다.

### I4. 기존 폴더를 옮길 때

섹션 B 절차(`git mv` 로 히스토리 보존, 경로 세그먼트 경계를 지키는 import 치환, typecheck 검증)를 따르고 다음을 더한다:

1. **import 관계부터 확인한다.** 파일 이름만 보고 묶지 않는다. 각 파일이 누구를 import 하고 누구에게 import 되는지 보고, 영역을 나눈 안을 사용자에게 먼저 보인다.
2. **폴더 밖에서 하위 경로로 직접 가져오는 곳**을 찾는다(`git grep -n "<폴더 경로>/" -- src`). 테스트 파일이나 다른 컴포넌트가 `panel/children` 처럼 직접 import 하면 함께 고친다. `package.json` `exports` 에 노출된 경로면 섹션 B0 대로 breaking change 여부를 사용자에게 확인한다.
3. **배치만 바꾸는 커밋**으로 낸다. 동작 변경, export 식별자 이름 변경, 리팩터링을 섞지 않는다. 폴더로 옮기면서 파일명에서 폴더명과 겹치는 접두어를 빼는 것(`select-multiple.tsx` → `select/multiple.tsx`)은 배치에 포함된다(섹션 F 의 짧은 서브컴포넌트 파일명).
4. typecheck/lint/test/build 를 돌리고, 부모 `index.ts` 의 공개 export 가 전과 같은지 직접 읽어 확인한다.

### I 엣지 케이스

- **소급해서 일괄 재배치하지 않는다.** 새로 만드는 폴더와, 사용자가 요청했거나 지금 작업으로 크게 손대는 폴더에 적용한다.
- **어느 영역에도 딱 속하지 않는 파일**(행 단위 컨트롤 등): 쓰는 영역이 하나면 그 폴더로, 둘 이상이면 부모 루트에 둔다.
- **FSD 프로젝트**: 슬라이스·세그먼트 구조가 우선이다. 이 절은 세그먼트(`ui/` 등) 안이 커졌을 때 그 안을 나누는 데만 쓴다.
