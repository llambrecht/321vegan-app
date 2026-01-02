import 'package:flutter/material.dart';
import 'package:vegan_app/helpers/preference_helper.dart';

class InfoModal extends StatefulWidget {
  final String title;
  final String description;
  final bool showBoycottToggle;
  final bool? initialBoycottValue;
  final Function(bool)? onBoycottToggleChanged;

  const InfoModal({
    super.key,
    required this.title,
    required this.description,
    this.showBoycottToggle = false,
    this.initialBoycottValue,
    this.onBoycottToggleChanged,
  });

  @override
  State<InfoModal> createState() => _InfoModalState();
}

class _InfoModalState extends State<InfoModal> {
  late bool _showBoycott;

  @override
  void initState() {
    super.initState();
    _showBoycott = widget.initialBoycottValue ?? true;
  }

  Future<void> _toggleBoycott(bool value) async {
    await PreferencesHelper.setShowBoycottPref(value);
    setState(() {
      _showBoycott = value;
    });
    widget.onBoycottToggleChanged?.call(value);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              widget.description,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            if (widget.showBoycottToggle) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Afficher les mentions Boycott',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                    Switch(
                      value: _showBoycott,
                      onChanged: _toggleBoycott,
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF1A722E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ),
      ),
    );
  }
}
