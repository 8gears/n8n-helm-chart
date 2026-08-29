## Contribution Guide

1. Make your changes
2. Write your commits using [Conventional Commits](https://www.conventionalcommits.org/). Release Please derives the next chart
   version from them, so `fix:` produces a PATCH, `feat:` a MINOR, and `feat!:` or a `BREAKING CHANGE:` footer a MAJOR. Pick the
   type that matches the [Chart Versioning Schema](#chart-versioning-schema).
3. Update `appVersion` in `Chart.yaml` if your change ships a new n8n version. Leave `version` alone, Release Please bumps it.
4. In `Chart.yaml`, replace the content of the `artifacthub.io/changes` section. See the ArtifactHub [annotation reference](https://artifacthub.io/docs/topics/annotations/helm/).
5. Run Chart-Testing  `make lint`
6. Install the charts and examples locally to see if they work
7. Submit your PR
8. Once it is merged, Release Please opens a `chore: release X.Y.Z` PR that bumps `version` in `Chart.yaml`. Merging that PR tags
   the release and publishes the chart to the OCI registry. Do not bump `version`, push a tag, or create a GitHub release by hand,
   Release Please owns all three. See [docs/RELEASES.md](docs/RELEASES.md).


## Chart Versioning Schema

The versions of the chart follow this schema:
* MAJOR version for backward-incompatible changes (e.g., `values.yaml` structural changes, output changes for the same given input).
* MINOR version when functionality is added in a backward-compatible manner (additions to the chart that will render the same output if the feature is not enabled).
* PATCH version for backward-compatible bug fixes and app version updates.


## Changelog

You can find the changelog in the [release notes](https://github.com/8gears/n8n-helm-chart/releases)
or the [ArtifactHub change log](https://artifacthub.io/packages/helm/open-8gears/n8n?modal=changelog).

