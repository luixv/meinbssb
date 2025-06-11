import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';

class BaseScreenLayout extends StatelessWidget {
  const BaseScreenLayout({
    super.key,
    required this.title,
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    required this.body,
    this.actions = const [],
    this.automaticallyImplyLeading = true,
    this.floatingActionButton,
  });

  final String title;
  final Map<String, dynamic> userData;
  final bool isLoggedIn;
  final Function() onLogout;
  final Widget body;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: UIConstants.backgroundColor,
        title: Text(
          title,
          style: UIConstants.appBarTitleStyle,
        ),
        actions: [
          ...actions,
          const Padding(
            padding: UIConstants.appBarRightPadding,
            child: ConnectivityIcon(),
          ),
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openEndDrawer();
              },
            ),
          ),
        ],
      ),
      endDrawer: AppDrawer(
        userData: userData,
        isLoggedIn: isLoggedIn,
        onLogout: onLogout,
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
