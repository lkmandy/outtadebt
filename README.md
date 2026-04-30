# OutaDebt

A Flutter app for tracking, managing, and eliminating personal debt — with social circles for community-based financial support.

> Scaffolded from the [Hungrimind Flutter Boilerplate](https://hungrimind.com) — a minimal-dependency MVVM foundation built for scalable, testable Flutter apps.

## Features

### Debt Tracking
- Add and manage multiple debts with balance, interest rate, minimum payment, and due date
- Categorize by type: Credit Card, Student Loan, Mortgage, Car Loan, Medical Bill, or Other
- Color-coded debt types for at-a-glance clarity

### Progress & Analytics
- Dashboard with total debt and per-category breakdown
- 12-month payoff projection chart with interest calculations
- Pie chart showing debt distribution across types
- Debt-free date estimator based on adjustable monthly payment amounts
- Interest savings calculator comparing simulated vs. minimum payments

### Social Circles
- Create or join circles for community-based debt accountability
- Categories: Credit Card, Student Loan, Mortgage, Car Loan, General
- Track member contributions toward shared goals
- View circle details and member participation

### Auth & Persistence
- Email/password signup and login
- Session persistence via SharedPreferences
- Display name support

## Tech Stack

- **Flutter** (iOS, Android, Web, Windows)
- **Firebase** — Firestore database, Firebase Core
- **GoRouter** — navigation and deep linking
- **fl_chart** — analytics charts and visualizations
- **ValueNotifier / MVVM** — state management
- **SharedPreferences** — local session persistence
- **Lottie / Flutter SVG** — animations and graphics

## Architecture

Follows MVVM with a service locator for dependency injection:

- `Views` — UI only, no logic
- `ViewModels` — page state and business logic via `ValueNotifier`
- `Services` — shared state across multiple ViewModels, registered in the locator
- `config/locator_config.dart` — service registration
- `config/route_config.dart` — typed route constants and GoRouter setup

See [agents.md](agents.md) for full architecture rules, conventions, and code examples.

## Getting Started

```bash
flutter pub get
flutter run
```

Firebase is required. Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) before running on those platforms.
