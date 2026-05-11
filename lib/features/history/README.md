# History feature scaffold

This feature is now split into clean-architecture layers:

- `data` for local persistence and repository implementations.
- `domain` for repository contracts and use cases.
- `presentation` for Riverpod providers and UI entry points.

The existing `HistoryPage` and scan notifier can be migrated to these layers incrementally.
