import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';
import './Profile/about_me_page.dart';
import './Profile/contact_page.dart';
import './Profile/products_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.onDateSaved,
    this.selectedInitialSubPage = SubPage.aboutMe,
  });
  final Function(DateTime) onDateSaved;
  final SubPage selectedInitialSubPage;

  @override
  ProfilePageState createState() => ProfilePageState();
}

enum SubPage { aboutMe, contact, products }

class ProfilePageState extends State<ProfilePage> {
  DateTime? selectedDate;
  final TextEditingController _dateController = TextEditingController();
  late SubPage selectedSubPage;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null);
    _loadSelectedDate();
    selectedSubPage = widget.selectedInitialSubPage;
  }

  Future<void> _loadSelectedDate() async {
    final DateTime? date = await PreferencesHelper.getSelectedDateFromPrefs();
    if (date != null) {
      setState(() {
        selectedDate = date;
        _dateController.text = DateFormat.yMMMd('fr_FR').format(selectedDate!);
      });
    }
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

      await PreferencesHelper.addSelectedDateToPrefs(selectedDate!);
      widget.onDateSaved(selectedDate!);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Modifications enregistrées !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: ClipPath(
                    clipper: WaveClipper(),
                    child: Container(
                      color: Theme.of(context).colorScheme.primary,
                      height: 0.19.sh,
                    ),
                  ),
                ),
                CustomPaint(
                  size: Size.fromHeight(0.190.sh),
                  painter: WaveTextPainter("Espace personnel"),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Row(
                    children: [
                      const Expanded(
                        flex: 1,
                        child: Text("Vegan depuis",
                            style: TextStyle(fontSize: 16)),
                      ),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Selectionner la date',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: _pickDate,
                            ),
                          ),
                          readOnly: true,
                          onTap: _pickDate,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Subpage selector
                  SegmentedButton<SubPage>(
                    segments: const <ButtonSegment<SubPage>>[
                      ButtonSegment<SubPage>(
                          value: SubPage.aboutMe,
                          label: Text('À propos'),
                          icon: Icon(Icons.question_mark_sharp)),
                      ButtonSegment<SubPage>(
                          value: SubPage.contact,
                          label: Text('Contact'),
                          icon: Icon(Icons.contact_mail)),
                      ButtonSegment<SubPage>(
                          value: SubPage.products,
                          label: Text('Produits envoyés'),
                          icon: Icon(Icons.send_to_mobile)),
                    ],
                    selected: <SubPage>{selectedSubPage},
                    onSelectionChanged: (Set<SubPage> newSelection) {
                      setState(() {
                        selectedSubPage = newSelection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  // Conditionally render the subpage container
                  _buildSubPageContent(selectedSubPage),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubPageContent(SubPage subPage) {
    switch (subPage) {
      case SubPage.aboutMe:
        return const AboutMePage();
      case SubPage.contact:
        return const ContactPage();
      case SubPage.products:
        return const ProductsPage();
    }
  }

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }
}
