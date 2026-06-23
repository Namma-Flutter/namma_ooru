## ADDED Requirements

### Requirement: Auto-capture GPS location on report creation
The system SHALL automatically capture the device's current GPS location (latitude and longitude) when the user begins creating a new report.

#### Scenario: Location auto-captured on new report
- **WHEN** user taps "New Report"
- **WHEN** location permission is granted
- **THEN** system requests current location from GPS
- **THEN** system displays captured location on a small map preview
- **THEN** system attaches coordinates to the report on submission

#### Scenario: High accuracy location
- **WHEN** user starts new report
- **THEN** system requests location with high accuracy (GPS_PROVIDER)
- **THEN** system waits up to 10 seconds for accurate fix
- **THEN** system uses best available accuracy (falls back to network location if GPS unavailable)

### Requirement: Location permission handling
The system SHALL request location permission at appropriate times and handle denial gracefully.

#### Scenario: Permission request on first report
- **WHEN** user taps "New Report" for the first time
- **WHEN** location permission has not been granted
- **THEN** system shows a rationale dialog explaining why location is needed
- **THEN** system requests location permission

#### Scenario: Location permission denied
- **WHEN** user denies location permission
- **THEN** system allows report creation without location
- **THEN** system shows a note "Location not available" on the report form
- **THEN** user can manually enter location by tapping on a map

### Requirement: User can edit captured location
The system SHALL allow users to adjust the captured location by dragging a pin on a map.

#### Scenario: Adjust location on map
- **WHEN** location has been captured
- **WHEN** user taps the location preview on the report form
- **THEN** system opens full-screen map with draggable pin
- **WHEN** user drags pin to correct position
- **WHEN** user taps "Confirm"
- **THEN** system updates report coordinates
- **THEN** system returns to report form with updated location

### Requirement: Report stores lat/lng coordinates
Every report SHALL store latitude and longitude as double values in the drift database.

#### Scenario: Coordinates saved with report
- **WHEN** user submits a report with location
- **THEN** system stores latitude and longitude in database
- **THEN** coordinates are included in sync payload to server
- **WHEN** user views report detail
- **THEN** system shows location pin on embedded map
