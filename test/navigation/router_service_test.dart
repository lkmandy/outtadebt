import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Navigation Tests', () {
    late RouterService routerService;
    late List<RouteBase> testRoutes;

    setUp(() {
      // Define test routes
      testRoutes = [
        GoRoute(path: '/', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/details',
          builder: (context, state) => DetailsPage(
            id: state.uri.queryParameters['id'],
            category: state.uri.queryParameters['category'],
          ),
        ),
        GoRoute(
          path: '/products/:id',
          builder: (context, state) => ProductPage(
            id: state.pathParameters['id'] ?? '',
            color: state.uri.queryParameters['color'],
            size: state.uri.queryParameters['size'],
          ),
        ),
        GoRoute(
          path: '/users/:userId/posts/:postId',
          builder: (context, state) => UserPostPage(
            userId: state.pathParameters['userId'] ?? '',
            postId: state.pathParameters['postId'] ?? '',
          ),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/404',
          builder: (context, state) => const NotFoundPage(),
        ),
        GoRoute(
          path: '/pop-scope',
          builder: (context, state) {
            final canPop = state.uri.queryParameters['canPop'] != 'false';
            return PopScopePage(
              key: ValueKey(state.uri.toString()),
              canPop: canPop,
            );
          },
        ),
      ];

      // Initialize router service with test routes
      routerService = RouterService(routes: testRoutes);
    });

    Widget createTestApp() {
      return MaterialApp.router(routerConfig: routerService.goRouter);
    }

    testWidgets('Initial route should be home', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(routerService.goRouter.state.uri.toString(), '/');
    });

    testWidgets('Go to should add new route to stack', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);

      routerService.push('/details');
      await tester.pumpAndSettle();

      expect(find.byType(DetailsPage), findsOneWidget);
      expect(find.byType(HomePage), findsNothing);
      expect(routerService.goRouter.state.uri.toString(), '/details');
    });

    testWidgets('Back should remove last route from stack', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      routerService.push('/details');
      await tester.pumpAndSettle();

      expect(find.byType(DetailsPage), findsOneWidget);

      routerService.pop();
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(DetailsPage), findsNothing);
      expect(
        routerService.goRouter.routeInformationProvider.value.uri.toString(),
        '/',
      );
    });

    testWidgets('Replace should replace last route in stack', (tester) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      routerService.push('/details');
      await tester.pumpAndSettle();

      expect(find.byType(DetailsPage), findsOneWidget);

      routerService.replace('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(DetailsPage), findsNothing);
      expect(routerService.goRouter.state.uri.toString(), '/settings');
    });

    testWidgets('Go should clear stack and navigate to new route', (
      tester,
    ) async {
      await tester.pumpWidget(createTestApp());
      await tester.pumpAndSettle();

      routerService.push('/details');
      await tester.pumpAndSettle();

      expect(find.byType(DetailsPage), findsOneWidget);

      routerService.go('/settings');
      await tester.pumpAndSettle();

      expect(find.byType(SettingsPage), findsOneWidget);
      expect(find.byType(DetailsPage), findsNothing);
      expect(routerService.goRouter.state.uri.toString(), '/settings');
    });

    testWidgets(
      'Go followed by multiple pushes should display only top route',
      (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/details');
        await tester.pumpAndSettle();

        expect(find.byType(DetailsPage), findsOneWidget);

        routerService.go('/');
        await tester.pumpAndSettle();
        routerService.push('/settings');
        await tester.pumpAndSettle();
        routerService.push('/details');
        await tester.pumpAndSettle();
        routerService.push('/products/456');
        await tester.pumpAndSettle();

        expect(find.byType(SettingsPage), findsNothing);
        expect(find.byType(DetailsPage), findsNothing);
        expect(find.byType(HomePage), findsNothing);
        expect(find.byType(ProductPage), findsOneWidget);
        expect(routerService.goRouter.state.uri.toString(), '/products/456');
      },
    );

    testWidgets(
      'Go resets navigation stack before pushing new routes',
      (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/details');
        await tester.pumpAndSettle();
        routerService.push('/products/456');
        await tester.pumpAndSettle();
        routerService.push('/users/123/posts/789');
        await tester.pumpAndSettle();

        expect(find.byType(UserPostPage), findsOneWidget);

        routerService.go('/');
        await tester.pumpAndSettle();
        routerService.push('/settings');
        await tester.pumpAndSettle();

        expect(find.byType(SettingsPage), findsOneWidget);
        expect(routerService.goRouter.state.uri.toString(), '/settings');
      },
    );

    testWidgets(
      'Go to invalid route should navigate to 404 and keep the previous route',
      (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/invalid-route');
        await tester.pumpAndSettle();

        expect(find.byType(NotFoundPage), findsOneWidget);
        expect(routerService.goRouter.state.uri.toString(), '/404');
      },
    );

    group('Route Parameters Tests', () {
      testWidgets('Should handle query parameters correctly', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/details?id=123&category=books');
        await tester.pumpAndSettle();

        expect(find.text('Details: 123 - books'), findsOneWidget);
        expect(routerService.goRouter.state.uri.queryParameters, {
          'id': '123',
          'category': 'books',
        });
      });

      testWidgets('Should handle path parameters correctly', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/products/456');
        await tester.pumpAndSettle();

        expect(find.text('Product: 456'), findsOneWidget);
        expect(routerService.goRouter.state.pathParameters, {
          'id': '456',
        });
      });

      testWidgets('Should handle multiple path parameters correctly', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/users/123/posts/789');
        await tester.pumpAndSettle();

        expect(find.text('User 123 - Post 789'), findsOneWidget);
        expect(routerService.goRouter.state.pathParameters, {
          'userId': '123',
          'postId': '789',
        });
      });

      testWidgets('Should handle mixed query and path parameters', (
        tester,
      ) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        routerService.push('/products/456?color=red&size=large');
        await tester.pumpAndSettle();

        expect(find.text('Product: 456 (red, large)'), findsOneWidget);
        expect(routerService.goRouter.state.uri.queryParameters, {
          'color': 'red',
          'size': 'large',
        });
      });
    });

    group('PopScope Tests', () {
      testWidgets('Should allow back when canPop is true', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to PopScope page
        routerService.push('/pop-scope');
        await tester.pumpAndSettle();

        expect(find.byType(PopScopePage), findsOneWidget);
        // Trigger pop through Navigator
        await tester.pageBack();
        await tester.pumpAndSettle();

        expect(find.byType(HomePage), findsOneWidget);
      });

      testWidgets('Should prevent back when canPop is false', (tester) async {
        await tester.pumpWidget(createTestApp());
        await tester.pumpAndSettle();

        // Navigate to PopScope page with canPop set to false
        routerService.push('/pop-scope?canPop=false');
        await tester.pumpAndSettle();

        expect(find.byType(PopScopePage), findsOneWidget);
        // Attempt to pop through Navigator
        await tester.pageBack();
        await tester.pumpAndSettle();

        // Verify pop was prevented
        expect(find.byType(PopScopePage), findsOneWidget);
      });
    });
  });
}

// Test pages
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Home')));
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({super.key, this.id, this.category});

  final String? id;
  final String? category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('Details: $id - $category')));
  }
}

class ProductPage extends StatelessWidget {
  const ProductPage({super.key, required this.id, this.color, this.size});

  final String id;
  final String? color;
  final String? size;

  @override
  Widget build(BuildContext context) {
    if (color != null || size != null) {
      return Scaffold(
        body: Center(child: Text('Product: $id ($color, $size)')),
      );
    }
    return Scaffold(body: Center(child: Text('Product: $id')));
  }
}

class UserPostPage extends StatelessWidget {
  const UserPostPage({super.key, required this.userId, required this.postId});

  final String userId;
  final String postId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('User $userId - Post $postId')));
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('Settings')));
  }
}

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('404')));
  }
}

// Add PopScopePage for testing PopScope behavior
class PopScopePage extends StatelessWidget {
  const PopScopePage({super.key, this.canPop = true, this.onPopInvoked});

  final bool canPop;
  final PopInvokedWithResultCallback<dynamic>? onPopInvoked;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: onPopInvoked,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pop Scope Page')),
        body: const Center(child: Text('Pop Scope Page')),
      ),
    );
  }
}
