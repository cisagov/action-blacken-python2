# action-blacken-python2 #

[![GitHub Build Status](https://github.com/cisagov/action-blacken-python2/workflows/build/badge.svg)](https://github.com/cisagov/action-blacken-python2/actions)
[![License](https://img.shields.io/github/license/cisagov/action-blacken-python2)](https://spdx.org/licenses/)
[![CodeQL](https://github.com/cisagov/action-blacken-python2/workflows/CodeQL/badge.svg)](https://github.com/cisagov/action-blacken-python2/actions/workflows/codeql-analysis.yml)

This is a [GitHub Docker container action](https://docs.github.com/en/actions/tutorials/use-containerized-services/create-a-docker-container-action#introduction)
to format Python 2 source code using [`black`](https://github.com/psf/black).

> [!WARNING]
> This action is written to make it easier to format Python 2 source code, but
> `black` will format *any* Python code in a project this action is run against.

<!-- Hack to work around markdownlint's MD028/no-blanks-blockquote rule. -->

> [!NOTE]
> Changes made by this action are only available for the workflow job
> that runs this action. A consuming workflow job would need to commit
> and push the modified files for them to persist.

## Usage ##

### Inputs ###

None.
<!--
| Name | Description | Interpreted Type | Default | Required |
| ---- | ----------- | ---------------- | ------- | :------: |
| input_name | The input's description. | `string` | n/a | yes |
-->

### Outputs ###

None.
<!--
| Name | Description | Output Type |
| ---- | ----------- | ----------- |
| output_name | The output's description. | `output_type` |
-->

### Sample GitHub Actions workflow ###

This GitHub action requires no permissions for its functionality.

```yml
---
name: The workflow

on:
  push:

jobs:
  my_job:
    # This job does not need any permissions
    permissions: {}
    runs-on: ubuntu-latest
    steps:
      - name: Checkout the Python 2 project
        uses: actions/checkout@08c6903cd8c0fde910a37f88322edcfb5dd907a8 # v5.0.0
      - name: Format the Python 2 project
        uses: cisagov/action-blacken-python2@v1.0.0
```

## Contributing ##

We welcome contributions!  Please see [`CONTRIBUTING.md`](CONTRIBUTING.md) for
details.

## License ##

This project is in the worldwide [public domain](LICENSE).

This project is in the public domain within the United States, and
copyright and related rights in the work worldwide are waived through
the [CC0 1.0 Universal public domain
dedication](https://creativecommons.org/publicdomain/zero/1.0/).

All contributions to this project will be released under the CC0
dedication. By submitting a pull request, you are agreeing to comply
with this waiver of copyright interest.
