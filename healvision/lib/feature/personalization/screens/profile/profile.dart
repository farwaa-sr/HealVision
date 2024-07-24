import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../common/widgets/image/t_circular_image.dart';
import '../../../../common/widgets/text/section_heading.dart';
import '../../../../data/repositories/authentication/authentication_repository.dart';
import '../../../../utilis/constants/colors.dart';
import '../../../../utilis/constants/image_strings.dart';
import '../../../../utilis/constants/size.dart';
import '../../../../utilis/loaders/shimmers/shimmer.dart';
import '../../controllers/user_controller.dart';
import 'widget/change_name.dart';
import 'widget/profile_menu.dart';

class UserProfile extends StatelessWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      appBar: TAppBar(
        bg: WColors.primary,
        showBackArrow: true,
        title: Text(
          'Profile',
          style: Theme.of(context)
              .textTheme
              .headlineSmall!
              .copyWith(color: WColors.white),
        ),
      ),
      // Body
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              // Profile
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image =
                          networkImage.isNotEmpty ? networkImage : WImages.user;
                      return controller.imageUploading.value
                          ? const TShimmerEffect(width: 80, height: 80)
                          : TCircularimage(
                              image: image,
                              width: 80,
                              height: 80,
                              isNetwork: networkImage.isNotEmpty,
                            );
                    }),
                    TextButton(
                      onPressed: () {
                        controller.uploadUserProfilePicture();
                      },
                      child: const Text('Change Profile Picture',style: TextStyle(color: WColors.black,fontWeight: FontWeight.w800),),
                    ),
                  ],
                ),
              ),

              // Details
              const SizedBox(
                height: TSizes.spaceBtwItem / 2,
              ),
              const Divider(),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              // Heading Information
              const SectionHeading(
                title: 'Profile Information',
                showActionButton: false,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),

              ProfileMenu(
                ontap: () {
                  Get.to(const ChangeName());
                },
                title: 'Name',
                value: controller.user.value.fullname,
              ),
              ProfileMenu(
                ontap: () {},
                title: 'Username',
                value: controller.user.value.username,
              ),

              // Details
              const SizedBox(
                height: TSizes.spaceBtwItem / 2,
              ),
              const Divider(),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              // Heading Information
              const SectionHeading(
                title: 'Personal Information',
                showActionButton: false,
              ),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              ProfileMenu(
                  ontap: () {},
                  title: 'User ID',
                  icon: Iconsax.copy,
                  value: controller.user.value.id),
              ProfileMenu(
                  ontap: () {},
                  title: 'E-Mail',
                  value: controller.user.value.email),
              ProfileMenu(
                  ontap: () {},
                  title: 'Phone No',
                  value: controller.user.value.phoneNumber),
              const Divider(),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.defaultDialog(
                      title: 'Logout!',
                      middleText: 'Are you sure you want to Logout?',
                      onConfirm: () {
                        AuthenticationRepository.instance.logout();
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
              
              Center(
                child: TextButton(
                  onPressed: () {
                    controller.deleteAccountWarningPopup();
                  },
                  child: Text('Delete Account',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall!
                          .apply(color: Colors.red)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
