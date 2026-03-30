---
name: create-service
description: Create a new app-wide service and register it in the locator
argument-hint: [service-name]
---

Create a new service for shared state between ViewModels. Read `agents.md` for full conventions.

## Templates

Use this template, replacing `{{ServiceName}}` with PascalCase and `{{service_name}}` with snake_case of the argument:

- `service.dart.md` → `lib/core/utils/$ARGUMENTS/${ARGUMENTS}_service.dart`

## Steps

1. Create the service file using `service.dart.md` template
2. Register it in `lib/config/locator_config.dart`:
   - Add a `Module<{{ServiceName}}Service>` to the `modules` list
   - Use `lazy: false` if needed at startup, `lazy: true` if it can wait
3. Inject it into ViewModels via constructor — never access `locator` from a ViewModel
