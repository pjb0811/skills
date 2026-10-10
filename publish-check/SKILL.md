---
name: publish-check
description: "Pre-release checklist for an npm package released through changesets: confirm whether the package actually publishes (`private`, `publishConfig`, `publish.yml`), run the type check and build, compare the local version with the npm registry, check that `package.json` `exports` matches the bundler entries and the barrel exports, then report a pass/fail table that says plainly when merging the 'Version Packages' PR will publish to npm. Works in single-package repos and monorepos (checks the published package's directory). Use before merging a 'Version Packages' PR, before a release, or when the user says '/publish-check', '배포 전 점검', '퍼블리시 체크', 'publish check', 'is this ready to publish'."
---

# Publish Check

changesets로 릴리스하는 npm 패키지를 배포 전에 점검한다. 릴리스 흐름 자체(changeset → Version Packages PR → `publish.yml`)는 `changesets-release` 스킬을 따른다. 저장소에 `version-management` 스킬이 있으면 패키지 경로나 추가 점검 항목을 거기서 확인한다.

저장소의 `version-management`가 이 스킬에 넘길 값을 따로 정하면 그것을 따른다(예: ui-kit은 워크스페이스 이름 `@repo/ui`와 npm 이름 `@jbpark/ui-kit`이 다르고, 배포되는 `exports`가 `package.publish.json`에 있다).

명령은 **배포 대상 패키지 디렉터리**에서 실행한다. 단일 패키지 저장소면 루트, 모노레포면 `private: false`인 패키지(예: ui-kit의 `packages/ui`)다. 각 단계가 실패하면 내용을 보고하고 멈춘다.

## 1. 배포 여부 확인

```bash
node -p "const p=require('./package.json');JSON.stringify({name:p.name,private:p.private,publishConfig:p.publishConfig},null,2)"
ls "$(git rev-parse --show-toplevel)/.github/workflows" | grep -i publish
```

- `private: false`이고 `publish.yml`이 있으면 **Version Packages PR 머지 = npm 공개 배포**다. 6단계 요약에 반드시 적는다.
- `private: true`이거나 `publish.yml`이 없으면 npm 배포는 일어나지 않는다. 그 사실을 보고하고, 나머지는 빌드 점검으로만 진행한다.
- 저장소 문서(`version-management` 스킬, `AGENTS.md` 등)가 말하는 상태와 다르면 그 문서를 고치도록 보고한다.

## 2. 타입 체크

`package.json` scripts에서 타입 체크 스크립트(`check-types`, `typecheck` 등)를 찾아 실행한다. 패키지 매니저는 lock 파일로 정한다(`pnpm-lock.yaml` → `pnpm`, `package-lock.json` → `npm`).

## 3. 빌드

`build` 스크립트를 실행한다. 모노레포면 저장소의 방식(예: `pnpm exec turbo run build --filter=<package>`)을 따른다.

## 4. 버전 비교

```bash
node -p "require('./package.json').version"
npm view "$(node -p "require('./package.json').name")" version 2>/dev/null || echo "not published yet"
```

- 로컬 버전이 npm보다 높다: Version Packages PR이 이미 머지돼 버전이 올라간 상태다. 다음 main push에서 `publish.yml`이 배포한다.
- 같다: 배포할 변경이 아직 없다(changeset이 없거나 Version Packages PR이 머지되지 않음). `CHANGELOG.md` 맨 위 절이 현재 버전과 같은지도 본다.

## 5. 진입점 대조

```bash
node -p "Object.keys(require('./package.json').exports ?? {}).join('\n')"
```

- `exports` 키와 번들러 entry(`tsdown.config.ts`, `vite.config.ts`의 `build.lib.entry`, `rollup` input 등)가 1:1로 맞는지 대조한다. 한쪽에만 추가되면 빌드는 통과해도, 소비자가 import하지 못하거나(exports 누락) 파일이 없다(entry 누락).
- 새로 추가된 컴포넌트·훅이 진입점 배럴(`src/index.ts` 등)과 `exports`에서 빠지지 않았는지 본다.
- `exports` 값이 가리키는 파일이 빌드 결과에 실제로 있는지 확인한다.

## 6. 요약

통과/실패를 표로 정리한다. 별도 수동 배포 명령은 없다. main에 changeset이 쌓이면 Version Packages PR이 열리고, 그 PR을 머지하면 `publish.yml`이 build → `npm publish` → 태그 → GitHub Release까지 처리한다.

1단계에서 배포가 살아 있으면 요약 마지막에 **"이 PR을 머지하면 `<name>@X.Y.Z`가 npm에 실제로 배포됩니다"** 라고 쓰고, 머지 전에 사용자 확인을 받는다.
