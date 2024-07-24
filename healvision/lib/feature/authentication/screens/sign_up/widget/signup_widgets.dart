import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../utilis/constants/colors.dart';
import '../../../../../utilis/constants/size.dart';
import '../../../../../utilis/constants/text_string.dart';
import '../../../../../utilis/validations/validation.dart';
import '../../../controllers/signup/signup_controller.dart';

class TSignUpForm extends StatelessWidget {
  const TSignUpForm({
    super.key,
    required this.dark,
  });

  final bool dark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
      child: Column(
        children: [
          // First Name & Last Name
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.firstname,
                  validator: (value) =>
                      TValidator.vaildationEmptyText('First Name', value),
                  expands: false,
                  decoration: InputDecoration(
                    labelText: WTexts.firstName,
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(
                width: TSizes.spaceBtwInputFields,
              ),
              Expanded(
                child: TextFormField(
                  expands: false,
                  controller: controller.lastname,
                  validator: (value) =>
                      TValidator.vaildationEmptyText('Last Name', value),
                  decoration: InputDecoration(
                    labelText: WTexts.lastName,
                    labelStyle: Theme.of(context).textTheme.labelSmall,
                    prefixIcon: const Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Username
          TextFormField(
            expands: false,
            controller: controller.username,
            validator: (value) =>
                TValidator.vaildationEmptyText('User Name', value),
            decoration: InputDecoration(
              labelText: WTexts.username,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              prefixIcon: const Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Email
          TextFormField(
            expands: false,
            controller: controller.email,
            validator: (value) => TValidator.validateEmail(value),
            decoration: InputDecoration(
              labelText: WTexts.email,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              prefixIcon: const Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Phone Number
          TextFormField(
            expands: false,
            controller: controller.phonenumber,
            validator: (value) => TValidator.validatePhoneNumber(value),
            decoration: InputDecoration(
              labelText: WTexts.phoneNo,
              labelStyle: Theme.of(context).textTheme.labelSmall,
              prefixIcon: const Icon(Iconsax.call),
            ),
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Role Selection Drop down
          DropdownButtonFormField(
            validator: (value) => TValidator.vaildationEmptyText('Role', value),
            decoration: const InputDecoration(prefixIcon: Icon(Icons.person)),
            onChanged: (value) {
              controller.selectedRole.value = value.toString();
            },
            items: [
              'Therapist',
              'Patient'
            ]
                .map(
                  (option) => DropdownMenuItem(
                    value: option,
                    child: Text(option),
                  ),
                )
                .toList(),
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Password
          Obx(
            () => TextFormField(
              expands: false,
              controller: controller.password,
              obscureText: controller.hidepassword.value,
              validator: (value) => TValidator.validatePassword(value),
              decoration: InputDecoration(
                labelText: WTexts.password,
                labelStyle: Theme.of(context).textTheme.labelSmall,
                prefixIcon: const Icon(Iconsax.password_check),
                suffixIcon: IconButton(
                  onPressed: () => controller.hidepassword.value =
                      !controller.hidepassword.value,
                  icon: Icon(
                    controller.hidepassword.value
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: TSizes.spaceBtwInputFields,
          ),
          // Term & Condition checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Obx(
                  () => Checkbox(
                    value: controller.privacyPolicy.value,
                    onChanged: (value) => controller.privacyPolicy.value =
                        !controller.privacyPolicy.value,
                  ),
                ),
              ),
              const SizedBox(
                width: TSizes.spaceBtwItem,
              ),
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: WTexts.iAgreeTo,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    TextSpan(
                      text: WTexts.privacyPolicy,
                      style: Theme.of(context).textTheme.labelSmall!.apply(
                            color: dark ? WColors.white : WColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                    TextSpan(
                      text: WTexts.and,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    TextSpan(
                      text: WTexts.termsOfUse,
                      style: Theme.of(context).textTheme.labelSmall!.apply(
                            color: dark ? WColors.white : WColors.primary,
                            decoration: TextDecoration.underline,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // SignUp Button
          const SizedBox(
            height: TSizes.spaceBtwSections,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.signup(),
              child: const Text(WTexts.createAccount),
            ),
          ),
        ],
      ),
    );
  }
}
