import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import 'package:vegan_app/services/api_service.dart';
import '../../../models/vegan_status.dart';

class ProductHelper {
  static Future<bool> _checkConnectivityAndShowSnackbar(
      BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult.contains(ConnectivityResult.none)) {
      if (!context.mounted) return false;
      _showSnackbar(
        context,
        'Pas de connexion internet. Veuillez réessayer plus tard.',
        Colors.orange,
      );
      return false;
    }
    return true;
  }

  static void _showSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  static Future<bool> tryAddDocument(BuildContext context,
      Map<dynamic, dynamic>? productInfo, VeganStatus? veganStatus) async {
    if (!await _checkConnectivityAndShowSnackbar(context)) return false;
    try {
      // Use the new API instead of Firebase
      final success = await ApiService.postProduct(
        ean: productInfo?['code'] ?? '',
        status:
            veganStatus?.toApiString() ?? VeganStatus.maybeVegan.toApiString(),
      );

      if (success) {
        await PreferencesHelper.addCodeToPreferences(
            productInfo?['code'] ?? '', true);

        if (!context.mounted) return false;
        _showSnackbar(
          context,
          'Le produit a bien été envoyé. Nous allons vérifier et l\'ajouter à la base de données.',
          Colors.green,
        );
        return true;
      } else {
        if (!context.mounted) return false;
        _showSnackbar(
          context,
          'Une erreur est survenue lors de l\'ajout du produit. Veuillez réessayer.',
          Colors.red,
        );
        return false;
      }
    } catch (e) {
      if (!context.mounted) return false;
      _showSnackbar(
        context,
        'Une erreur est survenue lors de l\'ajout du produit. Veuillez réessayer.',
        Colors.red,
      );
      return false;
    }
  }

  static Future<bool> tryAddError(
      BuildContext context, String code, String message,
      {String contact = ''}) async {
    if (!await _checkConnectivityAndShowSnackbar(context)) return false;
    try {
      final success = await ApiService.postErrorReport(
        ean: code,
        comment: message,
        contact: contact,
      );

      return success;
    } catch (e) {
      return false;
    }
  }
}
