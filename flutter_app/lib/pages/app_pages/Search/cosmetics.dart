import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vegan_app/helpers/database_helper.dart';

class CosmeticsPage extends StatefulWidget {
  const CosmeticsPage({super.key});

  @override
  CosmeticsPageState createState() => CosmeticsPageState();
}

class CosmeticsPageState extends State<CosmeticsPage> {
  List<CosmeticItem> filteredCosmetics = [];
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializePage();
  }

  Future<void> _initializePage() async {
    await _loadLastSearch();
  }

  Future<void> _loadLastSearch() async {
    final prefs = await SharedPreferences.getInstance();
    final lastSearch = prefs.getString('lastSearchCosmetics');
    if (lastSearch != null) {
      searchController.text = lastSearch;
      _searchCosmetic(lastSearch);
    }
  }

  Future<void> _searchCosmetic(String query) async {
    if (query.isEmpty) {
      setState(() => filteredCosmetics = []);
      return;
    }

    // Query the database for cosmetics by name
    final dbResult = await DatabaseHelper.instance.queryCosmeticByName(query);

    setState(() {
      filteredCosmetics = dbResult.map((item) {
        return CosmeticItem(
          name: item['brand'] as String,
          vegan: (item['vegan'] as String).toUpperCase() == "Y",
          crueltyFree: (item['cf'] as String).toUpperCase() == "Y",
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(),
              const SizedBox(height: 10),
              filteredCosmetics.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 32.0),
                      child: _buildEmptyState(),
                    )
                  : SizedBox(
                      height: MediaQuery.of(context).size.height - 150,
                      child: _buildCosmeticList(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextFormField(
        controller: searchController,
        decoration: const InputDecoration(
          labelText: 'Rechercher une marque (Avril, Nae, ...)',
          suffixIcon: Icon(Icons.search),
        ),
        onChanged: _searchCosmetic,
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, color: Colors.grey, size: 48),
          SizedBox(height: 16),
          Text(
            'Aucun résultat',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'La liste des marques est en cours de construction.\nN\'hésitez pas à me contacter pour en ajouter !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmeticList() {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: filteredCosmetics.length,
      itemBuilder: (context, index) {
        final cosmetic = filteredCosmetics[index];
        return _buildCosmeticCard(cosmetic);
      },
    );
  }

  Widget _buildCosmeticCard(CosmeticItem cosmetic) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              cosmetic.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            if (!cosmetic.vegan) _buildVeganAlert(),
            const SizedBox(height: 8),
            _buildStatusRow(
              icon: cosmetic.vegan ? Icons.check_circle : Icons.info,
              color: cosmetic.vegan ? Colors.green : Colors.orange,
              text: cosmetic.vegan ? "100% Vegan" : "Vérifiez le produit",
            ),
            _buildStatusRow(
              icon: cosmetic.crueltyFree ? Icons.check_circle : Icons.close,
              color: cosmetic.crueltyFree ? Colors.green : Colors.red,
              text:
                  cosmetic.crueltyFree ? "Cruelty-Free 🐰" : "Pas cruelty-free",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVeganAlert() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "Cette marque n'est pas 100% végane. Vérifiez l’emballage !",
              style: TextStyle(
                color: Colors.orange[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class CosmeticItem {
  final String name;
  final bool vegan;
  final bool crueltyFree;

  CosmeticItem({
    required this.name,
    required this.vegan,
    required this.crueltyFree,
  });
}
