import 'package:flutter/material.dart';

class SearchEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;

  const SearchEmptyState({
    super.key,
    this.icon = Icons.info_outline,
    this.message = 'Aucun résultat',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
