## ADDED Requirements

### Requirement: Sync service observes connectivity
The app SHALL monitor network connectivity changes via connectivity_plus and trigger sync when going online.

#### Scenario: Auto-sync on connectivity restored
- **WHEN** device loses network connectivity
- **WHEN** user creates reports (sync_status = pending)
- **WHEN** device regains connectivity
- **THEN** sync service automatically starts draining the pending queue
- **THEN** pending reports are uploaded to server

### Requirement: Pending reports uploaded sequentially
Reports with sync_status = "pending" SHALL be uploaded to the server in FIFO order (oldest first).

#### Scenario: Upload pending reports
- **WHEN** sync service runs
- **WHEN** there are pending reports in local database
- **THEN** service POSTs each report to server endpoint
- **WHEN** server responds with 200/201
- **THEN** system sets report sync_status = "synced"
- **THEN** system stores server-assigned report ID locally
- **THEN** service proceeds to next pending report

#### Scenario: Upload failure handling
- **WHEN** server responds with error
- **THEN** system sets report sync_status = "failed"
- **THEN** system stores error message locally
- **THEN** sync continues with next pending report
- **THEN** user sees failure indicator in report list

### Requirement: Status polling for server updates
The app SHALL poll the server for status updates on synced reports every 5 minutes when the app is in the foreground and online.

#### Scenario: Poll updates report status
- **WHEN** app is in foreground
- **WHEN** device is online
- **WHEN** 5 minutes have elapsed since last poll
- **THEN** service GETs status updates for all synced reports
- **WHEN** server returns updated status
- **THEN** system updates local report status
- **THEN** UI reactively updates via drift stream

### Requirement: REST API contract for sync
The sync service SHALL communicate with a REST API using JSON for metadata and multipart for photo uploads.

#### Scenario: POST new report
- **WHEN** sync service uploads a pending report
- **THEN** request SHALL be POST to /api/reports
- **THEN** body SHALL include: category, description, latitude, longitude, anonymous_device_id, photo (multipart, optional), created_at
- **THEN** server SHALL respond with 201 and JSON containing: server_id, status, created_at

#### Scenario: GET status updates
- **WHEN** sync service polls for updates
- **THEN** request SHALL be GET /api/reports/status?ids=id1,id2,id3
- **THEN** server SHALL respond with 200 and JSON array: [{id, status, updated_at, resolution_note}]
