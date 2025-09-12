## What this PR does / why we need it

<!-- Provide a clear and concise description of what this PR accomplishes and why it's needed -->

## Which issue this PR fixes

<!-- Optional: Link related issues using the format below. Issues will be automatically closed when PR is merged -->
<!-- fixes #123, fixes #456 -->

## Special notes for your reviewer

<!-- Any additional context, special considerations, or things reviewers should pay attention to -->

## Checklist

Please place an 'x' in all applicable fields and remove unrelated items.

### Version and Documentation
- [ ] Chart version updated in `Chart.yaml` following [semantic versioning](CONTRIBUTING.md#chart-versioning-schema)
- [ ] App version updated in `Chart.yaml` if applicable
- [ ] `artifacthub.io/changes` section updated in `Chart.yaml` (see [ArtifactHub annotation reference](https://artifacthub.io/docs/topics/annotations/helm/))
- [ ] Variables are documented in the `README.md`
### Testing and Validation
- [ ] Ran `ah lint` locally without errors
- [ ] Ran Chart-Testing: `ct lint --chart-dirs charts/n8n --charts charts/n8n --validate-maintainers=false`
- [ ] Tested chart installation locally
- [ ] Tested with example configurations in `/examples` directory

