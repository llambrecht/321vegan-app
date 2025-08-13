import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../models/brand_score.dart';

class BrandScoreBottomSheet extends StatelessWidget {
  final BrandScore brandScore;

  const BrandScoreBottomSheet({
    super.key,
    required this.brandScore,
  });

  static void show(BuildContext context, BrandScore brandScore) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BrandScoreBottomSheet(brandScore: brandScore),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 400.w,
                height: 12.h,
                margin: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        SizedBox(height: 24.h),
                        _buildOverallScore(),
                        SizedBox(height: 24.h),
                        _buildCategoryScore(brandScore.veganismScore),
                        SizedBox(height: 20.h),
                        _buildCategoryScore(brandScore.environmentalScore),
                        SizedBox(height: 20.h),
                        _buildCategoryScore(brandScore.socialScore),
                        if (brandScore.additionalInfo != null) ...[
                          SizedBox(height: 24.h),
                          _buildAdditionalInfo(),
                        ],
                        SizedBox(height: 20.h),
                        _buildDisclaimer(),
                        // Add bottom safe area padding
                        SizedBox(
                            height:
                                MediaQuery.of(context).padding.bottom + 40.h),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Évaluation de la marque',
          style: TextStyle(
            fontSize: 60.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          brandScore.brandName,
          style: TextStyle(
            fontSize: 54.sp,
            fontWeight: FontWeight.w600,
            color: brandScore.overallScore.color,
          ),
        ),
      ],
    );
  }

  Widget _buildOverallScore() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            brandScore.overallScore.color.withOpacity(0.1),
            brandScore.overallScore.color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: brandScore.overallScore.color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            'Note globale',
            style: TextStyle(
              fontSize: 60.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 150.w,
            height: 150.w,
            decoration: BoxDecoration(
              color: brandScore.overallScore.color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                brandScore.overallScore.value.toString(),
                style: TextStyle(
                  fontSize: 60.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            brandScore.overallScore.label,
            style: TextStyle(
              fontSize: 60.sp,
              fontWeight: FontWeight.bold,
              color: brandScore.overallScore.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryScore(CategoryScore category) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: category.score.color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.w,
                height: 20.w,
                decoration: BoxDecoration(
                  color: category.score.color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 60.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: category.score.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  category.score.label,
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w600,
                    color: category.score.color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            category.description,
            style: TextStyle(
              fontSize: 40.sp,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          ...category.details.map((detail) => Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      margin: EdgeInsets.only(top: 10.h, right: 12.w),
                      decoration: BoxDecoration(
                        color: category.score.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          fontSize: 40.sp,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade600,
                size: 40.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Informations complémentaires',
                style: TextStyle(
                  fontSize: 40.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            brandScore.additionalInfo!,
            style: TextStyle(
              fontSize: 40.sp,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 1,
        ),
      ),
      child: Text(
        'ℹ️ Ces évaluations sont basées sur des informations publiques et peuvent évoluer. Elles visent à vous informer pour faire des choix éclairés.',
        style: TextStyle(
          fontSize: 40.sp,
          color: Colors.orange.shade800,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
