```dart
import 'package:flutter/foundation.dart';

class {{FeatureName}}ViewModel {
  {{FeatureName}}ViewModel();

  // Add service dependencies via constructor injection:
  // {{FeatureName}}ViewModel({required SomeService someService})
  //   : _someService = someService;

  final ValueNotifier<int> counter = ValueNotifier<int>(0);

  void dispose() {
    counter.dispose();
  }
}
```
