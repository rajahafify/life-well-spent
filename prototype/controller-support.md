# Controller Support

## Goal

Make every player-facing interaction reachable without mouse or keyboard, and show a prompt when a contextual action is available.

## Configured Actions

| Surface | Action | Input | Status |
| --- | --- | --- | --- |
| Main Menu | Move selection | D-pad up/down | Configured |
| Main Menu | Activate selected button | A | Configured |
| Main Menu | Cancel New Game confirmation | B | Configured |
| Town | Move player | Left stick / D-pad | Configured |
| Town | Talk to nearby NPC | A | Configured |
| Town | Show talk prompt | Press A to talk | Configured |
| Town | Open/close inventory | X | Configured |
| Town | Open options | Start | Configured |
| Field | Move player | Left stick / D-pad | Configured |
| Field | Talk to nearby Forest Guard | A | Configured |
| Field | Target/attack nearby enemy | A | Configured |
| Field | Show talk prompt | Press A to talk | Configured |
| Field | Show attack prompt | Press A to attack | Configured |
| Field | Open/close inventory | X | Configured |
| Field | Open options | Start | Configured |
| Dialog | Advance visible Next/Accept/Claim/Close action | A | Configured |
| Dialog | Close when Close is available | B | Configured |
| Options Panel | Move row selection | D-pad up/down | Configured |
| Options Panel | Change game speed | D-pad left/right | Configured |
| Options Panel | Activate selected row | A | Configured |
| Options Panel | Close panel | B | Configured |
| Game Over | Continue to Summary | A | Configured |
| Run Summary | Select Rebirth / End Game | D-pad left/right/up/down | Configured |
| Run Summary | Activate selected action | A | Configured |

## Actions Still Needing Explicit Configuration

| Surface | Action | Current gap |
| --- | --- | --- |
| Inventory Window | Move between equipment slots and item rows | Inventory can be opened with X, but item focus/equip/use needs explicit controller navigation. |
| Inventory Window | Equip weapon/armor/consumable | Mouse-driven today; needs A to equip/use selected item. |
| Shortcut Bar | Use slots 1-9 | Keyboard number shortcuts exist; controller slot selection/use is not mapped. |
| Forest Scene | Move/interact after entering Forest | Town and Field have controller movement; Forest should be checked before expanding that map. |
| Quest Window | Scroll or inspect long objectives | Current quest panel is passive text; no controller action is needed yet unless objectives overflow. |

## Prompt Rules

- Prompt is hidden while dialog, inventory, options, or rebirth panels are open.
- NPC prompt takes priority over enemy prompt when both are nearby.
- Field A-button behavior follows the prompt priority: talk first, otherwise attack.
- Prompt follows the active target and stays centered just above that NPC or enemy in screen space.
