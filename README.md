---
# Music School Management Database
Coursework for the **Databases** class at **UBB (Babeș-Bolyai University)**, 2nd year.  
Implements a SQL Server database for managing a music school, plus a configurable
WinForms application for viewing and editing data.
---
## Database Setup
Run the scripts in this order in SSMS:
1. `db/schema/create_tables.sql` - creates all tables and relationships
2. `db/seeds/insert.sql` - populates sample data
---
## Database Schema
The database models core music school operations across these entities:
| Table | Description |
|-------|-------------|
| `Teachers` | Teacher records and assigned subjects |
| `Students` | Student personal data |
| `Instruments` | Instrument catalog |
| `Rooms` | Room metadata and capacity |
| `Lessons` | Lesson details with teacher, instrument, room |
| `Grades` | Student evaluations per lesson |
| `InstrumentRentals` | Instrument rental records per student |
| `Performances` | Performance events |
| `PerformanceParticipants` | Students and roles per performance |
---
## WinForms Application
A Windows Forms app that connects to the MusicSchool database and displays
a configurable parent-child table relationship using bound DataGridViews.
### Features
- Displays two related tables side by side (parent → child)
- Editable child grid with save support
- Reload button to refresh data without restarting
- Fully configurable via `App.config` - no hardcoded values
### Configuration
All settings are defined in `MusicSchoolFormsApp/WindowsFormsAppLAB1/App.config`:
| Key | Description |
|-----|-------------|
| `ConnectionString` | SQL Server connection string |
| `FormCaption` | Window title |
| `ParentTable` | Name of the parent table |
| `ParentQuery` | SQL query for the parent grid |
| `ParentLabel` | Label shown above the parent grid |
| `ParentKey` | Primary key column of the parent table |
| `ChildTable` | Name of the child table |
| `ChildQuery` | SQL query for the child grid |
| `ChildLabel` | Label shown above the child grid |
| `ChildKey` | Foreign key column linking to the parent |
| `RelationName` | Name of the DataRelation |
### Switching Table Pairs
The `App.config` includes a commented-out block for a different table pair
(`Students` -> `InstrumentRentals`). To switch, comment out the active block
and uncomment the alternative one.