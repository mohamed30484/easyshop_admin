# Easy Shop Merchant Portal

> A Flutter-based mobile administration application for merchants to manage their store profile, catalog, categories, and customer orders through a REST API.

Easy Shop Merchant Portal provides a focused operational workspace for store administrators. It supports a complete merchant onboarding flow, secure authentication with OTP verification, product and category management, order monitoring, profile management, and a dashboard that summarizes key store activity.

> **Note:** This repository contains the Flutter merchant/admin application. It consumes a separate backend API; the backend implementation is not included here.

## Project Overview

The app is designed for merchants who need a practical mobile interface for managing an e-commerce store. After registration and authentication, an administrator can access an at-a-glance dashboard, maintain product categories and products, review customer orders, inspect order details, and update their business profile.

The application follows a feature-first implementation of Clean Architecture. Each major business capability is organized into presentation, domain, and data layers, helping the project remain maintainable as features and API integrations grow.

## Tech Stack

| Area | Technology |
| --- | --- |
| Framework | Flutter |
| Language | Dart |
| State management | `flutter_bloc` with Cubits and sealed state classes |
| Dependency injection | `get_it` |
| HTTP client | `dio` |
| Functional error handling | `dartz` using `Either<Failure, T>` |
| Value equality | `equatable` |
| Configuration | `flutter_dotenv` |
| Local persistence | `shared_preferences` |
| Media and documents | `image_picker` and `file_picker` |
| External actions | `url_launcher` |
| Backend integration | REST API with JSON and multipart/form-data requests |
| Native targets | Android and iOS |

## Architecture

The project uses **Clean Architecture** with a feature-first folder layout. Dependencies point inward: the presentation layer calls domain use cases, use cases depend on repository abstractions, and data-layer repositories implement those abstractions using remote API data sources.

```text
Presentation → Domain → Data → Remote REST API
     ↑            ↑        ↑
   Cubits      Use cases  Repositories / Data sources
```

### Layers

- **Presentation** contains pages, reusable widgets, Cubits, and UI states. Cubits coordinate screen actions and expose loading, success, empty, and failure states to the interface.
- **Domain** contains business entities, repository contracts, and single-purpose use cases. This layer does not depend on Flutter or HTTP implementation details.
- **Data** contains API data sources, JSON models, and repository implementations. Models map potentially variable API response fields into stable domain entities.
- **Core** contains shared configuration, network setup, token interception, error types, local profile storage, media URL resolution, theme values, and responsive breakpoints.
- **App** composes the application shell, theme, and dependency-injection container.

### Dependency injection

`GetIt` registers shared infrastructure and repositories as lazy singletons, while Cubits are registered as factories. This gives every page an independent state-management instance while reusing the underlying API client and repositories.

### Networking and authentication

The application uses a centralized `Dio` client with:

- Configurable API base URL, storage base URL, and API key through environment variables.
- JSON request headers and request timeouts.
- An `AdminTokenInterceptor` that reads the locally stored token and attaches it as a `Bearer` authorization header.
- Multipart upload support for registration documents and profile images.
- Repository-level translation of Dio and parsing errors into user-friendly `Failure` messages.

## Features

- Merchant registration across a guided three-step onboarding flow.
- Registration fields for personal and business information, national ID, address, optional location coordinates, profile photo, commercial register, and tax card.
- Camera or gallery selection for profile images.
- Admin login, OTP verification, OTP resend, logout, and persisted session token handling.
- Local caching of the authenticated administrator profile using Shared Preferences.
- Dashboard with total products, total orders, pending orders, total categories, recent orders, and recent products.
- Pull-to-refresh support on data-driven screens.
- Product listing and management workflows, including create, update, delete, visibility, quantities, prices, category assignment, and image handling.
- Category CRUD workflows using category slugs for update and delete operations.
- Order listing with customer, payment, date, item-count, status, and total information.
- Order-detail views with customer information, delivery information, items, totals, and payment data.
- Location-related order data, including latitude and longitude, with external URL launching where applicable.
- Merchant profile retrieval and update flows.
- Responsive layout constraints for mobile and tablet-sized screens.
- Consistent Material 3 theme with reusable colors, form styling, status indicators, loading states, empty states, retry actions, and error feedback.

## Testing

The project is structured to support testing at multiple levels:

| Test type | Recommended scope |
| --- | --- |
| Unit tests | Use cases, Cubits, parameter validation, model parsing, and repository error mapping |
| Widget tests | Forms, validation messages, loading states, empty states, error views, and page interactions |
| Integration tests | Authentication flow, token persistence, API-backed catalog workflows, and order navigation |

Run the standard Flutter test suite with:

```bash
flutter test
```

Before adding or extending tests, consider mocking remote data sources or repositories so domain and presentation behavior can be verified independently of the live API.

## Folder Structure

```text
lib/
├── app/
│   ├── app.dart                      # MaterialApp setup and global providers
│   ├── injection_container.dart      # GetIt registrations
│   └── theme.dart                    # Application theme
├── core/
│   ├── constants/                    # API configuration, colors, breakpoints
│   ├── error/                        # Failure types
│   ├── network/                      # Dio client and token interceptor
│   ├── services/                     # Local profile persistence
│   └── utils/                        # Media URL resolution and shared helpers
├── features/
│   ├── auth/
│   │   ├── data/                     # Auth API source, models, repository implementation
│   │   ├── domain/                   # Auth entities, repository contract, use cases
│   │   └── presentation/             # Auth Cubit, states, onboarding and login pages
│   ├── categories/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── home/
│   │   └── presentation/             # Dashboard Cubit and home page
│   ├── orders/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/             # Order list and details pages
│   ├── products/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── profile/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── main.dart                          # Environment loading, DI setup, application entry point
```

Each data-driven feature generally follows the same internal pattern:

```text
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── models/                        # When UI-specific models are needed
    ├── pages/
    └── widgets/
```

## How to Run

### Prerequisites

- Flutter SDK installed and available in your terminal.
- A configured Android emulator/device or iOS simulator/device.
- Access to the backend REST API.
- An API key if the backend requires one.

### Setup

1. Clone the repository.

```bash
git clone <your-repository-url>
cd easyshopadmin
```

2. Install dependencies.

```bash
flutter pub get
```

3. Create a `.env` file in the project root. The file is intentionally not meant to be committed because it may contain environment-specific credentials.

```env
API_BASE_URL=https://your-api-domain.com/api/
STORAGE_BASE_URL=https://your-api-domain.com
API_KEY=your-api-key
```

4. Confirm that `.env` is declared in `pubspec.yaml` under Flutter assets, then run the app.

```bash
flutter run
```

### Useful commands

```bash
flutter analyze
flutter test
flutter clean
flutter pub get
flutter run
```

## API Endpoints

The Flutter client is organized around the following admin API areas:

| Area | Endpoint group |
| --- | --- |
| Authentication | `admin/login`, `admin/logout`, `admin/otp/verify`, `admin/otp/resend`, `admin/register` |
| Profile | `admin/profile`, `admin/profile/update` |
| Categories | `admin/categories` and category create, update, and delete routes |
| Products | `admin/products` and product create, update, and delete routes |
| Orders | `admin/orders` |

The exact backend contract, validation rules, and route middleware are owned by the API service. Keep the `.env` values aligned with the deployed backend environment.

## Screenshots

Add product screenshots to `docs/screenshots/` and replace the placeholder paths below with your own images.

| Screen | Preview |
| --- | --- |
| Login | `![Login](https://drive.google.com/uc?export=view&id=1iYGdKHvfxxdXHuqCvJy5iarCvUObO1JH)` |
| Merchant registration | `![Registration](docs/screenshots/register.png)` |
| Dashboard | `![Dashboard](docs/screenshots/dashboard.png)` |
| Products | `![Products](docs/screenshots/products.png)` |
| Orders | `![Orders](docs/screenshots/orders.png)` |
| Order details | `![Order details](docs/screenshots/order-details.png)` |
| Profile | `![Profile](docs/screenshots/profile.png)` |

> Remove rows for screens you do not plan to document, or replace the code-formatted placeholders with actual Markdown image tags after adding the files.

## Future Improvements

- Add a dedicated dashboard endpoint to avoid fetching products, orders, and categories separately for summary statistics.
- Introduce pagination, filtering, searching, and sorting for product and order lists.
- Add order-status update workflows if supported by the backend.
- Add image caching, upload progress, and multiple product-image support.
- Improve offline behavior with local caching and synchronization indicators.
- Expand automated coverage with mocked repository unit tests, Cubit tests, widget tests, and end-to-end integration tests.
- Add route management with a declarative navigation solution and deep-link support.
- Introduce internationalization and right-to-left layout support for multilingual merchant teams.
- Add CI workflows for formatting, static analysis, tests, and Android/iOS builds.
- Document the backend API contract with OpenAPI or Postman collections.

## Social Links

- GitHub: [@your-github-username](https://github.com/your-github-username)
- LinkedIn: [Your LinkedIn Profile](https://www.linkedin.com/in/your-linkedin-username/)
- Portfolio: [Your Portfolio](https://your-portfolio-domain.com)
- Email: [your-email@example.com](mailto:your-email@example.com)

Replace these placeholders with the project maintainer’s actual public links.

## Contributing

Contributions, suggestions, and bug reports are welcome. Please open an issue to discuss significant changes before submitting a pull request.

When contributing:

- Keep feature boundaries aligned with the existing Clean Architecture structure.
- Add or update tests when changing business logic or presentation behavior.
- Run `flutter analyze` and `flutter test` before opening a pull request.
- Avoid committing API keys, tokens, or environment files.

## License

Add a license file to the repository and state the selected license here, for example: `MIT License`.
