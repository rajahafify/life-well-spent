# Swordsman Guild Quest

## Core Idea

Certification is earned by spending Life.

## Player Goal

Unlock Swordsman Guild.

## Unlock Condition

Available only after Forest Guard blocks Forest path.

## Verbs

- Talk
- Claim Reward
- Spend
- Age
- Unlock
- Die

## Chain

### Step 1

- Cost: 40 Life
- Life: 100 → 60
- Chain step: 1
- Aging sprite: Sprite 1

### Step 2

- Cost: 40 Life
- Life: 60 → 20
- Chain step: 2
- Aging sprite: Sprite 2

### Step 3

- Cost: 40 Life / remaining Life
- Life: 20 → 0
- Chain step: 3
- Unlock: Swordsman Guild
- Game Over requested
- No new aging sprite

## Rules

- Steps must complete in order.
- Steps cannot be skipped.
- XP does not unlock quest.
- Quest completion, not acceptance, spends Life.
- Completion 3 ends run.

## Key Text

```text
Certification is not earned with coin.
It is earned with life.
```

Final:

```text
Reward: Swordsman Guild Unlocked
```
