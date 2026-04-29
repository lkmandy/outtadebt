import 'package:outtadebt/config/route_config.dart';
import 'package:go_router/go_router.dart';

const _unprotectedPaths = {
  RoutePaths.login,
  RoutePaths.signup,
  RoutePaths.onboarding,
  RoutePaths.notFound,
};

/// Service responsible for context-free navigation in view models.
class RouterService {
  RouterService({
    required this.routes,
    String? initialLocation,
    bool Function()? isLoggedIn,
  }) : goRouter = GoRouter(
          routes: routes,
          initialLocation: initialLocation,
          redirect: isLoggedIn == null
              ? null
              : (context, state) {
                  final loggedIn = isLoggedIn();
                  final path = state.matchedLocation;
                  final isUnprotected = _unprotectedPaths.contains(path);

                  if (!loggedIn && !isUnprotected) return RoutePaths.login;
                  if (loggedIn && (path == RoutePaths.login || path == RoutePaths.signup)) {
                    return RoutePaths.home;
                  }
                  return null;
                },
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
