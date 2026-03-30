# Flutter Kit - Project Guidelines

## Architecture Overview

- Follow MVVM (Model-View-ViewModel)
- Use ValueNotifier for state management, always created within a ViewModel
- ViewModels handle page-specific state and logic
- Views should only contain UI code and functionality related to BuildContext

### When to create a Service vs keeping state in a ViewModel

- **Default to ViewModel.** If state belongs to a single screen, keep it in the ViewModel.
- **Create a Service only when** multiple ViewModels need to read or write the same state (e.g., auth status, user preferences, a shared cart). If only one ViewModel uses it, it's not a service.
- Services are registered in the locator (`config/locator_config.dart`) and injected into ViewModels via constructor.

## Architecture Rules

1. Views should never use services directly, only through ViewModels.
2. Views should contain no logic where possible — defer to the ViewModel.
3. ViewModels should never use other ViewModels. Move shared functionality into a service.
4. ViewModels should not have access to BuildContext. Defer to the View.
5. Dependencies should always be injected through the constructor.
6. ViewModels are responsible for cleaning up their own resources. Views call the ViewModel's dispose method.
7. ValueNotifiers and other resources should be disposed in the ViewModel's dispose method, not in the View.

## State Management

- For single values, use `ValueNotifier<T>` directly
- For multiple related values, create a state class and use `ValueNotifier<StateClass>`
- This avoids having multiple ValueNotifiers and ensures atomic updates

Example with state class:

```dart
class DogState {
  final String name;
  final int age;
  final bool isHungry;

  const DogState({
    required this.name,
    required this.age,
    required this.isHungry,
  });

  DogState copyWith({
    String? name,
    int? age,
    bool? isHungry,
  }) {
    return DogState(
      name: name ?? this.name,
      age: age ?? this.age,
      isHungry: isHungry ?? this.isHungry,
    );
  }
}

class HomeViewModel {
  const HomeViewModel({required NotifyService notifyService})
    : _notifyService = notifyService;

  final NotifyService _notifyService;

  final ValueNotifier<DogState> _dogState = ValueNotifier(
    const DogState(name: 'Rex', age: 3, isHungry: false),
  );

  ValueListenable<DogState> get dogState => _dogState;

  void feedDog() {
    _dogState.value = _dogState.value.copyWith(isHungry: false);
    _notifyService.setToastEvent(ToastEventSuccess(message: 'Dog is fed'));
  }

  void dispose() {
    _dogState.dispose();
  }
}
```

Example of a View using a ViewModel:

```dart
class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel = HomeViewModel(
    notifyService: locator<NotifyService>(),
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  // build method
}
```

## Directory Structure

- `lib/`
  - `config/`: Configure routes and services
  - `core/`: Core application infrastructure
    - `abstractions/`: Wrapping external dependencies
    - `ui/`: Plain widgets and design system components
      - `constants/`: Design tokens (colors, spacing, text styles, etc.)
    - `utils/`: Shared utilities and core services
      - `http/`: HTTP client abstractions and implementations
      - `internal_notification/`: App-wide notification system
      - `l10n/`: Internationalization and localization
      - `navigation/`: Routing and navigation utilities
      - `locator.dart`: Service locator setup
  - `feature_name/`: Feature-specific code
    - For simple features (<=5 files):
      Place files directly in feature folder (e.g., `home/`, `startup/`, `not_found/`)
    - For complex features:
      - `models/`: Feature-specific models
      - `services/`: Feature-specific services
      - `viewmodels/`: Feature-specific ViewModels
      - `views/`: Feature UI components
      - `repositories/`: (Optional) Feature-specific data layer

## Service Locator and Dependency Injection

The app uses a custom service locator defined in `core/utils/locator.dart`.

### Registering Services

Services are registered in `config/locator_config.dart`:

```dart
final modules = [
  Module<RouterService>(
    builder: () => RouterService(routes: routes),
    lazy: false, // Created immediately at app startup
  ),
  Module<NotifyService>(
    builder: () => NotifyService(),
    lazy: false,
  ),
  Module<HttpAbstraction>(
    builder: () => HttpAbstraction(interceptors: [...]),
    lazy: true, // Created when first requested
  ),
];
```

### Using Services in ViewModels

ViewModels inject services through constructor parameters:

```dart
class HomeViewModel {
  const HomeViewModel({
    required NotifyService notifyService,
    required RouterService routerService,
  }) : _notifyService = notifyService,
       _routerService = routerService;

  final NotifyService _notifyService;
  final RouterService _routerService;
}
```

### Accessing Services in Views

Views inject services when creating ViewModels:

```dart
class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel = HomeViewModel(
    notifyService: locator<NotifyService>(),
    routerService: locator<RouterService>(),
  );
}
```

### Lazy vs Non-Lazy Services

- **`lazy: false`** - Created immediately at app startup (e.g., RouterService, NotifyService)
- **`lazy: true`** - Created when first requested (e.g., HttpAbstraction)

## Routing and Navigation

The app uses `go_router` with a thin `RouterService` wrapper for context-free navigation in ViewModels.

### Route Paths

Route paths are defined as typed constants in `config/route_config.dart`:

```dart
abstract final class RoutePaths {
  static const home = '/';
  static const notFound = '/404';
}
```

Always use `RoutePaths` constants instead of hardcoded path strings.

### Creating New Routes

Define routes in `config/route_config.dart`. **Use nested routes** to define parent-child relationships. go_router uses the hierarchy to build the navigation stack — child routes automatically get back navigation to their parent on mobile, while the URL updates on web.

```dart
final routes = [
  GoRoute(
    path: RoutePaths.home,
    pageBuilder: (context, state) => _buildPage(const HomeView(), state),
    routes: [
      // Child of home — navigating here builds stack: home → profile
      GoRoute(
        path: 'profile/:userId', // no leading / for child routes
        pageBuilder: (context, state) {
          final userId = state.pathParameters['userId'] ?? '';
          return _buildPage(ProfileView(userId: userId), state);
        },
      ),
    ],
  ),
];
```

When adding a new route:
1. Add a constant to `RoutePaths`
2. Nest it under its logical parent route
3. Use a relative path (no leading `/`) for child routes — go_router builds the full path from the hierarchy

### go vs push

- **Always default to `go`** for page navigation. It updates the URL on web, and go_router builds the correct back stack from the route hierarchy on mobile.
- **Only use `push`** for temporary overlays that shouldn't have their own URL — bottom sheets, dialogs, multi-step flows.

### Navigation in ViewModels

ViewModels inject `RouterService` and use it for navigation:

```dart
class ProfileViewModel {
  final RouterService _routerService;

  ProfileViewModel({required RouterService routerService})
    : _routerService = routerService;

  void navigateToHome() {
    _routerService.go(RoutePaths.home);
  }
}
```

### RouterService API

- `go(location)` - Navigate to a route. Updates the URL. Builds back stack from route hierarchy. **Use this by default.**
- `push(location)` - Push onto the stack without updating the URL. Only for modals/dialogs/flows.
- `replace(location)` - Replace the current route
- `pop()` - Go back (safe, checks `canPop()`)
- `canPop()` - Check if back navigation is possible

### Unknown Routes

Unknown routes are automatically redirected to the 404 page via `onException` in `RouterService`.

## Coding Conventions

- Use PascalCase for class names (e.g., `TodoService`, `HomeViewModel`)
- Use camelCase for variables and methods
- Use comments sparingly — prefer self-documenting code through descriptive naming
- All state in Services and ViewModels should use `ValueNotifier`
- ViewModels must receive Services through constructor injection and forward their state with a getter
- Views must use `ValueListenableBuilder` for state updates

### File Naming

Simple feature (flat structure):
- `{feature_name}/{name}_model.dart`
- `{feature_name}/{name}_service.dart`
- `{feature_name}/{name}_view_model.dart`
- `{feature_name}/{name}_view.dart`

Complex feature (with subdirectories):
- `{feature_name}/models/{name}.dart`
- `{feature_name}/services/{name}_service.dart`
- `{feature_name}/viewmodels/{name}_view_model.dart`
- `{feature_name}/views/{name}_view.dart`

## Testing

Tests should mirror the source file location in the `test/` folder.

- **Unit tests**: input <-> output
- **Widget tests**: action <-> result

### Testing Requirements

- Unit tests should focus on methods with clear input/output transformations
- Widget tests required for Views
- Follow Arrange-Act-Assert pattern
- Mock dependencies using Fake classes
- Widget tests should test the View with its real ViewModel (no mocking)
- Simple ViewModels with functionality covered by widget tests may not need separate unit tests
- Tests should verify behavior, not implementation details

### Widget Test Example

```dart
void main() {
  testWidgets('CounterView increments counter when button is pressed', (tester) async {
    await tester.pumpWidget(MaterialApp(home: CounterView()));

    expect(find.text('Counter: 0'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text('Counter: 1'), findsOneWidget);
  });
}
```

## Skills

Context-specific patterns loaded automatically via `.claude/skills/`:

| Skill | When Loaded |
|-------|------------|
| `create-feature` | Scaffolding a new feature (View, ViewModel, route) |
| `create-service` | Creating an app-wide service for shared state between ViewModels |
