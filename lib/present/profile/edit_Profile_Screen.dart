import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/config/style.dart';
import 'package:toyvalley/cubit/profile/cubit.dart';
import 'package:toyvalley/cubit/profile/state.dart';
import 'package:toyvalley/component/avatar/avatar_Select.dart';
import 'package:toyvalley/component/bar/simple_Bar.dart';
import 'package:toyvalley/component/button/main_Button.dart';
import 'package:toyvalley/component/text/custom_Text.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Scaffold(
          appBar: const SimpleAppBar(title: 'Edit account', isBackArrow: false),
          bottomNavigationBar: const EditAccountControls(),
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
                    const SizedBox(height: 35),
                    Text(
                      'Your avatar:',
                      style: h4TextStyle.copyWith(
                        fontSize: MediaQuery.of(context).size.height * 0.019,
                      ),
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

class EditAccountControls extends StatelessWidget {
  const EditAccountControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          height: MediaQuery.of(context).size.height * 0.13 - 16,
          child: Align(
            alignment: Alignment.topCenter,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: MainButton(
                    isColumn: true,
                    onTap: () {
                      Navigator.pop(context);
                    },
                    mainColor: MyColors.purpleLight,
                    shadowColor: MyColors.purpleShadow,
                    icon: 'back',
                    label: 'Back',
                    textSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 4,
                  child: MainButton(
                    onTap: () {
                      context
                          .read<ProfileCubit>()
                          .updateUser(state.newName, state.newAvatar)
                          .then((value) {
                            if (value != false) {
                              Navigator.pop(context);
                            }
                          });
                    },
                    mainColor: MyColors.greenLight,
                    shadowColor: MyColors.greenShadow,
                    label: 'Save'.toUpperCase(),
                    textSize: 20,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
