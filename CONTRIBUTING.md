## Contribution Guide

1. Make your changes
2. Update the `Chart.yaml` with the new version numbers for the chart and app. Follow the [Chart Versioning Schema](#chart-versioning-schema).
3. In `Chart.yaml`, replace the content of the `artifacthub.io/changes` section. See the ArtifactHub [annotation reference](https://artifacthub.io/docs/topics/annotations/helm/).
4. Run Chart-Testing  `make lint`
5. Install the charts and examples locally to see if they work
6. Submit your PR
7. The maintainers create a new release in GitHub using the chart version number as the tag and title.


## Commit Messages
Make sure your commit messages follow the [conventional commits](https://www.conventionalcommits.org/en/v1.0.0/) style


## Chart Versioning Schema

The versions of the chart follow this schema:
* MAJOR version for backward-incompatible changes (e.g., `values.yaml` structural changes, output changes for the same given input).
* MINOR version when functionality is added in a backward-compatible manner (additions to the chart that will render the same output if the feature is not enabled).
* PATCH version for backward-compatible bug fixes and app version updates.


## Changelog

You can find the changelog in the [release notes](https://github.com/8gears/n8n-helm-chart/releases)
or the [ArtifactHub change log](https://artifacthub.io/packages/helm/open-8gears/n8n?modal=changelog).

