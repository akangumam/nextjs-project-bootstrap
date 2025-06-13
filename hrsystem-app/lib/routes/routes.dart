import 'package:flutter/material.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/task/task_screen.dart';
import '../screens/expense/expense_screen.dart';
import '../screens/leave/leave_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/messages/messages_screen.dart';
import '../screens/notifications/notifications_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String attendance = '/attendance';
  static const String task = '/task';
  static const String expense = '/expense';
  static const String leave = '/leave';
  static const String profile = '/profile';
  static const String messages = '/messages';
  static const String notifications = '/notifications';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        );
      case attendance:
        return MaterialPageRoute(
          builder: (_) => const AttendanceScreen(),
        );
      case task:
        return MaterialPageRoute(
          builder: (_) => const TaskScreen(),
        );
      case expense:
        return MaterialPageRoute(
          builder: (_) => const ExpenseScreen(),
        );
      case leave:
        return MaterialPageRoute(
          builder: (_) => const LeaveScreen(),
        );
      case profile:
        return MaterialPageRoute(
          builder: (_) => const ProfileScreen(),
        );
      case messages:
        return MaterialPageRoute(
          builder: (_) => const MessagesScreen(),
        );
      case notifications:
        return MaterialPageRoute(
          builder: (_) => const NotificationsScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
