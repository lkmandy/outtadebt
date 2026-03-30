import 'package:outtadebt/config/route_config.dart';
import 'package:outtadebt/core/utils/navigation/router_service.dart';

class NotFoundViewModel {
  final RouterService _routerService;

  NotFoundViewModel({required RouterService routerService})
    : _routerService = routerService;

  void navigateToHome() {
    _routerService.go(RoutePaths.home);
  }
}
