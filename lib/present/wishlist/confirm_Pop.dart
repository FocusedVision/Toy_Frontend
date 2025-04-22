import 'package:flutter/material.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/config/style.dart';
import 'package:toyvalley/component/button/main_Button.dart';
import 'package:toyvalley/component/container/rounded_Container.dart';
import 'cross_Icon.dart';

class ConfirmPopUp extends StatelessWidget {
  const ConfirmPopUp({Key? key, required this.label, required this.onTap})
    : super(key: key);

  final String label;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: RoundedContainer(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.17,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
          child: Column(
            children: [
              const CrossIcon(),
              Text(
                label,
                style: h4TextStyle.copyWith(
                  fontSize: MediaQuery.of(context).size.height * 0.019,
                ),
              ),
              const Spacer(),
              actions(context),
            ],
          ),
        ),
      ),
    );
  }

  Row actions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: MainButton(
            height: 54,
            shadowColor: MyColors.greenShadow,
            mainColor: MyColors.greenLight,
            label: 'No'.toUpperCase(),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: MainButton(
            height: 54,
            shadowColor: MyColors.redShadow,
            mainColor: MyColors.redLight,
            label: 'Yes'.toUpperCase(),
            onTap: () {
              onTap();
              Navigator.pop(context);
            },
          ),
        ),
      ],
    );
  }
}
