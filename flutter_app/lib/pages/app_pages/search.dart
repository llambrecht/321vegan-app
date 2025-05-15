import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/pages/app_pages/Search/additives.dart';
import 'package:vegan_app/pages/app_pages/Search/cosmetics.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  SearchPageState createState() => SearchPageState();
}

enum SubPageSearch { additives, cosmetics }

class SearchPageState extends State<SearchPage> {
  DateTime? selectedDate;
  SubPageSearch selectedSubPage = SubPageSearch.additives;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(
                    color: Theme.of(context).colorScheme.primary,
                    height: 0.19.sh,
                  ),
                ),
              ),
              CustomPaint(
                size: Size.fromHeight(0.190.sh),
                painter: WaveTextPainter("Recherches"),
              ),
            ],
          ),
          // Subpage selector
          Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 0.0),
            child: SegmentedButton<SubPageSearch>(
              segments: const <ButtonSegment<SubPageSearch>>[
                ButtonSegment<SubPageSearch>(
                    value: SubPageSearch.additives,
                    label: Text('Additifs'),
                    icon: Icon(Icons.science)),
                ButtonSegment<SubPageSearch>(
                    value: SubPageSearch.cosmetics,
                    label: Text('Cosmétiques'),
                    icon: Icon(Icons.soap_rounded)),
              ],
              selected: <SubPageSearch>{selectedSubPage},
              onSelectionChanged: (Set<SubPageSearch> newSelection) {
                setState(() {
                  selectedSubPage = newSelection.first;
                });
              },
            ),
          ),
          // Subpage content
          Expanded(
            child: _buildSubPageContent(selectedSubPage),
          ),
        ],
      ),
    );
  }

  Widget _buildSubPageContent(SubPageSearch subPage) {
    switch (subPage) {
      case SubPageSearch.additives:
        return const AdditivesPage();
      case SubPageSearch.cosmetics:
        return const CosmeticsPage();
    }
  }
}
