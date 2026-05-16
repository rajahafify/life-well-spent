---
title: CI - GitHub Actions
type: reference
updated: 2026-05-16
sources:
  - .github/workflows/tests.yml
  - .github/workflows/web-release.yml
  - export_presets.cfg
  - AGENTS.md
tags: [architecture]
---

# CI - GitHub Actions

## Test Workflow
`.github/workflows/tests.yml` runs on push/PR to `master`/`main` and on manual dispatch.

### Pipeline
1. Checkout code
2. Download Godot 4.6.2 Linux headless
3. Disable the editor-only MCP plugin for CI
4. Import Godot assets
5. Run `tests/test_runner.tscn` with `--headless --quit`
6. Fail the job when the summary is not `0 failed` or Godot emits warnings/errors.

## Web Release Workflow
`.github/workflows/web-release.yml` publishes the Godot `Web` export to the `gh-pages` branch on version tag pushes matching `v*` and on manual dispatch. GitHub Pages serves that branch root.

### Pipeline
1. Checkout code
2. Download Godot 4.6.2 Linux headless
3. Download the matching Godot 4.6.2 export templates
4. Disable the editor-only MCP plugin for CI
5. Import Godot assets
6. Export `Web` to `builds/web/index.html`
7. Add `.nojekyll` to the export folder
8. Force-publish `builds/web` to the orphan `gh-pages` branch

## Structure
```
.github/workflows/tests.yml        -> test CI config
.github/workflows/web-release.yml  -> tag/manual gh-pages branch publish config
export_presets.cfg                 -> Web and Windows export presets
tests/test_runner.tscn             -> Tiny CI scene
tests/test_runner.gd               -> Runs specs, prints results, exits 0/1
tests/test_helper.gd               -> TestCase and assertions
tests/specs/*.gd                   -> Spec files
```

## Run Locally
```powershell
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --quit tests/test_runner.tscn
& "C:\Users\Home\Desktop\Godot\Godot_v4.6.2-stable_win64_console.exe" --headless --export-release "Web" "builds/web/index.html"
```

The test scene exits with code `1` when any spec fails. The web workflow expects GitHub Pages to be configured with source `Deploy from a branch`, branch `gh-pages`, folder `/`.
