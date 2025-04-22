import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toyvalley/config/colors.dart';

import 'package:toyvalley/cubit/main/cubit.dart';
import 'package:toyvalley/cubit/profile/cubit.dart';

import 'package:toyvalley/component/button/main_Button.dart';
import 'package:toyvalley/present/toy/toy_Screen.dart';
import 'package:toyvalley/present/profile/profile_Screen.dart';
import 'package:toyvalley/present/wishlist/wishlist_Screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MainCubit, MainState>(
      builder: (context, state) {
        return Scaffold(
          //extendBody: true,
          bottomNavigationBar: navigationBar(state, context),
          body: tabs(context)[state.tabIndex],
        );
      },
    );
  }

  Container navigationBar(MainState state, BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.13,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).size.height * 0.019,
        16,
        0,
      ),
      decoration: const BoxDecoration(
        color: MyColors.background,
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, -2),
            color: Color.fromRGBO(51, 51, 51, 0.25),
          ),
        ],
      ),
      child: Align(
        alignment: Alignment.topCenter,
        child: Row(children: navBarItems(state)),
      ),
    );
  }

  List<Widget> navBarItems(MainState state) {
    bool isSmallDisplay = MediaQuery.of(context).size.width < 400;
    return [
      Expanded(
        flex: 1,
        child: MainButton(
          onTap: () {
            context.read<MainCubit>().changeTab(0);
            context.read<ProfileCubit>().getUser();
            context.read<ProfileCubit>().getAvatars();
          },
          mainColor: MyColors.purpleLight,
          shadowColor: MyColors.purpleShadow,
          icon: 'profile',
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: MainButton(
          onTap: () {
            context.read<MainCubit>().changeTab(1);
          },
          mainColor: MyColors.greenLight,
          shadowColor: MyColors.greenShadow,
          icon: 'toys',
          label: 'Toys'.toUpperCase(),
          textSize: isSmallDisplay ? 16 : 18,
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        flex: 2,
        child: MainButton(
          onTap: () {
            context.read<MainCubit>().changeTab(2);
          },
          mainColor: MyColors.orangeLight,
          shadowColor: MyColors.orangeShadow,
          icon: 'heart',
          label: 'Wishlist'.toUpperCase(),
          textSize: isSmallDisplay ? 16 : 18,
        ),
      ),
    ];
  }

  List<Widget> tabs(BuildContext context) {
    return [const ProfileScreen(), const ToysScreen(), const WishlistScreen()];
  }
}
