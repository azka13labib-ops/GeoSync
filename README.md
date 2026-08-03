# GeoSync

Enterprise Attendance, Geofencing, and Workforce Management System

---

## 1. Project Overview

GeoSync is a highly scalable, secure, and modern attendance and workforce management application engineered for enterprise organizations, factories, and distributed multi-branch corporate networks. 

Built around a **Single Unified Application** architecture, GeoSync utilizes a cohesive Flutter codebase that seamlessly switches between executive HR management interfaces and employee attendance portals based on authenticated user roles. The system enforces strict security standards, combining hardware device UUID binding, precise GPS geofencing, and cryptographic Row-Level Security (RLS) policies to eliminate fraudulent attendance practices such as buddy punching and mock location manipulation.

---

## 2. Core Architectural Philosophy

GeoSync operates on three foundational design directives:
1. **Single Application, Dual Role System**: A single binary deployment serves both regular Employees and Executive Administrators (HR). Routing and UI presentation are dynamically determined by authenticated JWT claims and relational role mapping.
2. **Zero Public Enrollment**: To prevent unauthorized access, public self-registration is disabled. Employee accounts can only be provisioned by verified Administrators through secure, cloud-isolated backend functions without disrupting local session tokens.
3. **Defense-in-Depth Security**: Anti-cheat enforcement is handled simultaneously at the local client layer (Hardware UUID verification via secure storage and anti-mock GPS validation) and the cloud database layer (PostgreSQL RLS policies and atomic server timestamps).

---

## 3. System Capabilities & Features

### For Employees
- **Universal Authentication & Device Binding**: Secure NIK and password login. The initial login locks the employee's account to the physical hardware device UUID, automatically blocking unauthorized subsequent logins from foreign devices.
- **Precision Geofencing Check-In & Check-Out**: Verifies user GPS coordinates against designated corporate branch perimeters using spatial distance calculations before permitting attendance submissions.
- **Liveness Selfie Capture**: Requires live photograph capture during check-in and check-out to verify real-time physical presence.
- **Attendance & Leave Management**: Interactive portal for real-time leave requests, remaining leave balance tracking, and personal historical attendance review.

### For Administrators (HR / Executive)
- **Executive Analytics Dashboard**: High-level real-time overview of active workforce attendance, punctuality ratios, and immediate system notifications.
- **Secure Employee Provisioning**: Enroll new staff members and generate administrative credentials via isolated cloud runtime functions without triggering self-logout bugs.
- **Dynamic Branch Work Hour Configuration**: Configure localized operating schedules per office branch, including attendance opening hours, on-time cutoffs, and customizable tardiness tolerance thresholds.
- **One-Click Payroll Report Generation**: Automated aggregation and export of verified corporate attendance records into formatted spreadsheet reports for payroll processing.

---

## 4. Technology Stack

| Layer | Technology | Purpose |
| :--- | :--- | :--- |
| **Mobile Application** | Flutter & Dart | Cross-platform client targeting Android & iOS |
| **State Management** | Flutter Riverpod (v2+) | Reactive application state and lifecycle control |
| **Navigation & Routing** | GoRouter | Role-based declarative navigation and protection guards |
| **User Interface** | Vanilla Material 3 + Glassmorphic Tokens | Enterprise dark-mode UI with high visual hierarchy |
| **Database & API** | Supabase (PostgreSQL) | Relational database, instant PostgREST API, and storage |
| **Security Layer** | PostgreSQL RLS & Crypt | Server-side execution rules and password hashing |
| **Server-Side Runtime** | Deno & TypeScript | Cloud-isolated Supabase Edge Functions for admin tasks |

---

## 5. Repository Structure

```text
GeoSync/
├── backend/
│   ├── 001_initial_schema.sql         # Relational database schema, ENUMs, indices, and RLS rules
│   └── supabase/
│       └── functions/
│           └── create-employee/       # Deno/TS Edge Function for safe admin account enrollment
├── docs/
│   ├── PRD.md                         # Product Requirement Document and core architecture rules
│   ├── architecture.md                # Detailed technical diagrams and component workflows
│   ├── database.md                    # Data dictionary, relationships, and SQL migration logs
│   ├── design-system.md               # Visual design tokens, color palette, and component specs
│   └── tasks/                         # Modular feature execution task tracking
└── mobile/                            # Flutter mobile application codebase
    ├── lib/
    │   ├── core/                      # Constants, network wrapper, theme, and utility modules
    │   ├── features/                  # Feature-first modular layers (Auth, Attendance, Admin)
    │   └── navigation/                # GoRouter configurations and automated role routing
    └── pubspec.yaml                   # Dependency manifests and version locks
```

---

## 6. Setup & Installation Guide

### Prerequisites
- **Flutter SDK**: Version 3.24 or above with standard Android/iOS development tooling installed.
- **Windows Systems**: Developer Mode must be enabled in Windows Settings to allow symbolic link support for native Flutter plugins and security modules.
- **Supabase Account & CLI**: Required for local testing or cloud database staging deployments.

### Step 1: Database Migration
1. Log into your Supabase project console and open the SQL Editor.
2. Execute the entire codeblock provided in `backend/001_initial_schema.sql` to generate the foundational tables (`departments`, `office_locations`, `employees`, `work_hour_settings`, `attendance`, `leave_requests`, and `audit_logs`).
3. Ensure that Row-Level Security (RLS) policies remain active across all tables as specified in the schema file.

### Step 2: Environment Security & Configuration
Do not commit raw API credentials or cloud project URLs into public git repositories. To set up your environment locally:

1. Locate the configuration file within the mobile codebase at `mobile/lib/core/constants/app_constants.dart` (or create your secure local target).
2. Assign your Supabase project endpoints using environment parameters or build configurations without hardcoding sensitive strings into version-controlled files:

```dart
class AppConstants {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL', 
    defaultValue: 'YOUR_SUPABASE_PROJECT_URL',
  );
  static const String supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY', 
    defaultValue: 'YOUR_SUPABASE_PUBLISHABLE_ANON_KEY',
  );
}
```

When building or executing the Flutter application, provide these variables securely via command line parameters:
```bash
flutter run --dart-define=SUPABASE_URL=https://myproject.supabase.co --dart-define=SUPABASE_PUBLISHABLE_KEY=my_publishable_token_here
```

### Step 3: Edge Function Deployment
To enable secure Administrative provisioning without self-logout bugs, deploy the Deno Edge Function to your cloud project:

```bash
cd backend
supabase functions deploy create-employee --project-ref YOUR_PROJECT_REFERENCE_ID
```
Ensure your server environment has `SUPABASE_SERVICE_ROLE_KEY` defined natively in your cloud Supabase dashboard under Edge Function configurations. Never expose the service role key within the Flutter application client.

### Step 4: Building & Running the Mobile Application
1. Navigate into the mobile root directory:
   ```bash
   cd mobile
   ```
2. Download and synchronize required packages:
   ```bash
   flutter pub get
   ```
3. Run formal syntax and lint verification:
   ```bash
   flutter analyze
   ```
4. Launch the application on an active device or emulator:
   ```bash
   flutter run
   ```

---

## 7. Development Standards & Commit Philosophy

This project strictly adheres to atomic development steps and **Semantic Commit Formatting**. Every commit must target a discrete functional change and begin with an standard prefix:

- `feat:` for brand new capabilities, screens, or architectural modules.
- `fix:` for functional bug remediations or logic corrections.
- `refactor:` for code structural improvements without modifying runtime behaviors.
- `docs:` for architectural documentation, task progress tracking, or inline comments.
- `chore:` for dependency upgrades, linter adjustments, or repository maintenance.

---

## 8. License & Property Notice

GeoSync is proprietary software developed for enterprise corporate deployment. All rights regarding architecture, database designs, and implementation methodologies are reserved by the designated organization and project stakeholders.
