import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../utilis/constants/colors.dart';
import '../../../../../utilis/loaders/shimmers/shimmer.dart';
import '../../../common/widgets/image/t_circular_image.dart';
import '../../../utilis/constants/image_strings.dart';
import '../../personalization/controllers/user_controller.dart';

class PatientHomeAppBar extends StatelessWidget {
  const PatientHomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UserController());
    controller.fetchUserRecord();
    return TAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello there!',
            style: Theme.of(context).textTheme.labelMedium!.apply(
                  color: WColors.grey,
                ),
          ),
          Obx(
            () {
              if (controller.profileloading.value) {
                // Display a shimmer loader while user profile is being loading
                return const TShimmerEffect(width: 80, height: 15);
              } else {
                return Text(
                  controller.user.value.fullname,
                  style: Theme.of(context).textTheme.headlineSmall!.apply(
                        color: WColors.white,
                      ),
                );
              }
            },
          ),
        ],
      ),
      action: [
        Obx(() {
          final networkImage = controller.user.value.profilePicture;
          final image = networkImage.isNotEmpty ? networkImage : WImages.user;
          return controller.imageUploading.value
              ? const TShimmerEffect(width: 80, height: 80)
              : TCircularimage(
                  image: image,
                  width: 50,
                  height: 50,
                  isNetwork: networkImage.isNotEmpty,
                );
        }),
        const SizedBox(
          width: 15,
        ),
      ],
    );
  }
}
