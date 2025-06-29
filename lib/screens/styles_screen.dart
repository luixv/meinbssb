import 'package:flutter/material.dart';
import 'package:meinbssb/constants/ui_constants.dart';
import 'package:meinbssb/constants/ui_styles.dart';
import 'package:meinbssb/screens/base_screen_layout.dart';
import 'package:meinbssb/models/user_data.dart';

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
                // Left Column
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Header Style', style: UIStyles.headerStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Title Style', style: UIStyles.titleStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Subtitle Style', style: UIStyles.subtitleStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Body Style', style: UIStyles.bodyStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text(
                            'List Item Title Style',
                            style: UIStyles.listItemTitleStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text(
                            'List Item Subtitle Style',
                            style: UIStyles.listItemSubtitleStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Link Style', style: UIStyles.linkStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Button Style', style: UIStyles.buttonStyle),
                        ],
                      ),
                    ],
                  ),
                ),
                // Right Column
                SizedBox(
                  width: (MediaQuery.of(context).size.width -
                          UIConstants.screenPadding.left -
                          UIConstants.screenPadding.right -
                          UIConstants.spacingL) /
                      2,
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Title Style',
                            style: UIStyles.dialogTitleStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text(
                            'Content Style',
                            style: UIStyles.dialogContentStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text(
                            'Button Text Style',
                            style: UIStyles.dialogButtonTextStyle,
                          ),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Error Style', style: UIStyles.errorStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Warning Style', style: UIStyles.warningStyle),
                        ],
                      ),
                      SizedBox(height: UIConstants.spacingM),
                      Row(
                        children: [
                          Text('Success Style', style: UIStyles.successStyle),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: UIConstants.spacingM),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: UIConstants.mydarkGreyColor),
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
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {},
                style: UIStyles.defaultButtonStyle,
                child: const Text('Default Button Style'),
              ),
            ),
            const SizedBox(height: UIConstants.spacingM),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: UIStyles.dialogCancelButtonStyle,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.close),
                        SizedBox(width: UIConstants.spacingS),
                        Flexible(
                          child: Text(
                            'Cancel Button Style',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingM),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: UIStyles.dialogAcceptButtonStyle,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check),
                        SizedBox(width: UIConstants.spacingS),
                        Flexible(
                          child: Text(
                            'Accept Button Style',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
                _buildIconExample(Icons.wifi_off, 'WiFi Off - No network'),
                _buildIconExample(Icons.task_alt, 'Task - Completed tasks'),
                _buildIconExample(Icons.school, 'School - Training menu'),
                _buildIconExample(Icons.badge, 'Badge - User profile'),
                _buildIconExample(Icons.edit, 'Edit - Edit content'),
                _buildIconExample(
                  Icons.add_a_photo_outlined,
                  'Add a photo - Profile photo',
                ),
                _buildIconExample(Icons.person, 'Person - User profile'),
                _buildIconExample(
                  Icons.contact_phone,
                  'Contact - Contact information',
                ),
                _buildIconExample(Icons.account_balance, 'Bank - Bank data'),
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
                _buildIconExample(
                  Icons.signal_cellular_4_bar,
                  'Signal - Mobile Data',
                ),
                _buildIconExample(
                  Icons.delete_forever,
                  'Delete Forever - Destructive Action',
                ),
                _buildIconExample(
                  Icons.sports_bar_outlined,
                  'Oktoberfestlandesschießen',
                ),
                _buildIconExample(Icons.rule, 'Rule - Startrechte Ändern'),
                _buildIconExample(
                  Icons.cloud_off,
                  'Cloud Off - No Cloud Connection',
                ),
                _buildIconExample(
                  Icons.check,
                  'Check - Confirm (used in dialogs)',
                ),
                _buildIconExample(
                  Icons.upload_file,
                  'Upload File - Profile photo upload',
                ),
                _buildIconExample(Icons.refresh, 'Refresh - Reload data'),
                _buildIconExample(Icons.search, 'Search - Search bar'),
                _buildIconExample(
                  Icons.network_check,
                  'Network Check - Connectivity',
                ),
                _buildIconExample(Icons.vpn_lock, 'VPN Lock - Connectivity'),
                _buildIconExample(Icons.phone, 'Phone - Contact/phone number'),
                _buildIconExample(Icons.email, 'Email - Contact/email'),
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
        border: Border.all(color: UIConstants.mydarkGreyColor),
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
