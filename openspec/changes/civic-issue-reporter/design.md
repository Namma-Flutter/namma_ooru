## Context

Namma Ooru is a new Flutter app for civic issue reporting. Users capture photos of problems (trash, potholes, broken streetlights), add details, and submit reports. The app must work offline-first — reports are saved locally and sync to a server when connectivity is available. No user authentication is required (anonymous reporting). The UI follows the existing DESIGN.md style guide (Airbnb-inspired: clean white canvas, single accent color, soft rounded corners, photo-forward cards).

## Goals / Non-Goals

**Goals:**
- Offline-first: all reports saved locally via drift SQLite before any network attempt
- Anonymous reporting: no sign-up, no auth, no personal data collection
- Photo capture: camera integration with local photo storage and server upload
- GPS location: automatic lat/lng capture on each report, editable by user
- Sync: queue-based upload to REST API when online; server push status updates (polling-based since no push infra)
- Report list: sortable/filterable list of all user's reports with status indicators
- Report detail: full view with photo, description, category, location map, status history
- UI: Airbnb-inspired design language per DESIGN.md (clean, photo-first, rounded corners, single accent color)

**Non-Goals:**
- User authentication / accounts (anonymous only for v1)
- Real-time push notifications (polling-based sync is sufficient for v1)
- Offline-first for photos on large volumes (photos stored as local file paths; only metadata synced)
- Multi-tenancy or role-based access
- Map-based browsing of all reports (future feature)
- Native platform-specific features beyond camera and location

## Decisions

### Architecture: Feature-first with service layer

Feature folders under `lib/` (`reports/`, `sync/`, `settings/`) each containing UI, data, and logic. Shared services (`location_service`, `photo_service`, `database`) in `lib/core/`. This keeps related code co-located while avoiding circular dependencies through a thin core layer.

### Database: drift (SQLite)

Drift is the standard for production Flutter SQLite. Provides type-safe queries, migrations, reactive streams with `.watch()`. Suitable for offline-first mobile apps. Alternatives considered: `hive` (no relational queries), `objectbox` (heavier, less portable).

### Sync strategy: Simple queue-based push with polling pull

New reports inserted into drift with `sync_status = pending`. A `SyncService` observes connectivity changes via `connectivity_plus`. When online, it drains the pending queue (POST each report), then polls for status updates (GET). No conflict resolution needed for v1 — local is source of truth for new reports; server is source of truth for status updates. Alternatives considered: `OfflineFirst` repository pattern with `sqflite` (too complex for v1 scope), Firebase Firestore (vendor lock-in, adds auth requirement).

### Photo handling: Store locally, upload via multipart

Photos captured via `image_picker` saved to app documents directory. Drift stores file path + server URL (after upload). On sync, photos uploaded as multipart/form-data. Server returns URL which is stored locally. Alternatives considered: Base64 in SQLite (bloats database), Cloudinary direct upload (third-party dependency).

### Location: geolocator package

Standard Flutter GPS library. Request permission on first report. Cache last known location for quick use. Allow manual location editing in the report form. Alternatives considered: `location` package (less maintained), Google Maps Places API (requires API key, adds complexity).

### UI: Airbnb-inspired DESIGN.md tokens

Use DESIGN.md as a design token reference. Palettes, spacing, typography scale, and component shapes adapted for Namma Ooru. Single accent color (`#ff385c` Rausch) for CTAs. White canvas, soft rounded corners (`{rounded.sm}` 8px, `{rounded.md}` 14px). Cards for report list items with photo-first layout.

### State management: StatefulWidget + InheritedWidget for v1

No external state management library for this scope. Screens manage their own state. Drift's reactive streams (`watch()`) auto-update UI when data changes. Alternatives considered: Riverpod (adds dependency overhead for a simple app), Bloc (too ceremonial for v1).

## Risks / Trade-offs

- [Photo storage on low-end devices] → Limit photo resolution via image_picker `imageQuality` param (0.7). Warn user if storage is low.
- [Sync conflicts if server rejects a pending report] → Mark as `sync_failed` with error code; show in UI for retry.
- [GPS accuracy indoors] → Show accuracy reading in report form; allow manual location pin on map.
- [Polling overhead for status updates] → Poll every 5 minutes only when app is in foreground; no background work.
- [No auth means no report ownership on server] → Server assigns a device-generated UUID as anonymous identity; stored locally in drift preferences.
