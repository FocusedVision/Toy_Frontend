import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/config/style.dart';

import 'package:toyvalley/cubit/main/cubit.dart';
import 'package:toyvalley/cubit/profile/cubit.dart';
import 'package:toyvalley/cubit/profile/state.dart';
import 'package:toyvalley/component/bar/main_Bar.dart';
import 'package:toyvalley/component/button/main_Button.dart';
import 'package:toyvalley/component/text/custom_Text.dart';
import 'package:toyvalley/component/avatar/avatar_Select.dart';

class WelcomeUserScreen extends StatefulWidget {
  const WelcomeUserScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeUserScreen> createState() => _WelcomeUserScreenState();
}

class _WelcomeUserScreenState extends State<WelcomeUserScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const MainAppBar(label: ''),
          bottomNavigationBar: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 30),
            child: MainButton(
              onTap: () {
                context
                    .read<ProfileCubit>()
                    .updateUser(state.newName, state.newAvatar)
                    .then((value) {
                      if (value != false) {
                        context.read<MainCubit>().toMain();
                      }
                    });
              },
              label: 'Get started'.toUpperCase(),
              mainColor: MyColors.greenLight,
              shadowColor: MyColors.greenShadow,
              isActive:
                  state.newName?.isNotEmpty == true && state.newAvatar != null,
              textSize: 20,
            ),
          ),

          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
            },
            child: Padding(
              padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Hey! Welcome ',
                            style: h2TextStyle.copyWith(
                              fontFamily: 'VAG Rounded Std',
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0236,
                            ),
                          ),
                          TextSpan(
                            text: '👋🏻',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.0236,
                              fontFamily: 'EmojiOne',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Choose your avatar:',
                      style: h4TextStyle.copyWith(
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const AvatarSelect(),
                    const SizedBox(height: 32),
                    Text(
                      'Your name:',
                      style: h4TextStyle.copyWith(
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26.0),
                      child: CustomTextField(initValue: state.user?.name ?? ''),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
