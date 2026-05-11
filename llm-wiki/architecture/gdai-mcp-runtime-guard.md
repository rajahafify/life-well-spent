---
title: GDAI MCP Runtime Guard
type: reference
tags: [architecture, tooling, godot-mcp]
sources: [scripts/managers/gdai_mcp_runtime_guard.gd, tests/specs/gdai_mcp_runtime_guard_test.gd, project.godot]
---

# GDAI MCP Runtime Guard

## Overview
`GDAIMCPRuntimeGuard` keeps the GDAI MCP plugin enabled for editor/godot-mcp workflows while preventing the runtime server from starting during headless tests.

## API
```gdscript
class_name GDAIMCPRuntimeGuard
extends Node

func should_skip_runtime(display_name: String) -> bool
```

## Design Decisions
- `project.godot` autoload points to the guard instead of the addon runtime script.
- The guard returns immediately when `DisplayServer.get_name() == "headless"`.
- Non-headless editor/game sessions still instantiate `GDAIRuntimeServer` when available.
- Addon vendor files remain unchanged.

## Test Coverage
- `tests/specs/gdai_mcp_runtime_guard_test.gd` covers headless skip, non-headless allow, and project autoload path.

## Related
- `project.godot`
- GDAI MCP addon under `addons/gdai-mcp-plugin-godot/`
