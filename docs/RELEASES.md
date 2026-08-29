# Release Process

Chart releases are automated with [release-please](https://github.com/googleapis/release-please). Never edit
`version` in `charts/n8n/Chart.yaml`, never push a tag, and never create a GitHub Release by hand;
release-please owns all three.

Release state is defined by conventional commits on `main`, `release-please-config.json` and
`.release-please-manifest.json`.

## How It Works

1. A pull request is merged to `main` with a conventional commit subject.
2. That push to `main` opens or updates a `chore: release X.Y.Z` pull request, which bumps `version` in
   `charts/n8n/Chart.yaml` and `.release-please-manifest.json`.
3. Merging that pull request creates the `X.Y.Z` tag and the GitHub Release, whose body is the generated
   release notes.
4. `release-please.yml` then calls `publish-chart.yml`, which packages the chart at that tag and pushes it to
   `oci://8gears.container-registry.com/library`.

| Commit type | Version bump | Release notes |
|-------------|--------------|---------------|
| `feat:` | Minor | Features |
| `fix:` | Patch | Bug Fixes |
| `feat!:`, `fix!:`, or a `BREAKING CHANGE:` footer | Major | Breaking Changes |
| `perf:`, `revert:`, `docs:`, `refactor:` | Patch | Own section |
| `ci:`, `chore:`, `build:`, `style:`, `test:` | None on their own | Not shown |

Both columns are set by `changelog-sections` in `release-please-config.json`, and the second drives the first.
A section marked `hidden: true` contributes no lines to the release notes, and release-please skips the
release outright when the notes come out empty. So the rule is about the release notes, not the commit type:

- A push of only hidden types (`chore:`, `ci:`, ...) releases nothing.
- A push containing **any** visible commit cuts a release, and the bump is minor for `feat:`, major for a
  breaking change, and patch for everything else.
- To make a type releasable, give it a visible section. To stop a change releasing regardless of its type,
  add its path to `exclude-paths`.

`exclude-paths` is set to `.github` and `docs`, so a change confined to CI or to this directory does not cut a
release. `README.md` sits outside it on purpose: the publish workflow copies it into the chart package, so it
ships with the artifact.

Confirm the bump you expect with a dry run before relying on it:

```bash
npx release-please release-pr --dry-run \
  --repo-url=8gears/n8n-helm-chart --config-file=release-please-config.json \
  --manifest-file=.release-please-manifest.json
```

## The Version Baseline

release-please finds the previous release by looking for the tag matching the version in
`.release-please-manifest.json`. **The manifest version and the newest release tag must agree.** When they do
not, release-please finds no previous release, walks the whole history, and replays old commits into the next
release notes. Tags in this repository carry no `v` prefix (`2.1.0`, not `v2.1.0`), which is what
`include-v-in-tag: false` and `include-component-in-tag: false` produce.

`charts/n8n/Chart.yaml` must agree with both. `publish-chart.yml` refuses to publish when the packaged chart
version does not match the tag it was asked to build.

## No CHANGELOG.md

`skip-changelog: true` keeps release-please out of `CHANGELOG.md`, which stays a pointer to the GitHub
Releases and the [ArtifactHub changelog](https://artifacthub.io/packages/helm/open-8gears/n8n?modal=changelog).
Per-release user-facing notes live in the `artifacthub.io/changes` annotation in `Chart.yaml`, which the
contributor updates in the same pull request as the change. Release notes on the GitHub Release are still
generated from the commits.

## Chart.yaml Gets Reformatted Once

release-please rewrites `Chart.yaml` through a YAML round-trip, so the first release it cuts re-wraps the long
`description` value across several lines. The result is equivalent YAML and it happens only once.

## The Release Pull Request Gets No Workflow Runs

GitHub raises no workflow events for a ref pushed with `GITHUB_TOKEN`. release-please opens its
`chore: release X.Y.Z` pull request with exactly that token, so **that pull request gets zero workflow runs** -
no lint, no chart-testing, no title check.

The same rule applies to the tag release-please creates, which is why `publish-chart.yml` has no `push: tags`
trigger and is called directly from `release-please.yml` instead.

This matters the moment a branch ruleset requires a status check: the release pull request waits for a context
that will never be reported and can never be merged. To require checks, first make release-please open its
pull request as a GitHub App:

```yaml
- uses: actions/create-github-app-token@<sha>  # vX.Y.Z
  id: app-token
  with:
    app-id: ${{ vars.RELEASE_APP_ID }}
    private-key: ${{ secrets.RELEASE_APP_PRIVATE_KEY }}

- uses: googleapis/release-please-action@<sha>  # vX.Y.Z
  with:
    token: ${{ steps.app-token.outputs.token }}
```

Do not work around a blocked release pull request by pushing a tag by hand. The tag and
`.release-please-manifest.json` then disagree permanently, and every later release inherits the mismatch.

## Republishing a Chart

Use the `workflow_dispatch` on `publish-chart.yml` with the tag name. It packages and pushes an existing tag
without touching the manifest or creating a release.

## Reading the Workflow Outputs

The chart is not at the repository root, and release-please namespaces every per-release output with the
package path unless that path is `.`. The outputs are `charts/n8n--release_created`, `charts/n8n--tag_name`
and so on; the bare `release_created` and `tag_name` outputs are never set. `release-please.yml` normalizes
the two it needs into job outputs so downstream jobs do not have to care.

The action emits every property of the created release under the same prefix, among them
`charts/n8n--version`, `charts/n8n--major`, `charts/n8n--minor`, `charts/n8n--patch`, `charts/n8n--sha`,
`charts/n8n--name`, `charts/n8n--body`, `charts/n8n--html_url` and `charts/n8n--upload_url`. A new job that
needs one adds it to the `outputs:` block of the release job. The unprefixed `releases_created` and
`paths_released` outputs are the exception: the action always sets those two.

## Required Repository Settings

- Squash merging enabled.
- "Allow GitHub Actions to create and approve pull requests" enabled, otherwise release-please cannot open its
  pull request.
- `contents: write`, `pull-requests: write` and `issues: write` scoped to the release-please job. The workflow
  denies everything at the top level, so any job added there must request its own scopes.
- `REGISTRY_USER` and `REGISTRY_PASSWORD` secrets for the OCI push.
