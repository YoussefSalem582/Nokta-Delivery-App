import 'package:delivery_app/core/theme/nokta_colors.dart';
import 'package:delivery_app/features/auth/presentation/widgets/auth_choice/auth_choice_option_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class AuthChoiceOptions extends StatelessWidget {
  const AuthChoiceOptions({
    super.key,
    required this.onSignIn,
    required this.onSignUp,
  });

  final VoidCallback onSignIn;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AuthChoiceOptionCard(
          icon: Icons.person_add_outlined,
          title: 'auth_choice_sign_up'.tr(),
          subtitle: 'auth_choice_sign_up_hint'.tr(),
          emphasized: true,
          onTap: onSignUp,
        ),
        const SizedBox(height: NoktaSpacing.md),
        AuthChoiceOptionCard(
          icon: Icons.login_rounded,
          title: 'auth_choice_sign_in'.tr(),
          subtitle: 'auth_choice_sign_in_hint'.tr(),
          onTap: onSignIn,
        ),
      ],
    );
  }
}
