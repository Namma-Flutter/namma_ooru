## ADDED Requirements

### Requirement: User can capture photo via camera
The system SHALL allow users to take a photo using the device camera and attach it to a report.

#### Scenario: Capture photo from camera
- **WHEN** user taps camera icon on report creation form
- **WHEN** user grants camera permission (if not already granted)
- **THEN** system opens device camera
- **WHEN** user captures a photo
- **THEN** system displays photo thumbnail preview on the form

### Requirement: Photo quality and size limits
Photos SHALL be captured at reduced quality (imageQuality: 70) to limit file size. Maximum resolution SHALL be 1920px on the longest edge.

#### Scenario: Compressed photo capture
- **WHEN** user captures a photo
- **THEN** system resizes to max 1920px longest edge
- **THEN** system compresses to JPEG quality 70
- **THEN** system saves compressed photo to app documents directory

### Requirement: Photo stored in app documents directory
Captured photos SHALL be saved to the app's local documents directory. The drift database SHALL store the relative file path.

#### Scenario: Photo file persistence
- **WHEN** user captures a photo for a report
- **THEN** system saves file to app documents directory
- **THEN** system stores file path in report_photos table
- **WHEN** user views the report
- **THEN** system loads and displays photo from local file path

### Requirement: User can retake photo
The system SHALL allow users to retake a photo before submitting the report.

#### Scenario: Retake photo
- **WHEN** user has captured a photo
- **WHEN** user taps retake/delete on the photo preview
- **THEN** system discards current photo
- **THEN** system opens camera again
- **WHEN** user captures new photo
- **THEN** new photo replaces previous one

### Requirement: Report can be submitted without photo
Photos SHALL be optional. A report SHALL be valid with category and description alone.

#### Scenario: Submit without photo
- **WHEN** user fills category and description
- **WHEN** user does not attach any photo
- **WHEN** user taps Submit
- **THEN** report is saved with no photo attachment
- **THEN** report displays without photo in list and detail views
