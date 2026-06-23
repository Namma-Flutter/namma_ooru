## 1. Project Setup & Dependencies

- [x] 1.1 Add drift, sqlite3_flutterlibs, path_provider, path, connectivity_plus, http, image_picker, geolocator, flutter_map, latlong2, uuid, intl dependencies to pubspec.yaml
- [x] 1.2 Add drift_dev, build_runner dev dependencies to pubspec.yaml
- [x] 1.3 Run flutter pub get and verify project compiles
- [x] 1.4 Create directory structure: lib/core/database/, lib/core/services/, lib/features/reports/, lib/features/sync/, lib/features/settings/, lib/shared/widgets/, lib/shared/theme/

## 2. Database Layer (drift)

- [x] 2.1 Define drift database schema: reports table (id, category, description, latitude, longitude, photo_path, server_photo_url, status, sync_status, created_at, updated_at, server_id, error_message)
- [x] 2.2 Generate drift DAOs and model classes with build_runner
- [x] 2.3 Create AppDatabase class with singleton pattern and migration logic
- [x] 2.4 Create app_preferences table for device UUID and settings storage
- [x] 2.5 Create database service wrapper with common query methods (insert, getAll, getById, delete, updateStatus)
- [x] 2.6 Add drift reactive query methods (watchAll, watchById) for UI auto-updates

## 3. Core Services

- [x] 3.1 Create LocationService using geolocator: getCurrentLocation(), requestPermission(), with accuracy handling and timeout
- [x] 3.2 Create PhotoService using image_picker: captureFromCamera(), compressAndSave(), deletePhoto(), getLocalPath()
- [x] 3.3 Create ConnectivityService using connectivity_plus: stream connectivity changes, isOnline bool getter
- [x] 3.4 Create AnonymousIdentityService: generate device UUID on first launch, persist in preferences, expose getter

## 4. Theme & Design Tokens

- [x] 4.1 Create design token constants from DESIGN.md: colors (primary #ff385c, ink #222222, canvas #ffffff, etc.), spacing (4px base), rounded radii, typography scale
- [x] 4.2 Create AppTheme with ThemeData using tokens: white canvas, rounded components, single accent color for CTAs
- [x] 4.3 Create shared widgets: AppButton (primary/secondary), AppCard (rounded with shadow), AppCategoryBadge, StatusBadge, EmptyStateWidget

## 5. Report List Screen

- [x] 5.1 Build ReportListScreen with AppBar (title "My Reports"), floating action button for new report
- [x] 5.2 Build ReportListItem widget: category icon, truncated description, date, status badge, photo thumbnail (Airbnb card style)
- [x] 5.3 Wire up drift stream to auto-refresh list when data changes
- [x] 5.4 Implement empty state when no reports exist
- [x] 5.5 Implement pull-to-refresh for manual sync trigger

## 6. New Report Screen

- [x] 6.1 Build NewReportScreen with scrollable form: category dropdown/picker, description text field (multiline), photo capture area with camera button, location preview with map thumbnail
- [x] 6.2 Implement category picker UI (horizontal chip selector or bottom sheet list)
- [x] 6.3 Implement photo capture flow: tap camera icon -> open camera -> show thumbnail preview with retake option
- [x] 6.4 Implement location auto-capture on screen open with loading state
- [x] 6.5 Implement location editing: tap location preview -> open full-screen draggable pin map -> confirm
- [x] 6.6 Implement form validation (category required, description required min 10 chars)
- [x] 6.7 Implement submit flow: validate -> insert into drift database -> save photo to documents -> navigate back to list
- [x] 6.8 Show success snackbar and return to report list on submit

## 7. Report Detail Screen

- [x] 7.1 Build ReportDetailScreen with: full-width photo (if exists), category badge, description, location map pin, date, status badge
- [x] 7.2 Implement embedded map view with location pin using flutter_map
- [x] 7.3 Implement status timeline widget showing status history
- [x] 7.4 Implement delete option for pending (unsynced) reports with confirmation dialog
- [x] 7.5 Add retry sync button for failed sync reports

## 8. Sync Service

- [x] 8.1 Create SyncService with observeConnectivity() that listens to ConnectivityService stream
- [x] 8.2 Implement processPendingReports(): query pending reports from drift, POST each to /api/reports with multipart photo, update sync_status on response
- [x] 8.3 Implement pollStatusUpdates(): GET /api/reports/status?ids=... for synced reports, update local status field
- [x] 8.4 Implement 5-minute polling timer (only when app foreground + online)
- [x] 8.5 Handle error cases: network failure, server rejection (mark as failed with error), retry logic
- [x] 8.6 Wire sync status into UI: pending indicator, synced checkmark, failed with retry button

## 9. Settings Screen

- [x] 9.1 Build SettingsScreen with: anonymous device ID display, sync status, about section
- [x] 9.2 Add "Report Categories" info section explaining what each category means
- [x] 9.3 Add force sync button to trigger manual sync

## 10. Main App Wiring

- [x] 10.1 Update main.dart: initialize drift database, initialize services (location, connectivity), wrap with MaterialApp using AppTheme
- [x] 10.2 Set up initial route: ReportListScreen as home, with routes for NewReport and ReportDetail
- [x] 10.3 Wire bottom navigation or drawer: Reports (main), Settings
- [ ] 10.4 Test full flow: create report offline -> save locally -> view in list -> go online -> verify sync -> view detail
- [x] 10.5 Verify flutter analyze passes (0 errors, 0 warnings)

## 11. Platform Configuration

- [x] 11.1 Configure iOS Info.plist: camera usage description, location usage descriptions (when in use)
- [x] 11.2 Configure Android AndroidManifest.xml: camera permission, location permissions (fine + coarse), internet permission
- [ ] 11.3 Test on iOS simulator/device: camera, location, photo storage
- [ ] 11.4 Test on Android emulator/device: camera, location, photo storage
