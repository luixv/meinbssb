import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import 'package:provider/provider.dart';
import '/services/core/font_size_provider.dart';

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
  final UserData? userData;
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
        automaticallyImplyLeading: automaticallyImplyLeading,
        backgroundColor: UIConstants.backgroundColor,
        title: ScaledText(
          title,
          style: UIStyles.appBarTitleStyle,
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
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) => body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
