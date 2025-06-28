import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vegan_app/helpers/preference_helper.dart';
import '../../../models/product_document.dart';
import '../../../models/vegan_status.dart';

class ProductHelper {
  static Future<bool> _checkConnectivityAndShowSnackbar(
      BuildContext context) async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
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
      // Proceed with Firestore operation
      CollectionReference products =
          FirebaseFirestore.instance.collection('productsWithMaybe');
      final product = ProductDocument(
        createdAt: DateTime.now().toUtc(),
        code: productInfo?['code'] ?? '',
        isVegan: veganStatus ?? VeganStatus.maybeVegan,
      );
      await products.doc(product.code).set(product.toJson());
      await PreferencesHelper.addCodeToPreferences(product.code, true);

      if (!context.mounted) return false;
      _showSnackbar(
        context,
        'Le produit a bien été envoyé. Nous allons vérifier et l\'ajouter à la base de données.',
        Colors.green,
      );
      return true;
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
      BuildContext context, String code, String message) async {
    if (!await _checkConnectivityAndShowSnackbar(context)) return false;
    try {
      CollectionReference errors =
          FirebaseFirestore.instance.collection('errors');
      await errors.add({
        'code': code,
        'message': message,
        'handled': false,
        'created_at': DateTime.now().toUtc(),
      });

      return true;
    } catch (e) {
      return false;
    }
  }
}
