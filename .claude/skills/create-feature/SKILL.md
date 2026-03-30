---
name: create-feature
description: Scaffold a new feature with View, ViewModel, and route registration
argument-hint: [feature-name]
---

Create a new feature following the project's MVVM architecture. Read `agents.md` for full conventions.

## Templates

Use these templates, replacing `{{FeatureName}}` with PascalCase and `{{feature_name}}` with snake_case of the argument:

- `view_model.dart.md` → `lib/$ARGUMENTS/${ARGUMENTS}_view_model.dart`
- `view.dart.md` → `lib/$ARGUMENTS/${ARGUMENTS}_view.dart`

## Steps

1. Create the feature directory: `lib/$ARGUMENTS/`
2. Create the ViewModel using `view_model.dart.md` template
3. Create the View using `view.dart.md` template
4. Add a path constant to `RoutePaths` in `lib/config/route_config.dart`
5. Add a `GoRoute` to the `routes` list in `lib/config/route_config.dart` using `_buildPage`
6. Run `dart format .` on the new files
