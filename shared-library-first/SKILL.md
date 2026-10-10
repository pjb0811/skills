---
name: shared-library-first
description: "In the pjb0811 projects, build reusable UI in ui-kit and reusable React hooks in use-hooks first, release them, then consume the published package from the app repository (live-editor, pjb0811.github.io, …) instead of implementing them inline. Covers how to judge reusability, the order of work across repositories, and edge cases (extending an existing hook, prototyping locally, splitting UI from logic). Use when adding a component or hook to an app repository that another project could also use, or when the user says '공유 라이브러리로', 'ui-kit에 먼저', 'use-hooks로 빼줘'."
---

# Shared Library First

새 컴포넌트나 기능을 구현할 때, 그 안의 UI 요소나 훅이 지금 저장소 밖에서도 쓰일 수 있으면 앱 저장소에 바로 구현하지 않고 **공유 라이브러리에 먼저 구현한다.**

- UI 컴포넌트 → `pjb0811/ui-kit`
- React 훅 → `pjb0811/use-hooks` (`@jbpark/use-hooks`)

라이브러리에서 머지하고 배포한 뒤, 앱 저장소는 그 패키지를 의존성으로 추가해서 쓴다.

## 1. 판단 기준

만들기 전에 묻는다: "이게 지금 프로젝트 말고 다른 프로젝트에서도 쓸모가 있나?"

- **그렇다 / 애매하다** → 공유 라이브러리 경로를 기본값으로 제안한다.
- **아니다, 이 앱의 도메인에 묶여 있다**(예: live-editor의 AST 변환 로직) → 앱 저장소에 구현한다. 억지로 추상화하지 않는다.

재사용 신호:

- 도메인 로직 없는 UI 프리미티브나 합성 컴포넌트(버튼, 입력, 피커, 레이아웃) → `ui-kit`
- 도메인 로직 없는 상태·이벤트·브라우저 API 훅(디바운스, localStorage, 히스토리 상태, 스크롤) → `use-hooks`

## 2. 작업 순서

1. 라이브러리 저장소에서 새 브랜치로 구현한다. 그 저장소의 컨벤션을 먼저 파악한다(`coding-style` 섹션 A).
2. 테스트·데모·스토리 등 라이브러리의 관례대로 추가한다.
3. PR을 올리고 머지한다. 앱에서 쓰려면 npm 배포까지 끝났는지 확인한다(`changesets-release`).
4. 앱 저장소로 돌아와 새 버전을 의존성으로 추가하고 가져다 쓴다.
5. 앱 저장소 PR에는 "라이브러리 X에 Y를 추가했고 여기서 그걸 쓴다"는 게 드러나야 한다. 로컬 구현과 섞지 않는다.

예: live-editor에 undo/redo를 넣을 때(2026-07-28) `useHistoryState`를 use-hooks에 구현하고 배포한 뒤 live-editor가 새 버전을 의존성으로 추가했다. 같은 세션에서 live-editor가 직접 갖고 있던 `useDebounce`도 use-hooks 구현으로 바꿨다.

## 엣지 케이스

- **비슷한 게 이미 있지만 똑같지 않다**: 새로 만들기 전에 기존 것을 확장하거나 일반화할 수 있는지 먼저 본다.
- **먼저 써 봐야 검증되는 경우**: 앱 저장소에서 임시로 프로토타이핑해도 되지만, 검증되면 라이브러리로 옮기는 후속 작업을 사용자에게 남긴다. 임시 구현이 그대로 남지 않게 한다.
- **UI와 훅이 함께 필요하다**: 렌더링이 주된 산출물이면 `ui-kit`, 상태·로직이 주된 산출물이면 `use-hooks`. 둘 다 필요하면 나눠서 각각 넣는다.
