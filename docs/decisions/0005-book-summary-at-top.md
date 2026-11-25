# 0005: Put the Book summary at the top of the list

- **Status:** Accepted
- **Date:** 2026-11-20

## Context

The Book tab shows a summary of the training list: the number of trainings, total days and total hours. The bottom of the screen already holds the tab bar and the "Submit Request" button. The catalog is small (28 courses), so the list usually holds only a few items. The first version (2026-11-19) put the summary in a bottom toolbar, and it moved to the top of the list the next day.

## Options

1. **A `Section` at the top of the list.** The user sees the totals first, then scrolls through what makes them up. It scrolls away on a long list.
2. **A footer at the end of the list.** It reads like a receipt, but the user has to scroll to the end to see the totals.
3. **A sticky total line in the bottom inset, above Submit.** It's always visible, but it makes the bottom area taller and puts more next to the one primary action.
4. **Inside the Submit button** (for example, "Submit 3 trainings · 24 h"). The text is compact, but it truncates at large Dynamic Type sizes.

## Decision

Option 1. Seeing the summary at a glance and then scrolling to check the items is the reading order the screen is meant for. The bottom stays reserved for Submit. This was a UX judgment call, not a measured result.

## Consequences

- On a long list, the totals aren't visible next to the Submit button. The Submit Request sheet repeats the course list and total hours, so the user sees them again before sending.
- Revisit if the catalog grows and lists get long enough that the totals are often scrolled away.
