import 'package:outtadebt/config/route_config.dart';
import 'package:go_router/go_router.dart';

/// Service responsible for context-free navigation in view models.
class RouterService {
  RouterService({required this.routes, String? initialLocation})
    : goRouter = GoRouter(
        routes: routes,
        initialLocation: initialLocation,  // ← add this
        onException: (context, state, router) {
          if (state.uri.path != RoutePaths.notFound) {
            router.go(RoutePaths.notFound);
          }
        },
      );
      
  final List<RouteBase> routes;
  final GoRouter goRouter;

  void go(String location, {Object? extra}) {
    goRouter.go(location, extra: extra);
  }

  Future<T?> push<T>(String location, {Object? extra}) {
    return goRouter.push<T>(location, extra: extra);
  }

  void replace(String location, {Object? extra}) {
    goRouter.replace(location, extra: extra);
  }

  bool canPop() {
    return goRouter.canPop();
  }

  void pop<T extends Object?>([T? result]) {
    if (!goRouter.canPop()) {
      return;
    }
    goRouter.pop(result);
  }

  void dispose() {
    goRouter.dispose();
  }
}
