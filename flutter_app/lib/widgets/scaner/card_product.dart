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
            "La base de données est construite à partir de\nOpenFoodFacts.\nCertains produits peuvent ne pas être référencés, mais vous pouvez nous aider à les ajouter en les scannant et en les signalant !",
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
              "Ce produit nous est inconnu. Vous pouvez le signaler comme végane ou non. Merci !",
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 80.h),
            ElevatedButton(
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
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Signaler comme végane',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16), // Add spacing between the buttons
            ElevatedButton(
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
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Signaler comme non végane',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
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
                padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 36.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Je ne sais pas',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
    // TODO : add a separated column for the reason in the database and change this.
    final reason = productInfo?['brand'].split('--')[1];
    final brand = productInfo?['brand'].split('--')[0];

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
