---
title: CI — GitHub Actions
type: reference
updated: 2026-05-08
sources:
  - .github/workflows/tests.yml
  - AGENTS.md
tags: [architecture]
---

# CI — GitHub Actions

## Workflow
`.github/workflows/tests.yml` — runs on push/PR to `master`/`main` when `tests/**` changes.

## Pipeline
1. Checkout code
2. Download Godot 4.6.2 Linux headless
3. Run `tests/test_runner.tscn` with `--headless --quit`

## Structure
```
.github/workflows/tests.yml  → CI config
tests/test_runner.tscn       → Test scene (runs specs, prints results)
tests/specs/*.json           → Spec files
```

## Run Locally
```bash
Godot --headless --quit tests/test_runner.tscn
```
