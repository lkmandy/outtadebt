```dart
import 'package:flutter/material.dart';
import 'package:outtadebt/core/utils/locator.dart';
import 'package:outtadebt/{{feature_name}}/{{feature_name}}_view_model.dart';

class {{FeatureName}}View extends StatefulWidget {
  const {{FeatureName}}View({super.key});

  @override
  State<{{FeatureName}}View> createState() => _{{FeatureName}}ViewState();
}

class _{{FeatureName}}ViewState extends State<{{FeatureName}}View> {
  late final {{FeatureName}}ViewModel _viewModel = {{FeatureName}}ViewModel();

  // If the ViewModel needs services, inject them:
  // late final {{FeatureName}}ViewModel _viewModel = {{FeatureName}}ViewModel(
  //   someService: locator<SomeService>(),
  // );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('{{FeatureName}}')),
      body: const Center(
        child: Text('{{FeatureName}}'),
      ),
    );
  }
}
```
