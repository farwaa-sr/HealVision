import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/containers/primary_header_container.dart';
import '../../../../common/widgets/list_title/setting_menu_title.dart';
import '../../../../common/widgets/list_title/user_profile_title.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utilis/constants/colors.dart';
import '../../../../utilis/constants/size.dart';
import '../profile/profile.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Headrer
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  TAppBar(
                    title: Text(
                      "Account",
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: WColors.white),
                    ),
                  ),
                  // User Profile Card
                  TUserProfileTitle(
                    onpressed: () => Get.to(const UserProfile()),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                ],
              ),
            ),
            // Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  // Account Setting
                  const SectionHeading(
                    title: 'App Setting',
                    showActionButton: false,
                  ),
                  // Logout Button
                  const SizedBox(
                    height: TSizes.spaceBtwItem,
                  ),
                  TSettingMenuTitle(
                    icon: Icons.feedback,
                    title: 'Feedback',
                    subtitle: 'Share your thoughts and suggestions with us',
                    onpressed: () {
                      feedback();
                    },
                  ),
                  TSettingMenuTitle(
                    icon: Icons.rate_review,
                    title: 'Rate Us',
                    subtitle: 'Give us your feedback and help us improve',
                    onpressed: () {
                      rateus();
                    },
                  ),
                  TSettingMenuTitle(
                    icon: Icons.share,
                    title: 'Share',
                    subtitle: 'Spread the word about our app with your friends',
                    onpressed: () {
                      share();
                    },
                  ),
                  TSettingMenuTitle(
                    icon: Iconsax.security_card,
                    title: 'Account Privacy',
                    subtitle:
                        'Control your privacy settings and manage connected accounts',
                    onpressed: () {
                      privacy();
                    },
                  ),

                  // Logout Button
                  const SizedBox(
                    height: TSizes.spaceBtwSections,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.defaultDialog(
                          title: 'Logout!',
                          middleText: 'Are you sure you want to Logout?',
                          onConfirm: () async {
                            await AuthenticationRepository.instance.logout();
                          },
                          onCancel: () => Get.back(),
                        );
                      },
                      child: Text('Logout',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: WColors.white)),
                    ),
                  ),
                  const SizedBox(
                    height: TSizes.spaceBtwSections * 2.5,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<void> privacy() async {
    final Uri url = Uri.parse(
        '');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> feedback() async {
    final Uri url = Uri.parse('');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> share() async {
    final Uri url =
        Uri.parse('');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> rateus() async {
    final Uri url = Uri.parse('');
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}
