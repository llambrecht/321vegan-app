import 'package:flutter/material.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/models/boycott_data.dart';

class InfoModal extends StatefulWidget {
  final String description;
  final BoycottMatch? boycottMatch;
  final bool showBoycottToggle;
  final bool? initialBoycottValue;
  final Function(bool)? onBoycottToggleChanged;

  const InfoModal({
    super.key,
    required this.description,
    this.boycottMatch,
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
    final match = widget.boycottMatch;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (match != null) ...[
                    Text(
                      match.brandDisplay,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (match.groupName != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Appartient au groupe ${match.groupName}',
                        style: TextStyle(
                          fontSize: 13,
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Text(
                        match.reason,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    widget.description,
                    style: TextStyle(
                      fontSize: match != null ? 13 : 16,
                      color: match != null ? Colors.grey[600] : Colors.black87,
                    ),
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
          ),
        ],
      ),
    );
  }
}
