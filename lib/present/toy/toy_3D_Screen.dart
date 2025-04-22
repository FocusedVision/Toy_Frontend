import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:toyvalley/cubit/main/cubit.dart';
import 'package:toyvalley/cubit/toy/cubit.dart';
import 'package:toyvalley/config/colors.dart';
import 'package:toyvalley/component/connect/index.dart';
import 'package:toyvalley/component/bar/simple_Bar.dart';
import 'package:toyvalley/component/3D_View/model_View_Mobile.dart';
import 'package:toyvalley/component/3D_View/toy_3D_Panel.dart';
import 'package:toyvalley/component/3D_View/toy_3D_Bar.dart';

class Toy3D extends StatefulWidget {
  const Toy3D({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<Toy3D> createState() => _Toy3DState();
}

class _Toy3DState extends State<Toy3D> with SingleTickerProviderStateMixin {
  bool animationIsStarted = false;
  bool pause = true;
  bool isLoaded = false;

  double offset = 0;
  int timeInThisScreen = 0;

  late Timer timer;
  late Animation<double> animation;
  late AnimationController controller;

  final GlobalKey<ModelViewerState> modelViewerKey =
      GlobalKey<ModelViewerState>();

  @override
  void initState() {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => timeInThisScreen = timer.tick,
    );
    controller = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller)
      ..addListener(() {
        if (!isLoaded) {
          setState(() {
            offset = controller.value;
          });
        } else {
          setState(() {
            offset = 1;
            controller.stop();
          });
        }
      });

    controller.forward();
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    controller.dispose();
    animation.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ToyCubit, ToyState>(
      builder: (context, state) {
        final toy = state.currentProduct;
        return !state.noConnection
            ? WillPopScope(
              onWillPop: () async {
                if (toy != null) {
                  context.read<MainCubit>().sendAnalyticsEvent(
                    6,
                    seconds: timeInThisScreen,
                    id: toy.id,
                  );
                }

                if (Platform.isAndroid) {
                  Navigator.pop(context);
                }
                return true;
              },
              child: Scaffold(
                body:
                    !state.isLoading && toy != null
                        ? Column(
                          //fit: StackFit.expand,
                          children: [
                            Container(
                              color: MyColors.background,
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).padding.top,
                            ),
                            Toy3DPanel(
                              toy: toy,
                              modelViewerKey: modelViewerKey,
                              isLoaded: isLoaded,
                              offset: offset,
                              onResetButtonTap: () {
                                setState(() {
                                  pause = true;
                                });
                              },
                              onModelLoaded: () {
                                setState(() {
                                  isLoaded = true;
                                });
                              },
                            ),
                            Toy3DBottomBar(
                              toy: toy,
                              title: widget.title,
                              paused: pause,
                              onPauseButtonTap: () {
                                if (isLoaded) {
                                  setState(() {
                                    if (animationIsStarted) {
                                      if (pause) {
                                        modelViewerKey.currentState!.play();
                                      } else {
                                        modelViewerKey.currentState!.pause();
                                      }
                                      pause = !pause;
                                    } else {
                                      context
                                          .read<MainCubit>()
                                          .sendAnalyticsEvent(2, id: toy.id);
                                      modelViewerKey.currentState!.play();
                                      animationIsStarted = true;
                                      pause = false;
                                    }
                                  });
                                }
                              },
                              onBackButtonTap: () {
                                context.read<MainCubit>().sendAnalyticsEvent(
                                  6,
                                  seconds: timeInThisScreen,
                                  id: toy.id,
                                );
                                Navigator.pop(context);
                              },
                            ),
                          ],
                        )
                        : const SizedBox(),
              ),
            )
            : Scaffold(
              appBar: SimpleAppBar(title: ''),
              body: Padding(
                padding: const EdgeInsets.only(bottom: 130.0),
                child: NoConnection(),
              ),
            );
      },
    );
  }
}
