import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/helpers/shared_styles.dart';

class DatePickerPage extends StatefulWidget {
  const DatePickerPage({super.key});

  @override
  DatePickerPageState createState() => DatePickerPageState();
}

class DatePickerPageState extends State<DatePickerPage> {
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR');
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        _dateController.text = DateFormat.yMMMd('fr_FR').format(selectedDate!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/areYouVegan'),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColor,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Depuis quand ?",
              style: FirstLaunchStyles.titleTextStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30.0),
            TextFormField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Sélectionnez une date',
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.white),
                  onPressed: _pickDate,
                ),
              ),
              readOnly: true,
              style: const TextStyle(color: Colors.white),
              onTap: _pickDate,
            ),
            const SizedBox(height: 20.0),
            selectedDate != null
                ? ElevatedButton(
                    onPressed: () async {
                      await PreferencesHelper.addSelectedDateToPrefs(
                          selectedDate!);
                      if (!context.mounted) return;
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                    style: FirstLaunchStyles.buttonStyle,
                    child: const Text('Continuer'),
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}
