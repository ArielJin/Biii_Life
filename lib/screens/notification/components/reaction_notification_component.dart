import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/notifications/notification_model.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/profile/screens/member_profile_screen.dart';
import 'package:Biii_Life/utils/app_constants.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

class ReactionNotificationComponent extends StatelessWidget {
  final NotificationModel element;
  final VoidCallback? callback;

  const ReactionNotificationComponent({required this.element, this.callback});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        cachedImage(element.secondaryItemImage, height: 40, width: 40, fit: BoxFit.cover).cornerRadiusWithClipRRect(100),
        8.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  WidgetSpan(
                    child: Text('${element.secondaryItemName.validate()} ', style: boldTextStyle(size: 14, fontFamily: fontFamily)).onTap(() {
                      MemberProfileScreen(memberId: element.secondaryItemId.validate()).launch(context);
                    }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
                  ),
                  if (element.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                  TextSpan(text: " ${language.reacted} ", style: secondaryTextStyle(fontFamily: fontFamily)),
                  if (element.itemImage.validate().isNotEmpty)
                    WidgetSpan(child: cachedImage(element.itemImage.validate(), height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover).cornerRadiusWithClipRRect(9)),
                  TextSpan(
                    text: element.action == NotificationAction.actionCommentActivityReacted ? " ${language.onYourComment}" : " ${language.onYourPost}",
                    style: secondaryTextStyle(fontFamily: fontFamily),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
            ),
            6.height,
            Text(convertToAgo(element.date.validate()), style: secondaryTextStyle(size: 12)),
          ],
        ).expand(),
        Observer(
          builder: (_) => IconButton(
            onPressed: () async {
              if (!appStore.isLoading)
                showConfirmDialogCustom(
                  context,
                  onAccept: (c) {
                    ifNotTester(() {
                      appStore.setLoading(true);

                      deleteNotification(notificationId: element.id.toString()).then((value) {
                        if (value.deleted.validate()) {
                          callback?.call();
                        }
                      }).catchError((e) {
                        appStore.setLoading(false);
                        toast(e.toString(), print: true);
                      });
                    });
                  },
                  dialogType: DialogType.CONFIRMATION,
                  title: language.deleteNotificationConfirmation,
                  positiveText: language.remove,
                );
            },
            icon: Icon(Icons.delete_outline, color: appStore.isDarkMode ? bodyDark : bodyWhite),
          ),
        ),
      ],
    ).paddingAll(16);
  }
}
