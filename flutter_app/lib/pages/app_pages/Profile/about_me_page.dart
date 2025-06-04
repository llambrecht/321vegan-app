import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening the Instagram link

class AboutMePage extends StatelessWidget {
  const AboutMePage({super.key});

  // Launch Instagram function
  void _launchInstagram(BuildContext context) async {
    const instagramUrl = 'instagram://user?username=321vegan.app';
    const fallbackUrl = 'https://instagram.com/321vegan.app';

    try {
      bool launched = await launchUrl(Uri.parse(instagramUrl),
          mode: LaunchMode.externalApplication);

      if (!launched) {
        // If Instagram app cannot be opened, open in a browser instead
        await launchUrl(Uri.parse(fallbackUrl),
            mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Impossible d\'ouvrir Instagram. Veuillez vérifier l\'application ou votre connexion.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // About Me Section
        Container(
          color: Colors.green[50],
          padding: const EdgeInsets.all(16),
          child: Text.rich(
            TextSpan(
              text: "Merci d'utiliser ",
              style: TextStyle(fontSize: 44.sp), // Default style
              children: const <TextSpan>[
                TextSpan(
                  text: "321 Vegan",
                  style: TextStyle(
                      fontWeight: FontWeight.bold), // Bold style for 321Vegan
                ),
                TextSpan(
                  text:
                      " ! J'ai développé cette application entièrement gratuite et sans publicités ",
                ),
                TextSpan(
                  text:
                      "afin d'aider la communauté végane à identifier plus facilement les produits végétaliens. \nAidez-moi à la faire vivre en la partageant autour de vous !",
                )
              ],
            ),
          ),
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: GestureDetector(
            onTap: () => _launchInstagram(context),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _launchInstagram(context),
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.blue.withOpacity(0.2),
                highlightColor: Colors.blue.withOpacity(0.1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Logo inside a circle
                      ClipOval(
                        child: Image.asset(
                          'lib/assets/logo_instagram.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rejoignez moi sur Instagram',
                            style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '@321vegan.app',
                            style: TextStyle(
                              fontSize: 50.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(top: 16, right: 16),
          child: GestureDetector(
            onTap: () async {
              const url = 'https://plantbasedtreaty.org/fr';
              await launchUrl(Uri.parse(url));
            },
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                splashColor: Colors.green.withOpacity(0.2),
                highlightColor: Colors.green.withOpacity(0.1),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          'lib/assets/logo_pbt.png',
                          width: 50,
                          height: 50,
                          fit: BoxFit.fill,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'J\'ai signé le Traité Végétalien',
                            style: TextStyle(
                              fontSize: 50.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Signez aussi !',
                            style: TextStyle(
                              fontSize: 50.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {
            Share.share(
              'Découvrez l\'application 321 Vegan (scan de produits, recherche d\'additifs, suivi de votre impact), sur Android et iOS ! https://linktr.ee/321vegan',
              subject: '321Vegan App',
            );
          },
          icon: const Icon(Icons.share),
          label: const Text('Partager l\'application'),
        ),
      ],
    );
  }
}
