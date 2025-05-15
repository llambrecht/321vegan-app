import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vegan_app/helpers/preference_helper.dart';

class ProductHelper {
  static Future<bool> tryAddDocument(BuildContext context,
      Map<dynamic, dynamic>? productInfo, bool isVegan) async {
    try {
      // Check internet connection
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        if (!context.mounted) return false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Pas de connexion internet. Veuillez réessayer plus tard.'),
            backgroundColor: Colors.orange,
          ),
        );
        return false;
      }

      // Proceed with Firestore operation
      CollectionReference products =
          FirebaseFirestore.instance.collection('products');
      await products.doc(productInfo?['name']).set({
        'created_at': DateTime.now().toUtc(),
        'isVegan': isVegan,
      });
      await PreferencesHelper.addCodeToPreferences(productInfo?['code'], true);

      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Le produit a bien été envoyé. Nous allons vérifier et l\'ajouter à la base de données.'),
          backgroundColor: Colors.green,
        ),
      );
      return true;
    } catch (e) {
      if (!context.mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Une erreur est survenue lors de l\'ajout du produit. Veuillez réessayer.'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
