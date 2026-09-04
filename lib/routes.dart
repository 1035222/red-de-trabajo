import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../screens/search_screen.dart';
import '../screens/publish_screen.dart';
import '../screens/chat_list_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/my_services_screen.dart';
import '../screens/my_profile_screen.dart';
import '../screens/portfolio_screen.dart';
import '../screens/reviews_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String search = '/search';
  static const String publish = '/publish';
  static const String chatList = '/chat';
  static const String chatDetail = '/chat/:id';
  static const String profile = '/profile';
  static const String serviceDetail = '/service/:id';
  static const String myServices = '/my-services';
  static const String myProfile = '/my-profile';
  static const String editProfile = '/edit-profile';
  static const String portfolio = '/portfolio';
  static const String reviews = '/reviews';
  static const String settings = '/settings';
  static const String notifications = '/notifications';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case search:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      case publish:
        return MaterialPageRoute(builder: (_) => const PublishScreen());
      case chatList:
        return MaterialPageRoute(builder: (_) => const ChatListScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case myServices:
        return MaterialPageRoute(builder: (_) => const MyServicesScreen());
      case myProfile:
        return MaterialPageRoute(builder: (_) => const MyProfileScreen());
      case portfolio:
        return MaterialPageRoute(builder: (_) => const PortfolioScreen());
      case reviews:
        return MaterialPageRoute(builder: (_) => const ReviewsScreen());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      case notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      default:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
    }
  }
}
