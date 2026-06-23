## ADDED Requirements

### Requirement: No user registration required
The system SHALL NOT require any form of user registration, login, email, phone number, or personal identification to create reports.

#### Scenario: Anonymous report creation
- **WHEN** user launches app for first time
- **WHEN** user taps "New Report"
- **THEN** system does NOT ask for any account creation or sign-in
- **THEN** user can immediately fill report details and submit

### Requirement: Device-generated anonymous identity
The system SHALL generate a UUID on first launch stored in app_preferences. This UUID SHALL be sent with each report to the server as an anonymous_device_id for basic deduplication.

#### Scenario: Anonymous device ID generation
- **WHEN** user launches app for first time
- **THEN** system generates a random UUID
- **THEN** system stores UUID in local preferences
- **THEN** UUID is attached to every outgoing report as anonymous_device_id

#### Scenario: Identity persists across restarts
- **WHEN** user creates reports
- **WHEN** user closes and reopens the app
- **THEN** system uses same anonymous device ID
- **THEN** server can associate new reports with same device

### Requirement: No personal data in reports
Reports SHALL NOT contain user name, email, phone number, or any personally identifiable information.

#### Scenario: Report fields exclude PII
- **WHEN** user creates a report
- **THEN** report form fields are limited to: category, description, photo, location
- **THEN** no field requests name, email, phone, or other PII
