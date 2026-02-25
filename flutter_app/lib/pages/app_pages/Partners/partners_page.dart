import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vegan_app/models/partners/partners.dart';
import 'package:vegan_app/services/api_service.dart';

class PartnersPage extends StatefulWidget {
  const PartnersPage({super.key});

  @override
  State<PartnersPage> createState() => _PartnersPageState();
}

class _PartnersPageState extends State<PartnersPage> {
  List<Partners> _partners = [];
  bool _isLoading = false;
  String get _baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://api.321vegan.fr';

  @override
  void initState() {
    super.initState();
    _loadPartnersInfo();
  }

  Future<void> _loadPartnersInfo() async {
    setState(() {
      _isLoading = true;
    });

    final result = await ApiService.getPartners();
    setState(() {
      _partners = result;
      _isLoading = false;
    });
  }

  Map<int, List<Partners>> _groupPartnersByCategory() {
    final Map<int, List<Partners>> grouped = {};

    for (final partner in _partners) {
      final categoryId = partner.category.id;
      if (!grouped.containsKey(categoryId)) {
        grouped[categoryId] = [];
      }
      grouped[categoryId]!.add(partner);
    }

    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with legend
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 12.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                      spreadRadius: 0,
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      children: [
                        Icon(
                          Icons.card_giftcard,
                          color: Theme.of(context).colorScheme.primary,
                          size: 56.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Codes Promos Partenaires',
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),

                    // Legend
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 48.w,
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Les codes avec une étoile sont des codes affiliés qui me donnent une commission. Les utiliser permet de soutenir 321 Vegan !',
                            style: TextStyle(
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _partners.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.card_giftcard,
                                size: 200.sp,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 32.h),
                              Text(
                                'Aucun partenaire disponible',
                                style: TextStyle(
                                  fontSize: 52.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 12.h),
                          children: _buildPartnersList(),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPartnersList() {
    final grouped = _groupPartnersByCategory();
    final List<Widget> widgets = [];

    // Sort categories by id
    final sortedCategoryIds = grouped.keys.toList()..sort();

    for (final categoryId in sortedCategoryIds) {
      final partners = grouped[categoryId]!;
      final categoryName = partners.first.category.name;

      widgets.add(_buildCategoryTitle(categoryName));

      for (final partner in partners) {
        widgets.add(_buildPartnerCard(partner: partner));
      }
    }

    widgets.add(SizedBox(height: 45.h));

    return widgets;
  }

  Widget _buildCategoryTitle(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(8.w, 24.h, 8.w, 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 48.sp,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildPartnerCard({
    required Partners partner,
  }) {
    // Construct the logo URL from the API base URL and logo path
    final logoUrl = '$_baseUrl/${partner.logoPath}';

    return Card(
      margin: EdgeInsets.all(16.h),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: () => _launchWebsite(context, partner.url),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Row(
            children: [
              // Logo container
              SizedBox(
                width: 250.w,
                height: 250.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: logoUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[400],
                      ),
                    ),
                    errorWidget: (context, url, error) {
                      return Container(
                        color: Colors.grey[200],
                        child: Icon(
                          Icons.image_not_supported,
                          size: 80.sp,
                          color: Colors.grey[400],
                        ),
                      );
                    },
                  ),
                ),
              ),

              SizedBox(width: 16.w),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand name with optional commission star
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            partner.name,
                            style: TextStyle(
                              fontSize: 52.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        if (partner.isAffiliate)
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 48.sp,
                          ),
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Discount amount
                    Text(
                      partner.discountText,
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange[600],
                      ),
                    ),

                    SizedBox(height: 6.h),

                    // Discount code
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        'Code: ${partner.discountCode}',
                        style: TextStyle(
                          fontSize: 36.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Arrow icon
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 50.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchWebsite(BuildContext context, String url) async {
    try {
      final Uri uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d\'ouvrir le lien'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
