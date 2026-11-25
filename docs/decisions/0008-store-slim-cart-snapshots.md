# 0008: Store a slim snapshot of displayed fields in the training list

- **Status:** Accepted
- **Date:** 2026-11-25

## Context

[0003](0003-store-course-snapshots.md) saved full `Course` values in the cart. A review found two problems. First, the save format is tied to the catalog model: changing `Course` would make existing saved carts fail to decode. Second, Book reads only five fields: `id` (de-duplication, removal, `BookingRequest.courseIDs`), `name` (rows, the delete confirmation and the Submit Request sheet), `subtitle` and `category` (rows), and `hours` (rows and totals). It never reads `description`, `type`, `certificationKind` or `image`. Book doesn't navigate to course details yet.

## Options

1. **Keep full `Course` snapshots.** No changes, but the schema risk remains and unused data is stored.
2. **Store IDs only and resolve them against the catalog.** Nothing in the cart can go stale, but rendering depends on the catalog loading, and a removed course silently drops out.
3. **Store a slim snapshot of only the fields Book displays** (`id`, `name`, `subtitle`, `category`, `hours`), in its own `Codable` type owned by Book. The cart renders on its own and stores only what it shows.

## Decision

Option 3. The cart only needs to remember what the user picked and show it. Giving it its own type means changes to `Course` can't break saved carts. If the saved file still can't be decoded, the service logs the error and starts with an empty cart instead of throwing.

## Consequences

- Book gets its own model, and "Add to training" maps `Course` to it.
- The displayed fields can still go stale. A backend should validate the IDs it receives, and the app could refresh snapshots when the catalog loads.
- Opening course details from Book will need the full `Course`, which means looking it up or fetching it by ID. That will be its own decision when Book navigation is built.
- Changing the snapshot type itself still needs a migration or a decoding fallback. Keeping it to the displayed fields makes that less likely. Showing a new field in Book means adding it to the snapshot.
- Carts saved in the old full-`Course` format won't decode with the new type, so they fall back to empty. That's acceptable because the rebuilt app hasn't shipped.
