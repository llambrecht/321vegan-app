import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // About Me Section
        Container(
          color: Colors.green[50],
          padding: const EdgeInsets.all(16),
          child: Text.rich(
            TextSpan(
              text:
                  "Pour toute question ou suggestion, vous pouvez utiliser l'adresse email ci-dessous ou bien me contacter sur Instagram :",
              style: TextStyle(fontSize: 44.sp), // Default style
              children: const <TextSpan>[
                TextSpan(
                  text: " @321vegan.app",
                  style: TextStyle(
                      fontWeight: FontWeight.bold), // Bold style for 321Vegan
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20), // Add some space between the two sections
        ListTile(
          tileColor: Colors.grey[200],
          title: const Text('contact@321vegan.fr'),
          onTap: () async {
            // Copy the email to clipboard
            await Clipboard.setData(
              const ClipboardData(text: 'contact@321vegan.fr'),
            );

            // Check if the widget is still mounted before accessing the context
            if (!context.mounted) {
              return; // If the widget is not mounted, exit early
            }

            // Show the snackbar after clipboard operation
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Adresse e-mail copiée !'),
              ),
            );
          },
          trailing: const Icon(Icons.copy),
        ),
      ],
    );
  }
}
