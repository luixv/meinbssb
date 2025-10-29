import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import 'menu/app_menu.dart';
import '/screens/connectivity_icon.dart';
import '/models/user_data.dart';
import '/widgets/scaled_text.dart';
import 'package:provider/provider.dart';
import '/providers/font_size_provider.dart';

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
    this.leading,
    this.floatingActionButton,
    this.showMenu = true,
    this.showConnectivityIcon = true,
  });

  final String title;
  final UserData? userData;
  final bool isLoggedIn;
  final VoidCallback onLogout;
  final Widget body;
  final List<Widget> actions;
  final bool automaticallyImplyLeading;
  final Widget? leading;
  final Widget? floatingActionButton;
  final bool showMenu;
  final bool showConnectivityIcon;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UIConstants.backgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: automaticallyImplyLeading && leading == null,
        backgroundColor: UIConstants.backgroundColor,
        iconTheme: const IconThemeData(color: UIConstants.textColor),
        leading: leading,
        title: ScaledText(
          title,
          style: UIStyles.appBarTitleStyle,
        ),
        actions: [
          ...actions,
          if (showConnectivityIcon)
            const Padding(
              padding: UIConstants.appBarRightPadding,
              child: ConnectivityIcon(),
            ),
          if (showMenu)
            Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu, color: UIConstants.textColor),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              ),
            ),
        ],
      ),
      endDrawer: showMenu
          ? AppDrawer(
              userData: userData,
              isLoggedIn: isLoggedIn,
              onLogout: onLogout,
            )
          : null,
      body: Consumer<FontSizeProvider>(
        builder: (context, fontSizeProvider, child) => body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
