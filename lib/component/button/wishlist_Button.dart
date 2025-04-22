import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:toyvalley/cubit/main/cubit.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/component/button/main_Button.dart';

class WishlistButton extends StatefulWidget {
  const WishlistButton({
    Key? key,
    required this.toyId,
    required this.add,
    required this.remove,
    required this.isSelected,
  }) : super(key: key);

  final int toyId;
  final Function add;
  final Function remove;
  final bool isSelected;

  @override
  _WishlistButtonState createState() => _WishlistButtonState();
}

class _WishlistButtonState extends State<WishlistButton> {
  late bool isSelected = widget.isSelected;
  double iconHeight = 18;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainCubit, MainState>(
      listener: (context, state) {
        bool a =
            state.products!
                .firstWhere((element) => element.id == widget.toyId)
                .isInUserProducts!;
        if (a != isSelected) {
          isSelected = a;
        }
      },
      builder: (context, state) {
        return MainButton(
          onTap: () {
            animate();
            if (!isSelected) {
              widget.remove();
            } else {
              widget.add();
            }
          },
          mainColor: MyColors.orangeLight,
          shadowColor: MyColors.orangeShadow,
          iconSize: 17,
          icon: isSelected ? "hearth_filled" : "hearth",
          textSize: 11,
          label: "Add to wishlist",
          isColumn: true,
        );
      },
    );
  }

  void animate() {
    setState(() {
      isSelected = !isSelected;
      if (isSelected) {}
    });
  }
}
