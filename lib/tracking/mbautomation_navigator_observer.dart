import 'package:flutter/widgets.dart';
import 'package:mbautomation/mbautomation.dart';

/// Navigator observer to track page route automatically.
/// The name of the view sent to MBurger is the name of the `RouteSettings` object.
class MBAutomationNavigatorObserver extends RouteObserver<PageRoute<dynamic>> {
  /// Sends a screen view with the PageRoute passed.
  /// If the settings object of the route has a value
  /// @param route The page route.
  void _sendScreenView(PageRoute<dynamic> route) {
    final String screenName = route.settings.name;
    if (screenName != null) {
      MBAutomation.trackScreenView(screenName, null);
    }
  }

  /// Function called when a route is pushed.
  @override
  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      _sendScreenView(route);
    }
  }

  /// Function called when a route is replaced.
  @override
  void didReplace({Route<dynamic> newRoute, Route<dynamic> oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      _sendScreenView(newRoute);
    }
  }

  /// Function called when a route is popped.
  @override
  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    super.didPop(route, previousRoute);
    if (previousRoute is PageRoute && route is PageRoute) {
      _sendScreenView(previousRoute);
    }
  }
}
