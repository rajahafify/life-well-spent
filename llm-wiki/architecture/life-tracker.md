---
title: LifeTracker
type: reference
tags: [architecture, models, productivity]
sources: [scripts/models/life_tracker.gd, tests/specs/life_tracker_test.gd]
---

# LifeTracker

## Overview
Pure model for real-life daily tasks, habits, completions, streaks, and XP rewards.

## API
```gdscript
add_task(id, title, xp_reward = 10)
add_habit(id, title, xp_reward = 10)
complete_task(id, date) -> bool
is_task_complete(id, date) -> bool
completed_count_for_date(date) -> int
streak_for(id) -> int
to_dict() -> Dictionary
apply_dict(data)
from_dict(data)
```

## Design Decisions
- Completion key is `task_id|date`, so same task pays XP once per day.
- Habits reuse task data with `habit = true` and add streak tracking.
- Date math is manual and model-local to avoid Node dependencies.

## Test Coverage
- `tests/specs/life_tracker_test.gd`: tasks, habit streaks, once-per-day XP, daily counts, serialization round trip.

## Related
- [ProgressionModel](progression-model.md)
- [QuestManager](quest-manager.md)
