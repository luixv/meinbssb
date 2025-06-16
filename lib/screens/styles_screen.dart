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
            const Text('Icons', style: UIStyles.headerStyle),
            const SizedBox(height: UIConstants.spacingM),
            Wrap(
              spacing: UIConstants.spacingL,
              runSpacing: UIConstants.spacingM,
              children: [
                _buildIconExample(Icons.menu, 'Menu - App drawer'),
                _buildIconExample(Icons.close, 'Close - Dialogs and forms'),
                _buildIconExample(Icons.check, 'Check - Confirmation'),
                _buildIconExample(Icons.add, 'Add - New items'),
                _buildIconExample(
                  Icons.delete_outline,
                  'Delete - Remove items',
                ),
                _buildIconExample(Icons.arrow_back, 'Back - Navigation'),
                _buildIconExample(
                  Icons.visibility,
                  'Visibility - Password field',
                ),
                _buildIconExample(
                  Icons.visibility_off,
                  'Visibility Off - Password field',
                ),
                _buildIconExample(Icons.login, 'Login - Authentication'),
                _buildIconExample(
                  Icons.lock_reset,
                  'Password Reset - Reset password',
                ),
                _buildIconExample(
                  Icons.check_circle,
                  'Success - Success messages',
                ),
                _buildIconExample(Icons.error, 'Error - Error messages'),
                _buildIconExample(Icons.home, 'Home - Home navigation'),
                _buildIconExample(
                  Icons.remove_circle_outline,
                  'Remove - Decrease font size',
                ),
                _buildIconExample(
                  Icons.add_circle_outline,
                  'Add - Increase font size',
                ),
                _buildIconExample(Icons.restore, 'Restore - Reset font size'),
                _buildIconExample(Icons.school_outlined, 'School - Training'),
                _buildIconExample(
                  Icons.delete_outline_outlined,
                  'Delete - Remove items',
                ),
                _buildIconExample(
                  Icons.calendar_today,
                  'Calendar - Date selection',
                ),
                _buildIconExample(
                  Icons.app_registration,
                  'Registration - User registration',
                ),
                _buildIconExample(Icons.wifi, 'WiFi - Network status'),
                _buildIconExample(
                  Icons.signal_cellular_4_bar,
                  'Cellular - Network status',
                ),
                _buildIconExample(Icons.wifi_off, 'WiFi Off - No network'),
                _buildIconExample(
                  Icons.bluetooth_connected,
                  'Bluetooth - Connection status',
                ),
                _buildIconExample(Icons.vpn_lock, 'VPN - Secure connection'),
                _buildIconExample(
                  Icons.network_check,
                  'Network Check - Connection status',
                ),
                _buildIconExample(Icons.task_alt, 'Task - Completed tasks'),
                _buildIconExample(Icons.school, 'School - Training menu'),
                _buildIconExample(Icons.badge, 'Badge - User profile'),
                _buildIconExample(Icons.edit, 'Edit - Edit content'),
                _buildIconExample(Icons.celebration, 'Celebration - Events'),
                _buildIconExample(Icons.photo_camera, 'Camera - Photo capture'),
                _buildIconExample(Icons.person, 'Person - User profile'),
                _buildIconExample(
                  Icons.contact_phone,
                  'Contact - Contact information',
                ),
                _buildIconExample(Icons.account_balance, 'Bank - Bank data'),
                _buildIconExample(Icons.settings, 'Settings - App settings'),
                _buildIconExample(Icons.style, 'Style - App styling'),
                _buildIconExample(Icons.logout, 'Logout - Sign out'),
                _buildIconExample(Icons.help_outline, 'Help - Help section'),
                _buildIconExample(Icons.info_outline, 'Info - Information'),
                _buildIconExample(
                  Icons.error_outline,
                  'Error - Error messages',
                ),
                _buildIconExample(Icons.save, 'Save - Save changes'),
                _buildIconExample(
                  Icons.search,
                  'Search - Search functionality',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconExample(IconData icon, String description) {
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
