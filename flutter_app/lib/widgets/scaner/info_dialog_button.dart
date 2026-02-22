import 'package:flutter/material.dart';
import 'package:vegan_app/pages/app_pages/helpers/product.helper.dart';

class InfoDialogButton extends StatelessWidget {
  final String barcode;
  final String buttonLabel;
  final String dialogTitle;
  final String commentTitle;
  final String commentHint;
  final Color buttonColor;

  const InfoDialogButton({
    super.key,
    required this.barcode,
    required this.buttonLabel,
    required this.dialogTitle,
    required this.commentTitle,
    required this.commentHint,
    required this.buttonColor
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.report_problem, color: buttonColor),
      label: Text(
        buttonLabel,
        style: TextStyle(color: buttonColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        side: BorderSide(color: buttonColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: () {
        final rootContext = context;
        showDialog(
          context: rootContext,
          builder: (context) {
            final TextEditingController commentController =
                TextEditingController();
            final TextEditingController contactController =
                TextEditingController();
            String? commentErrorText;
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: Text(dialogTitle),
                  content: SingleChildScrollView(
                    child: Column(
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
                          text: TextSpan(
                            text: commentTitle,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            children: const [
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
                          controller: commentController,
                          maxLines: 4,
                          maxLength: 800,
                          decoration: InputDecoration(
                            hintText:
                                commentHint,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                            errorText: commentErrorText,
                          ),
                          onChanged: (_) {
                            if (commentErrorText != null) {
                              setState(() => commentErrorText = null);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          "Contact (optionnel)",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        TextField(
                          controller: contactController,
                          maxLines: 2,
                          maxLength: 200,
                          decoration: InputDecoration(
                            hintText:
                                "Email ou @ instagram (au cas où on aurait besoin d'infos)",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (commentController.text.trim().isEmpty) {
                          setState(
                              () => commentErrorText = "Ce champ est requis.");
                        } else {
                          Navigator.of(context).pop();
                          bool result = await ProductHelper.tryAddError(
                            rootContext,
                            barcode,
                            commentController.text.trim(),
                            contact: contactController.text.trim(),
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

class ReportErrorButton extends StatelessWidget {
  final String barcode;

  const ReportErrorButton({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return InfoDialogButton(
      barcode: barcode,
      buttonLabel: "Signaler une erreur",
      dialogTitle: "Signaler une erreur",
      commentTitle: "Quel est ce produit ? ",
      commentHint: "Décrivez le problème rencontré avec ce produit",
      buttonColor: Colors.orange,
    );
  }
}

class SendInfoButton extends StatelessWidget {
  final String barcode;

  const SendInfoButton({super.key, required this.barcode});

  @override
  Widget build(BuildContext context) {
    return InfoDialogButton(
      barcode: barcode,
      buttonLabel: "Envoyer des infos",
      dialogTitle: "Envoyer une info",
      commentTitle: "Quel est ce produit? ",
      commentHint: "Décrivez le produit",
      buttonColor: Colors.blue,
    );
  }
}