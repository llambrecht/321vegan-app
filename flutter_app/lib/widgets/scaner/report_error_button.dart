import 'package:flutter/material.dart';
import 'package:vegan_app/pages/app_pages/helpers/product.helper.dart';

class ReportErrorButton extends StatelessWidget {
  final String barcode;

  const ReportErrorButton({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.report_problem, color: Colors.orange),
      label: const Text(
        "Signaler une erreur",
        style: TextStyle(color: Colors.orange),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: const BorderSide(color: Colors.orange),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        final rootContext = context;
        showDialog(
          context: rootContext,
          builder: (context) {
            final TextEditingController controller = TextEditingController();
            String? errorText;
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text("Signaler une erreur"),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Code-barre : $barcode",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        text: const TextSpan(
                          text: "Détails de l'erreur ",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                          children: [
                            TextSpan(
                              text: "*",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: controller,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: "Décrivez le problème rencontré",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 12,
                          ),
                          errorText: errorText,
                        ),
                        onChanged: (_) {
                          if (errorText != null) {
                            setState(() => errorText = null);
                          }
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) {
                          setState(() => errorText = "Ce champ est requis.");
                        } else {
                          Navigator.of(context).pop();
                          bool result = await ProductHelper.tryAddError(
                            rootContext,
                            barcode,
                            controller.text.trim(),
                          );

                          await Future.delayed(
                              const Duration(milliseconds: 100));
                          if (!rootContext.mounted) return;
                          final messenger = ScaffoldMessenger.of(rootContext);

                          if (!result) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text(
                                    "Une erreur est survenue. Veuillez réessayer."),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text("Signalement envoyé. Merci !"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      child: const Text("Envoyer"),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
