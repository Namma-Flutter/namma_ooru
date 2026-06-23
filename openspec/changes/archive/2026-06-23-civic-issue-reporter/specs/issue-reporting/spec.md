## ADDED Requirements

### Requirement: User can create a civic issue report
The system SHALL allow users to create a new civic issue report by providing a category, description, and optional photo. The user's current location SHALL be automatically attached.

#### Scenario: User creates a report with all fields
- **WHEN** user taps "New Report" button
- **WHEN** user selects category from predefined list (Trash, Pothole, Streetlight, Graffiti, Other)
- **WHEN** user enters description text
- **WHEN** user captures or selects a photo
- **WHEN** user taps "Submit" button
- **THEN** system creates report with status "submitted"
- **THEN** system saves report to local database
- **THEN** system returns user to report list showing the new report

#### Scenario: User creates a report without photo
- **WHEN** user fills category and description
- **WHEN** user skips photo attachment
- **WHEN** user taps "Submit"
- **THEN** system creates report with no photo attachment
- **THEN** system saves report successfully

### Requirement: User can view list of all reports
The system SHALL display a list of all reports the user has submitted, sorted by submission date descending.

#### Scenario: Report list shows all reports
- **WHEN** user opens the app
- **THEN** system shows report list with each item displaying: category icon, truncated description, date, status badge, photo thumbnail

#### Scenario: Empty state when no reports exist
- **WHEN** user opens the app
- **WHEN** no reports have been created
- **THEN** system shows empty state with illustration and "No reports yet" message
- **THEN** system shows a "Create First Report" button

### Requirement: User can view report details
The system SHALL display full details of a selected report including photo, description, category, location on map, submission date, and current status.

#### Scenario: View full report detail
- **WHEN** user taps a report in the list
- **THEN** system navigates to detail screen showing: full-size photo (if attached), category badge, full description, location map pin, submission timestamp, current status with last-updated timestamp

### Requirement: Reports have predefined categories
The system SHALL support a fixed set of report categories: Trash, Pothole, Broken Streetlight, Graffiti, Illegal Dumping, Other.

#### Scenario: Category selection
- **WHEN** user creates a new report
- **THEN** system presents category picker with all 6 options
- **WHEN** user selects a category
- **THEN** system uses selected category for the report

### Requirement: Reports track status lifecycle
Reports SHALL have a status lifecycle: submitted → under_review → in_progress → resolved. Server may update status; local app reads and displays current status.

#### Scenario: Status display
- **WHEN** user views report detail
- **THEN** system displays current status with color-coded badge
- **THEN** system shows status history timeline (status changes with timestamps)

### Requirement: User can delete a pending report
The system SHALL allow users to delete reports that have not yet been synced to the server.

#### Scenario: Delete pending report
- **WHEN** user views a report with sync_status = pending
- **WHEN** user taps "Delete" option
- **WHEN** user confirms deletion
- **THEN** system removes report from local database
- **THEN** system removes associated photo from device storage
