import 'package:flutter/material.dart';
import '/constants/ui_constants.dart';
import '/constants/ui_styles.dart';
import '/models/user_data.dart';
import '/screens/base_screen_layout.dart';
import '/screens/schulungen_screen.dart';
import '/widgets/scaled_text.dart';
import 'package:intl/intl.dart';

class SchulungenSearchScreen extends StatefulWidget {
  const SchulungenSearchScreen(
    this.userData, {
    required this.isLoggedIn,
    required this.onLogout,
    super.key,
  });
  final UserData? userData;
  final bool isLoggedIn;
  final Function() onLogout;

  @override
  State<SchulungenSearchScreen> createState() => _SchulungenSearchScreenState();
}

class _SchulungenSearchScreenState extends State<SchulungenSearchScreen> {
  DateTime? _selectedDate;

  String _formatDate(DateTime date) {
    return DateFormat('dd.MM.yyyy').format(date);
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _navigateToResults() {
    if (_selectedDate == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SchulungenScreen(
          widget.userData,
          isLoggedIn: widget.isLoggedIn,
          onLogout: widget.onLogout,
          searchDate: _selectedDate!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseScreenLayout(
      title: 'Schulungen',
      userData: widget.userData,
      isLoggedIn: widget.isLoggedIn,
      onLogout: widget.onLogout,
      body: Padding(
        padding: const EdgeInsets.all(UIConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ScaledText(
              'Schulungen suchen',
              style: UIStyles.headerStyle,
            ),
            const SizedBox(height: UIConstants.spacingM),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: UIStyles.formInputDecoration.copyWith(
                        labelText: 'Datum wählen',
                        floatingLabelBehavior: FloatingLabelBehavior.auto,
                      ),
                      child: ScaledText(
                        _selectedDate == null
                            ? 'Bitte wählen Sie ein Datum'
                            : _formatDate(_selectedDate!),
                        style: UIStyles.bodyStyle,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: UIConstants.spacingM),
                ElevatedButton(
                  onPressed: _selectedDate != null ? _navigateToResults : null,
                  child: const Text('Suchen'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
