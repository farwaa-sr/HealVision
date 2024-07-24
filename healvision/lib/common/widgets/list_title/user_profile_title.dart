import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


import '../../../feature/personalization/controllers/user_controller.dart';
import '../../../utilis/constants/colors.dart';
import '../../../utilis/constants/image_strings.dart';
import '../../../utilis/loaders/shimmers/shimmer.dart';
import '../image/t_circular_image.dart';

class TUserProfileTitle extends StatelessWidget {
  const TUserProfileTitle({
    super.key,
    required this.onpressed,
  });
  final VoidCallback onpressed;

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return ListTile(
      leading: Obx(() {
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
      title: Text(
        controller.user.value.fullname,
        style: Theme.of(context)
            .textTheme
            .headlineSmall!
            .apply(color: WColors.white),
      ),
      subtitle: Text(
        controller.user.value.email,
        style:
            Theme.of(context).textTheme.bodyMedium!.apply(color: WColors.white),
      ),
      trailing: IconButton(
        onPressed: onpressed,
        icon: const Icon(
          Iconsax.edit,
          color: WColors.white,
        ),
      ),
    );
  }
}
