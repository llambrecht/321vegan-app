import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vegan_app/helpers/helper.dart';
import 'package:vegan_app/models/vegan_status.dart';
import 'package:vegan_app/pages/app_pages/helpers/product.helper.dart';

class NoResultCard extends StatelessWidget {
  const NoResultCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      height: 1000.h,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Scannez un code-barre pour savoir si le produit est vegan !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 60.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Image.asset(
            'lib/assets/app_icon.png',
            height: 300.h,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 8),
          Text(
            "La base de données est construite à partir de\nOpenFoodFacts.\nLe scan est prévu pour les produits alimentaires. Pour les cosmétiques, vous pouvez utiliser la recherche.",
            style: TextStyle(fontSize: 40.sp),
          ),
        ],
      ),
    );
  }
}

class NotFoundProductInfoCard extends StatelessWidget {
  final Map<dynamic, dynamic>? productInfo;

  const NotFoundProductInfoCard({
    super.key,
    required this.productInfo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 850.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              productInfo?['code'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              (() {
                return 'Ce produit a déjà été soumis mais il est introuvable ! Vous pouvez m\'aider en me transmettant des informations sur celui-ci. Merci !';
              })(),
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Introuvable",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NonVeganProductInfoCard extends StatefulWidget {
  final Map<dynamic, dynamic>? productInfo;
  final ConfettiController confettiController;

  const NonVeganProductInfoCard({
    super.key,
    required this.productInfo,
    required this.confettiController,
  });

  @override
  NonVeganProductInfoCardState createState() => NonVeganProductInfoCardState();
}

class NonVeganProductInfoCardState extends State<NonVeganProductInfoCard> {
  bool _isButtonDisabled = false;

  void resetButton() {
    setState(() {
      _isButtonDisabled = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.productInfo?['name'] ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "Produit non référencé. Envoyez le en cliquant sur un des bouton et nous l'ajouterons après vérification !",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              "(Produits alimentaires uniquement)",
              textAlign: TextAlign.left,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 60.h),
            // Side by side buttons for vegan/non-vegan
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonDisabled
                        ? null
                        : () async {
                            bool success = await ProductHelper.tryAddDocument(
                              context,
                              widget.productInfo,
                              VeganStatus.vegan, // Vegan
                            );
                            if (success) {
                              setState(() {
                                _isButtonDisabled = true;
                              });
                              widget.confettiController.play();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 20.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 60.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "C'est végane",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isButtonDisabled
                        ? null
                        : () async {
                            bool success = await ProductHelper.tryAddDocument(
                              context,
                              widget.productInfo,
                              VeganStatus.nonVegan, // Non vegan
                            );
                            if (success) {
                              setState(() {
                                _isButtonDisabled = true;
                              });
                              widget.confettiController.play();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                          vertical: 16.h, horizontal: 20.w),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.block,
                          color: Colors.white,
                          size: 60.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          "C'est pas végane",
                          style: TextStyle(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 500.w,
                child: ElevatedButton(
                  onPressed: _isButtonDisabled
                      ? null
                      : () async {
                          bool success = await ProductHelper.tryAddDocument(
                            context,
                            widget.productInfo,
                            VeganStatus.maybeVegan, // Maybe vegan
                          );
                          if (success) {
                            setState(() {
                              _isButtonDisabled = true;
                            });
                            widget.confettiController.play();
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding:
                        EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.white,
                        size: 60.sp,
                      ),
                      SizedBox(width: 20.w),
                      Text(
                        'Je ne sais pas',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RejectedProductInfoCard extends StatelessWidget {
  final Map<dynamic, dynamic>? productInfo;

  const RejectedProductInfoCard({
    super.key,
    required this.productInfo,
  });

  @override
  Widget build(BuildContext context) {
    // In the database, the reason why its not vegan is stored in the brand field; separated by '--'
    final reason = productInfo?['problem'];
    final brand = productInfo?['brand'];

    return Container(
      height: 600.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade200],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.red,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Helper.truncate(
                (productInfo?['name']?.isNotEmpty ?? false)
                    ? productInfo!['name']
                    : 'Unnamed Product',
                45,
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 70.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              (() {
                // Check if the brand is not null and is a non-empty string
                if (brand != null && brand is String && brand.isNotEmpty) {
                  // Capitalize the first letter and keep the rest
                  String formattedBrand =
                      '${brand[0].toUpperCase()}${brand.substring(1)}';
                  if (formattedBrand.length > 30) {
                    // Truncate and add ellipsis
                    formattedBrand = '${formattedBrand.substring(0, 30)}...';
                  }
                  return formattedBrand;
                }
                // Default text
                return 'Marque inconnue';
              })(),
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            // Add a text for the reason
            const SizedBox(height: 16),
            Text(
              "Pas Vegan !",
              style: TextStyle(
                fontSize: 80.sp,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            if (reason != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
