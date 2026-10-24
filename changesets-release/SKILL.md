---
name: changesets-release
description: "Common changesets release procedure shared by the pjb0811 repositories (use-hooks, ui-kit, live-editor, workbench, pjb0811.github.io): how a changeset becomes a 'Version Packages' PR and what merging it does, checking whether that merge publishes to npm before merging, approving workflow runs stuck at 'action_required' after the changeset-draft bot pushes (mergeStateStatus stays BLOCKED), the `feat` vs `feat/*` branch-name ref conflict, and running manual npm commands that need 2FA (`npm deprecate`, `dist-tag`, `owner`) through a browser approval link. Repository specifics (package path, package manager, whether npm publish runs) live in each repository's own `version-management` skill; read that too when it exists. Use when adding a changeset, merging a 'Version Packages' PR, a PR stays BLOCKED although CI looks green, or the user says '버전 올려줘', 'release 진행', 'npm 배포', '배포해줘', 'npm deprecate'."
---

# Changesets Release

pjb0811 저장소들이 함께 쓰는 changesets 릴리스 흐름. 저장소마다 다른 부분(배포 대상 패키지 경로, 패키지 매니저, npm 배포 여부)은 그 저장소의 `.claude/skills/version-management/SKILL.md`에 있다. 있으면 같이 읽는다.

## 1. 상태 먼저 확인하기

문서에 적힌 배포 상태는 낡을 수 있다(live-editor 문서가 `private: true`라고 잘못 안내하던 적이 있다). 매번 ref 기준으로 직접 확인한다:

```bash
git fetch origin
git show origin/main:package.json | node -p "const p=JSON.parse(require('fs').readFileSync(0));({name:p.name,private:p.private,version:p.version,publishConfig:p.publishConfig})"
ls .github/workflows/                 # publish.yml 유무
npm view <package-name> version       # 레지스트리에 실제로 있는지
```

모노레포면 배포 대상 패키지의 `package.json`(예: ui-kit은 `packages/ui/package.json`)을 본다. 확인 결과가 저장소 문서와 다르면 실제 상태를 따르고, 문서가 낡았다는 사실을 근거(확인한 ref, 명령 출력)와 함께 사용자에게 보고한다. 문서를 고치는 것은 사용자가 요청할 때만 한다.

## 2. 릴리스 흐름

> 아래 워크플로·스크립트 이름과 동작은 환경 사실이다(환경 의존, 2026-10 확인: live-editor·ui-kit·use-hooks·workbench·pjb0811.github.io 의 `origin/main`). 다시 확인할 때는 `git ls-tree --name-only origin/main .github/workflows/ .github/scripts/` 로 파일을 보고, 동작은 해당 워크플로 파일을 읽는다. 여기 적힌 것과 다르면 실제 파일을 따르고 이 스킬이 낡았다고 보고한다.

1. **changeset 추가**: 사용자에게 보이는 변경이 있는 PR에는 `.changeset/*.md`가 필요하다. `changeset` CLI로 직접 만들거나, `changeset-draft.yml`(필수 상태 체크 `draft`)이 PR마다 초안을 만들고 갱신한다.
   - 봇 초안은 **최대 `minor`까지만** 쓴다(`.github/scripts/draft-bump.mjs`). 모델이 `major`를 고르면 `minor`로 낮추고 봇 커밋 메시지 끝에 `(model suggested major; capped at minor)`를 붙인다. 정말 호환성을 깨는 변경이면 사람이 초안을 `major`로 고친다(pjb0811/live-editor#457).
   - Renovate PR(`renovate/*`)은 봇이 건너뛴다. 릴리스에 넣어야 하는 의존성 변경(`peerDependencies` 범위 등)이면 changeset을 직접 추가한다.
2. **Version Packages PR**: main에 push될 때마다 `version.yml`이 누적된 changeset으로 `changeset-release/main` 브랜치에 "chore: version packages" PR을 열고 유지한다. 버전 bump와 `CHANGELOG.md` 갱신이 들어 있다.
3. **머지할 때**: 머지도 main push이므로 다른 워크플로가 이어서 돈다.
   - `publish.yml`이 있으면: 현재 버전 태그(`vX.Y.Z`)가 없을 때만 build → npm publish(OIDC Trusted Publishing, `NPM_TOKEN` 불필요) → 태그 push → `CHANGELOG.md`에서 해당 버전 절을 뽑아 GitHub Release 생성.
     - workbench는 두 가지가 다르다. 버전이 `0.0.0`이면 태그가 없어도 아무것도 하지 않는다. 현재 버전이 이미 npm에 있으면(npm이 이 워크플로를 신뢰하기 전에 손으로 한 첫 배포) publish는 건너뛰고 태그와 GitHub Release만 만든다. workbench에는 `version-management` 스킬이 없으니 `publish.yml`을 직접 읽는다.
   - `publish.yml`이 없고 `private: true`면(pjb0811.github.io): 일반 main push와 같다. 배포 워크플로(GitHub Pages 등)만 돈다.

## 3. npm에 배포되는 저장소의 머지 확인

**npm publish는 공개적이고 되돌릴 수 없다**(`npm unpublish`는 72시간 제한이 있고, 이미 받아간 사용자에게는 소용없다). 1단계에서 배포가 살아 있으면, Version Packages PR을 머지하기 전에 "지금 머지하면 npm에 `<package>@X.Y.Z`가 배포됩니다"라고 알리고 **매번 따로 확인받는다.** 사용자가 먼저 "머지해줘"라고 했더라도 다시 확인한다.

배포 후 확인:

```bash
npm view <package-name> version
npm view <package-name> dist-tags --json
gh release list --limit 3
gh run list --branch main --limit 3
```

## 4. `action_required`로 멈춘 실행 승인

필수 상태 체크는 보통 `lint-and-build`와 `draft`다(환경 의존, 2026-10 확인. 지금 값은 `gh api repos/<owner>/<repo>/rulesets` 로 확인한다).

changeset-draft 봇이 PR 브랜치에 커밋을 push하면 `synchronize`로 CI와 Changeset Draft가 다시 도는데, 이 실행이 **`conclusion: action_required`, job 0개**로 멈출 때가 있다. 문제 있는 실행이 아니라 승인을 기다리는 상태다. 필수 체크가 끝나지 않으니 `mergeStateStatus`가 `BLOCKED`로 남는다.

```bash
gh run list --branch <branch> --json databaseId,name,status,conclusion,headSha,event
gh api -X POST repos/<owner>/<repo>/actions/runs/<run_id>/approve   # CI, Changeset Draft 각각
gh run watch <run_id> --exit-status
gh pr view <n> --json mergeable,mergeStateStatus                    # CLEAN이면 머지 가능
```

## 5. 브랜치 이름

Conventional Commits 접두어를 브랜치 이름에도 쓴다: `feat/*`, `fix/*`, `refactor/*`, `chore/*`.

git은 `feat` 브랜치와 `feat/foo` 브랜치를 동시에 가질 수 없다(`refs/heads/feat`과 `refs/heads/feat/foo` 경로 충돌). 새 브랜치를 만들기 전에 `git branch -a`로 겹치는 bare 브랜치가 있는지 본다. 있으면 다른 이름을 쓰거나, 지워도 되는지 사용자에게 먼저 묻는다. 임의로 지우지 않는다.

## 6. 손으로 하는 npm 작업 (2FA)

정기 배포는 `publish.yml`이 OIDC로 하므로 로그인이나 OTP가 필요 없다. 이 절은 `npm deprecate`, `npm dist-tag`, `npm owner`처럼 손으로 실행하는 쓰기 작업에만 해당한다. 모두 공개 레지스트리를 바로 바꾸므로 대상 패키지·버전·메시지를 사용자에게 확인받은 뒤 실행한다.

> 아래 동작은 환경 사실이다(환경 의존, 2026-10 확인: npm 11.16.0, `auth-type=web`, 계정 2FA 켜짐). 다르게 동작하면 `npm --version`, `npm config get auth-type`으로 지금 환경을 확인하고 이 절이 낡았다고 보고한다.

1. **로그인 확인**: `npm whoami`가 401이면 `npm login --auth-type=web`을 실행하고, 출력된 `https://www.npmjs.com/login?next=/login/cli/...` 링크를 사용자에게 전달한다. 사용자가 브라우저에서 승인하면 CLI가 토큰을 `~/.npmrc`에 저장한다. 비밀번호나 OTP 코드를 받아서 대신 입력하지 않는다.
2. **터미널(TTY)에서 실행한다**: 터미널이 없으면(백그라운드 실행 등) npm은 2FA 승인을 기다리지 않고 `npm error code EOTP`로 바로 끝나고, 로그의 승인 링크도 `***`로 가려진다. 가상 터미널로 실행하고 로그에서 링크를 꺼내 사용자에게 전달한다. 명령이 승인될 때까지 끝나지 않으므로 첫 줄은 백그라운드로 띄우고, 둘째 줄로 로그를 읽는다.
   ```bash
   script -q -f -c 'npm deprecate <package> "<message>"; echo "exit=$?"' <log-file> < /dev/null > /dev/null
   grep -aoE 'https://www\.npmjs\.com/auth/cli/[a-f0-9-]+|exit=[0-9]+|npm error code [A-Z0-9]+' <log-file>
   ```
   승인은 **명령마다** 따로 필요하다. 패키지 여러 개를 처리하면 링크도 그만큼 나온다.
3. **반영 확인**: 직후의 `npm view`는 레지스트리 캐시 때문에 이전 값을 보여줄 수 있다. 캐시를 피해서 다시 본다.
   ```bash
   npm view <package> deprecated --prefer-online
   ```
4. **되돌리기**: `npm deprecate <package> ""`(빈 메시지)로 deprecate를 해제한다.
