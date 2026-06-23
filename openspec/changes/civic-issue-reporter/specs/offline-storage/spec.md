## ADDED Requirements

### Requirement: All reports stored locally in drift database
The system SHALL persist all reports in a local SQLite database managed by drift. No network request SHALL be required to save a report.

#### Scenario: Report saved locally first
- **WHEN** user creates a report
- **WHEN** device has no network connectivity
- **THEN** system saves report to local drift database
- **THEN** system marks report sync_status as "pending"
- **THEN** report appears in the report list immediately

#### Scenario: App restart preserves reports
- **WHEN** user creates reports
- **WHEN** user closes and reopens the app
- **THEN** all previously created reports appear in the list
- **THEN** report details are fully accessible offline

### Requirement: Drift database schema
The database SHALL contain tables: reports, report_photos, sync_queue, and app_preferences with appropriate relationships.

#### Scenario: Schema creation on first launch
- **WHEN** user launches app for the first time
- **THEN** drift runs migration to create all tables
- **THEN** app is ready for use without any setup

### Requirement: Database migrations
Drift schema changes SHALL be managed through versioned migrations. Schema version stored in app_preferences.

#### Scenario: Migration on schema change
- **WHEN** app updates to a version with new database schema
- **THEN** drift runs migration from current version to latest
- **THEN** all existing data is preserved
