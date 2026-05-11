# UI

## Core Idea

UI displays model state and routes player intent. UI does not own rules.

## HUD

Shows:
- Life
- Combat HP
- XP
- weapon
- armor
- consumable/count
- current objective
- guild quest chain step

## Dialog Panel

Shows:
- NPC name
- dialog text
- Accept button
- Complete button
- Close button

Rules:
- Dialog open disables movement.
- Buttons emit intent only.
- Controllers forward intent to models.

## Quest Status Panel

Shows:
- current objective
- Swordsman Guild chain step
- locked/unlocked state

## Game Over Panel

Text:

```text
Your life was spent to unlock:
SWORDSMAN GUILD

Was it a life well spent?

Reborn?
[Yes] [No]
```

Rules:
- Game Over blocks gameplay input.
- Yes triggers Reborn.
- No behavior TBD.
