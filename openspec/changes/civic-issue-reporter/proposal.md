## Why

Namma Ooru aims to empower citizens to report civic issues (trash, potholes, broken streetlights, etc.) directly from their phones. Currently there is no easy way for residents to flag problems to authorities. This app provides a simple mobile interface with offline-first storage so reports work even without internet, then syncs when connectivity returns.

## What Changes

- New Flutter app with civic issue reporting as the core feature
- Offline SQLite database via drift for local report storage
- Online sync to a REST API backend when connectivity is available
- Camera integration for capturing issue photos
- Automatic GPS location capture on each report
- Anonymous reporting option (no account required)
- Report list view showing all submitted reports with status
- Basic report detail view with photo, description, location, status

## Capabilities

### New Capabilities
- `issue-reporting`: Create and submit civic issue reports with photo, description, category, and location. View submitted reports and their resolution status.
- `offline-storage`: Local persistence using drift (SQLite). All reports saved locally before any network attempt. Query, filter, and manage local data.
- `sync`: Bidirectional sync between local drift database and remote server. Queue outgoing reports when offline; reconcile when online.
- `anonymous-reporting`: Report issues without user registration or authentication. No personal data required.
- `photo-capture`: Camera integration via image_picker. Attach photos to reports. Store photos locally and sync to server.
- `location-tracking`: Automatic GPS location capture using geolocator. Attach lat/lng coordinates to each report. Show reports on a map.

### Modified Capabilities

None - this is a new application.

## Impact

- New Flutter project with drift, geolocator, image_picker, http, and connectivity_plus dependencies
- New data layer: drift database schema for reports, photos, sync queue
- New UI screens: report creation form, report list, report detail, settings
- New service layer: sync service, location service, photo service
- Backend API contract needed for sync (REST endpoints defined in design)
- pubspec.yaml updated with new dependencies
