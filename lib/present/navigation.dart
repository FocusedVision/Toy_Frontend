import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/cubit/main/cubit.dart';

import 'package:toyvalley/present/welcome_user.dart';
import 'package:toyvalley/component/connect/index.dart';
import 'package:toyvalley/present/video_Intro.dart';
import 'package:toyvalley/present/main_Screen.dart';

class StartNavigation extends StatefulWidget {
  const StartNavigation({Key? key}) : super(key: key);

  @override
  _StartNavigationState createState() => _StartNavigationState();
}

class _StartNavigationState extends State<StartNavigation> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        if (state.screen == MainStateScreen.main) {
          return const MainScreen();
        } else if (state.screen == MainStateScreen.intro) {
          return VideoIntro();
        } else if (state.screen == MainStateScreen.loading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: MyColors.orange),
            ),
          );
        } else if (state.screen == MainStateScreen.noConnection) {
          return Scaffold(body: NoConnection(isRetryAvailable: true));
        } else if (state.screen == MainStateScreen.newUser) {
          return const WelcomeUserScreen();
        } else {
          return const Scaffold();
        }
      },
    );
  }
}
