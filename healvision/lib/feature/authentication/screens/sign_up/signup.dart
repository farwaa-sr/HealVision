import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';
import '../../../../utilis/constants/colors.dart';
import '../../../../utilis/constants/size.dart';
import '../../../../utilis/constants/text_string.dart';
import '../../../../utilis/helpers/helper_function.dart';
import 'widget/signup_widgets.dart';

class SignUp extends StatelessWidget {
  const SignUp({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: WColors.white,
        centerTitle: true,
        title: Text(
          'Sign Up',
          style: GoogleFonts.outfit(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
          child: Column(
            children: [
              // Title
              Text(
                WTexts.signupTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(
                height: TSizes.spaceBtwSections,
              ),
              // Form
              TSignUpForm(dark: dark),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              // Divider
              TFormDivider(dark: dark, dividerText: WTexts.orSignUpWith),
              const SizedBox(
                height: TSizes.spaceBtwItem,
              ),
              // Social Buttons
              const TSocialButtons()
            ],
          ),
        ),
      ),
    );
  }
}
