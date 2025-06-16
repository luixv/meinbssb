import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/screens/base_screen_layout.dart';
import '/models/user_data.dart';

class StylesScreen extends StatelessWidget {
  const StylesScreen({
    required this.userData,
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });

  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Styles',
      userData: userData,
      isLoggedIn: isLoggedIn,
      onLogout: onLogout,
      body: SingleChildScrollView(
        padding: UIConstants.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: UIConstants.spacingL,
              runSpacing: UIConstants.spacingM,
              children: [
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.menuIcon,
                        size: 8,
                        color: UIConstants.defaultAppColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Header Style', style: UIStyles.headerStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.homeIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Title Style', style: UIStyles.titleStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.infoIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Subtitle Style', style: UIStyles.subtitleStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.personIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Body Style', style: UIStyles.bodyStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.saveIcon,
                        size: 8,
                        color: Colors.white,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Button Style', style: UIStyles.buttonStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.infoIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text(
                        'Dialog Title Style',
                        style: UIStyles.dialogTitleStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.personIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text(
                        'Dialog Content Style',
                        style: UIStyles.dialogContentStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.checkIconData,
                        size: 8,
                        color: Colors.white,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text(
                        'Dialog Button Text Style',
                        style: UIStyles.dialogButtonTextStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.personIcon,
                        size: 8,
                        color: UIConstants.textColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text(
                        'List Item Title Style',
                        style: UIStyles.listItemTitleStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.infoIcon,
                        size: 8,
                        color: UIConstants.greyColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text(
                        'List Item Subtitle Style',
                        style: UIStyles.listItemSubtitleStyle,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        UIConstants.infoIcon,
                        size: 8,
                        color: Colors.white,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('News Style', style: UIStyles.newsStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: UIConstants.errorColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Error Style', style: UIStyles.errorStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: UIConstants.successColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Success Style', style: UIStyles.successStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: UIConstants.warningColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Warning Style', style: UIStyles.warningStyle),
                    ],
                  ),
                ),
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: UIConstants.linkColor,
                      ),
                      SizedBox(width: UIConstants.spacingS),
                      Text('Link Style', style: UIStyles.linkStyle),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
              ),
              padding: const EdgeInsets.all(UIConstants.spacingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Form Input Decoration',
                    style: UIStyles.bodyStyle,
                  ),
                  const SizedBox(height: UIConstants.spacingS),
                  TextField(
                    decoration: UIStyles.formInputDecoration.copyWith(
                      labelText: 'Example Input',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: () {},
              style: UIStyles.defaultButtonStyle,
              child: const Text('Default Button Style'),
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: () {},
              style: UIStyles.dialogCancelButtonStyle,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(UIStyles.dialogCancelIcon),
                  SizedBox(width: UIConstants.spacingS),
                  Text('Dialog Cancel Button Style'),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            ElevatedButton(
              onPressed: () {},
              style: UIStyles.dialogAcceptButtonStyle,
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(UIStyles.dialogAcceptIcon),
                  SizedBox(width: UIConstants.spacingS),
                  Text('Dialog Accept Button Style'),
                ],
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            const Divider(height: UIConstants.spacingL),
            const Text(
              'App Icons',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Wrap(
              spacing: UIConstants.spacingM,
              runSpacing: UIConstants.spacingM,
              children: [
                _buildIconItem(
                  Icons.menu,
                  'Menu - Opens the app drawer',
                ),
                _buildIconItem(
                  Icons.close,
                  'Close - Used in dialogs and forms',
                ),
                _buildIconItem(
                  Icons.check,
                  'Check - Used for confirmation',
                ),
                _buildIconItem(
                  Icons.add,
                  'Add - Used for adding new items',
                ),
                _buildIconItem(
                  Icons.delete_outline,
                  'Delete - Used for removing items',
                ),
                _buildIconItem(
                  Icons.arrow_back,
                  'Back - Used for navigation',
                ),
                _buildIconItem(
                  Icons.visibility,
                  'Visibility - Used for password fields',
                ),
                _buildIconItem(
                  Icons.visibility_off,
                  'Visibility Off - Used for password fields',
                ),
                _buildIconItem(
                  Icons.login,
                  'Login - Used on the login button',
                ),
                _buildIconItem(
                  Icons.lock_reset,
                  'Password Reset - Used for resetting password',
                ),
                _buildIconItem(
                  Icons.check_circle_outline,
                  'Check Circle Outline - Used for success messages',
                ),
                _buildIconItem(
                  Icons.check_circle,
                  'Check Circle - Used for success messages',
                ),
                _buildIconItem(
                  Icons.error,
                  'Error - Used for error messages',
                ),
                _buildIconItem(
                  Icons.home,
                  'Home - Used for home navigation',
                ),
                _buildIconItem(
                  Icons.remove_circle_outline,
                  'Remove - Used for decreasing font size',
                ),
                _buildIconItem(
                  Icons.add_circle_outline,
                  'Add - Used for increasing font size',
                ),
                _buildIconItem(
                  Icons.restore,
                  'Restore - Used for resetting font size',
                ),
                _buildIconItem(
                  Icons.school_outlined,
                  'School - Used for training/schulungen',
                ),
                _buildIconItem(
                  Icons.delete_outline_outlined,
                  'Delete Outline - Used for removing items',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconItem(IconData icon, String description) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(UIConstants.spacingS),
      decoration: BoxDecoration(
        border: Border.all(color: UIConstants.greyColor),
        borderRadius: BorderRadius.circular(UIConstants.cornerRadius),
      ),
      child: Row(
        children: [
          Icon(icon, color: UIConstants.defaultAppColor),
          const SizedBox(width: UIConstants.spacingS),
          Expanded(
            child: Text(
              description,
              style: UIStyles.bodyStyle,
            ),
          ),
        ],
      ),
    );
  }
}
