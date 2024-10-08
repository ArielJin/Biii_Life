import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/loading_widget.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/activity_response.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/profile/screens/member_profile_screen.dart';
import 'package:Biii_Life/utils/app_constants.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

class LatestActivityComponent extends StatelessWidget {
  const LatestActivityComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          16.height,
          Text(language.latestActivities, style: boldTextStyle(size: 18)),
          16.height,
          SnapHelperWidget(
            future: latestActivity(),
            onSuccess: (List<ActivityResponse> snap) {
              if (snap.isNotEmpty) {
                return AnimatedListView(
                  shrinkWrap: true,
                  slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                  physics: NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.only(left: 0, right: 0, bottom: 16),
                  itemCount: snap.length,
                  itemBuilder: (ctx, index) {
                    ActivityResponse activity = snap[index];
                    return InkWell(
                      onTap: () {
                        MemberProfileScreen(memberId: activity.userId.validate()).launch(context);
                      },
                      child: Column(
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (activity.userAvatar!.full.validate() != 'false')
                                cachedImage(activity.userAvatar!.full.validate(), height: 40, width: 40, fit: BoxFit.cover).cornerRadiusWithClipRRect(20),
                              16.width,
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (activity.title.validate().isNotEmpty)
                                    Text(parseHtmlString(activity.title.validate()), style: primaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 2)
                                  else if(activity.content!.rendered.validate().isNotEmpty)
                                    Text('${activity.name.validate()} ' + parseHtmlString(activity.content!.rendered.validate()), style: primaryTextStyle(), overflow: TextOverflow.ellipsis, maxLines: 2),
                                  Text(convertToAgo(activity.date.validate()), style: secondaryTextStyle()),
                                ],
                              ).expand(),
                            ],
                          ),
                          Divider(height: 32),
                        ],
                      ),
                    );
                  },
                );
              } else {
                return NoDataWidget(title: language.noDataFound);
              }
            },
            errorWidget: NoDataWidget(title: language.somethingWentWrong, imageWidget: NoDataLottieWidget()),
            loadingWidget: LoadingWidget(isBlurBackground: false).paddingSymmetric(vertical: context.height() * 0.2),
          ),
        ],
      ),
    );
  }
}
