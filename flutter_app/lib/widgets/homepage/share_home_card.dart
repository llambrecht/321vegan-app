import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vegan_app/helpers/time_counter/time_counter.dart';
import 'package:vegan_app/models/seasonal_theme.dart';
import 'package:vegan_app/widgets/homepage/stat_card.dart';
import 'package:vegan_app/widgets/wave_clipper.dart';

/// The image that gets shared: the home page (counter + stats) inside a phone
/// mockup, branded 321 Vegan, decorated with a seasonal theme. Uses fixed
/// logical sizes (no ScreenUtil) so the captured image is identical on every
/// device.
class ShareHomeCard extends StatelessWidget {
  final DateTime targetDate;
  final Map<String, int> savings;
  final SeasonalTheme theme;

  const ShareHomeCard({
    required this.targetDate,
    required this.savings,
    required this.theme,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.lerp(theme.primaryColor, Colors.black, 0.35)!,
            theme.primaryColor,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('lib/assets/white_icon.png', width: 42, height: 42),
              const SizedBox(width: 10),
              const Text(
                '321 Vegan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Baloo',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildPhoneMockup(),
          const SizedBox(height: 14),
          const Text(
            'Vous connaissez 321 Vegan ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Baloo',
            ),
          ),
          const SizedBox(height: 10),
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [
              _FeatureChip('🌱 Voir son impact'),
              _FeatureChip('📷 Scanner les produits'),
              _FeatureChip('💸 Des réductions'),
              _FeatureChip('🤝 Communautaire'),
              _FeatureChip('❤️ Gratuit'),
              _FeatureChip('💻 Open source'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockup() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2937),
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 234,
          height: 415,
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    gradient: theme.backgroundGradient,
                  ),
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: ClipPath(
                  clipper: WaveClipper(),
                  child: Container(color: theme.waveColor, height: 78),
                ),
              ),
              _buildSeasonalDecoration(),
              Column(
                children: [
                  // Below the wave (78px high at the edges).
                  const SizedBox(height: 80),
                  const Text(
                    'Vous êtes végane depuis',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'Baloo',
                    ),
                  ),
                  _buildCounter(),
                  const SizedBox(height: 4),
                  ...homeStats.map(
                    (stat) =>
                        _miniStatCard(stat, savings[stat.savingsKey] ?? 0),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      'Depuis le ${DateFormat('dd/MM/yyyy').format(targetDate)}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'Baloo',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
              // Notch
              Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 64,
                  height: 12,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F2937),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Seasonal icon/asset over the wave, mirroring the home page positions
  /// (size 889, offset -72/42 plus the theme's icon offsets and scale, on a
  /// 1170x2532 design mapped to the 234x415 mockup screen). Note that on the
  /// home page the theme icon offsets get ScreenUtil scaling applied twice
  /// (once in the theme files, once in SeasonalIcon), which these values
  /// account for.
  Widget _buildSeasonalDecoration() {
    final double size;
    final double top;
    final double left;
    switch (theme.season) {
      case Season.defaultTheme:
        size = 165;
        top = 7;
        left = -13;
      case Season.winter:
        size = 110;
        top = 6;
        left = 4;
      case Season.spring:
        size = 110;
        top = -8;
        left = 0;
      case Season.summer:
        size = 150;
        top = -40;
        left = -2;
      case Season.autumn:
        size = 84;
        top = 0;
        left = 18;
    }

    return Positioned(
      top: top,
      left: left,
      child: theme.seasonalAsset != null
          ? Image.asset(theme.seasonalAsset!, width: size, height: size)
          : Icon(theme.seasonalIcon, size: size, color: Colors.white),
    );
  }

  Widget _buildCounter() {
    final breakdown = TimeBreakdown.between(targetDate, DateTime.now());
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _counterColumn('${breakdown.years}', 'ans'),
        const SizedBox(width: 8),
        _counterColumn('${breakdown.months}', 'mois'),
        const SizedBox(width: 8),
        _counterColumn('${breakdown.days}', 'jours'),
        const SizedBox(width: 8),
        _counterColumn('${breakdown.hours}', 'heures'),
        const SizedBox(width: 8),
        _counterColumn('${breakdown.minutes}', 'min'),
        const SizedBox(width: 8),
        _counterColumn('${breakdown.seconds}', 'sec'),
      ],
    );
  }

  Widget _counterColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value.padLeft(2, '0'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -4),
          child: Text(
            label,
            style: const TextStyle(fontSize: 8, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _miniStatCard(HomeStat stat, int value) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: ClipPath(
        clipper: BookDividerClipper(),
        child: Container(
          color: stat.cardColor,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stat.title.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$value',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          stat.unitName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: stat.iconColor,
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(stat.icon, color: Colors.white, size: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  final String label;

  const _FeatureChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontFamily: 'Baloo',
        ),
      ),
    );
  }
}
