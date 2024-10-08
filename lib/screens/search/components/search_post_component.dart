import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/activity_response.dart';
import 'package:Biii_Life/screens/post/screens/single_post_screen.dart';
import 'package:Biii_Life/screens/profile/screens/member_profile_screen.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class SearchPostComponent extends StatefulWidget {
  final List<ActivityResponse> postList;

  const SearchPostComponent({required this.postList});

  @override
  State<SearchPostComponent> createState() => _SearchPostComponentState();
}

class _SearchPostComponentState extends State<SearchPostComponent> {
  @override
  Widget build(BuildContext context) {
    if (widget.postList.isNotEmpty)
      return AnimatedListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
        padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
        itemCount: widget.postList.length,
        itemBuilder: (context, index) {
          ActivityResponse data = widget.postList[index];

          return Container(
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(borderRadius: radius(commonRadius), color: context.cardColor),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    cachedImage(
                      data.userAvatar!.full.validate() != 'false' ? data.userAvatar!.full.validate() : '',
                      height: 40,
                      width: 40,
                      fit: BoxFit.cover,
                    ).cornerRadiusWithClipRRect(100),
                    12.width,
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              data.name.validate(),
                              style: boldTextStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).flexible(flex: 1),
                          ],
                        ),
                        4.height,
                        Text(convertToAgo(data.date.validate()), style: secondaryTextStyle()),
                      ],
                    ).expand(),
                  ],
                ).onTap(() {
                  if (data.userId.validate() != 0) {
                    MemberProfileScreen(memberId: data.userId.validate()).launch(context);
                  } else {
                    toast(language.canNotViewThisUser);
                  }
                }, borderRadius: radius(8)),
                if (data.content!.rendered.validate().isNotEmpty) Text(parseHtmlString(data.content!.rendered..validateAndFilter()), style: primaryTextStyle()).paddingTop(8),
                InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  child: Text(language.viewPost, style: primaryTextStyle(color: context.primaryColor)),
                  onTap: () {
                    SinglePostScreen(postId: data.id.validate()).launch(context);
                  },
                ).center().paddingTop(data.content!.rendered.validate().isNotEmpty ? 0 : 8),
              ],
            ),
          );
        },
      );
    else
      return Observer(
        builder: (_) => SizedBox(
          height: context.height() * 0.7,
          child: NoDataWidget(
            imageWidget: NoDataLottieWidget(),
            title: language.noPostsFound,
          ),
        ).visible(!appStore.isLoading),
      );
  }
}
