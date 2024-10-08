import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/screens/groups/screens/create_group_screen.dart';
import 'package:Biii_Life/screens/membership/screens/membership_plans_screen.dart';
import 'package:Biii_Life/utils/app_constants.dart';

class InitialNoGroupComponent extends StatefulWidget {
  final VoidCallback? callback;

  InitialNoGroupComponent({this.callback});

  @override
  State<InitialNoGroupComponent> createState() => _InitialNoGroupComponentState();
}

class _InitialNoGroupComponentState extends State<InitialNoGroupComponent> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        EmptyPostLottieWidget(),
        Text(
          language.startACommunity,
          style: secondaryTextStyle(),
          textAlign: TextAlign.center,
        ).paddingSymmetric(horizontal: 32),
        16.height,
        TextButton(
          style: ButtonStyle(
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            side: MaterialStateProperty.all(BorderSide(color: appColorPrimary.withOpacity(0.5))),
          ),
          onPressed: () {
            if (pmpStore.canCreateGroup) {
              CreateGroupScreen().launch(context).then((value) {
                if (value) widget.callback?.call();
              });
            } else {
              MembershipPlansScreen().launch(context);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, size: 20, color: context.iconColor),
              4.width,
              Text(language.createGroup, style: primaryTextStyle(size: 14)),
            ],
          ),
        ),
      ],
    );
  }
}
