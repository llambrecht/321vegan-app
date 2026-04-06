import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/models/product_scores.dart';
import 'package:vegan_app/pages/app_pages/Profile/subscription_page.dart';
import 'package:vegan_app/services/open_food_facts_service.dart';
import 'package:vegan_app/widgets/scaner/score_badge.dart';
import 'package:vegan_app/widgets/shared/link_row.dart';

/// Shows Nutriscore + Green-score for vegan products
///
/// - [enabled]: controlled by the parent (scan settings). When false, renders nothing.
/// - [isSubscribed]: if true, fetches and shows scores with an info dialog.
///   If false, shows a blurred paywall overlay.
/// - [onDisable]: called when the user taps "Désactiver" in the info dialog.
class ProductScoresSection extends StatefulWidget {
  final String barcode;
  final bool isSubscribed;
  final bool enabled;
  final VoidCallback? onDisable;

  const ProductScoresSection({
    super.key,
    required this.barcode,
    required this.isSubscribed,
    this.enabled = true,
    this.onDisable,
  });

  @override
  State<ProductScoresSection> createState() => _ProductScoresSectionState();
}

class _ProductScoresSectionState extends State<ProductScoresSection> {
  ProductScores? _scores;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.isSubscribed && widget.enabled) {
      _fetchScores();
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  void didUpdateWidget(ProductScoresSection old) {
    super.didUpdateWidget(old);
    if (!widget.enabled) return;

    if (old.barcode != widget.barcode && widget.isSubscribed) {
      setState(() {
        _scores = null;
        _loading = true;
      });
      _fetchScores();
    }
    if (!old.isSubscribed && widget.isSubscribed && _scores == null) {
      setState(() => _loading = true);
      _fetchScores();
    }
    // Fetch if scores were just enabled
    if (!old.enabled &&
        widget.enabled &&
        widget.isSubscribed &&
        _scores == null) {
      setState(() => _loading = true);
      _fetchScores();
    }
  }

  Future<void> _fetchScores() async {
    final scores = await OpenFoodFactsService.fetchScores(widget.barcode);
    if (mounted) {
      setState(() {
        _scores = scores;
        _loading = false;
      });
    }
  }

  void _openSubscriptionPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SubscriptionPage()),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => _ScoresInfoDialog(
        onDisable: () {
          Navigator.of(context).pop();
          widget.onDisable?.call();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();
    return Center(
      child: widget.isSubscribed ? _buildScores() : _buildLockedOverlay(),
    );
  }

  Widget _buildScores() {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    return GestureDetector(
      onTap: _showInfoDialog,
      child: ScoreBadges(
        nutriscoreGrade: _scores?.nutriscoreGrade,
        ecoscoreGrade: _scores?.ecoscoreGrade,
      ),
    );
  }

  Widget _buildLockedOverlay() {
    return GestureDetector(
      onTap: _openSubscriptionPage,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: const IgnorePointer(
              child: ScoreBadges(nutriscoreGrade: 'a', ecoscoreGrade: 'a-plus'),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.lock_outline,
                  size: 40.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Accès Nutriscore / Green-score réservé aux abonné·es',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ScoresInfoDialog extends StatelessWidget {
  final VoidCallback onDisable;

  const _ScoresInfoDialog({required this.onDisable});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
      child: Padding(
        padding: EdgeInsets.all(28.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, size: 80.sp, color: primary),
            ),
            SizedBox(height: 20.h),
            Text(
              'Nutriscore & Green-score®',
              style: TextStyle(
                fontSize: 52.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              'Ces données sont fournies par OpenFoodFacts, une base de données alimentaire collaborative et open source. Elles peuvent être incomplètes ou absentes pour certains produits.',
              style: TextStyle(
                fontSize: 38.sp,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            LinkRow(
              icon: Icons.open_in_new,
              label: 'openfoodfacts.org',
              url: 'https://world.openfoodfacts.org',
              color: primary,
            ),
            SizedBox(height: 6.h),
            LinkRow(
              icon: Icons.open_in_new,
              label: 'En savoir plus sur le Nutriscore',
              url: 'https://fr.openfoodfacts.org/nutriscore',
              color: primary,
            ),
            SizedBox(height: 6.h),
            LinkRow(
              icon: Icons.open_in_new,
              label: 'En savoir plus sur le Green-score®',
              url: 'https://fr.openfoodfacts.org/green-score',
              color: primary,
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 18.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Fermer',
                  style: TextStyle(
                    fontSize: 42.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onDisable,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey.shade500,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                ),
                child: Text(
                  'Désactiver les scores',
                  style: TextStyle(fontSize: 36.sp),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
