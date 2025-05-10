import 'package:flutter/widgets.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/feature_screen.dart';

class Routes {
  static const login = '/';
  static const dashboard = '/dashboard';
  static const features = '/features';

  static Map<String, WidgetBuilder> get all => {
    login: (_) => const LoginScreen(),
    dashboard: (_) => const DashboardScreen(),
    features: (_) => const FeatureScreen(),
  };
}
