import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/loading_widget.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/members/friend_request_model.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/profile/screens/member_profile_screen.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

import '../../../utils/app_constants.dart';

class MemberFriendsScreen extends StatefulWidget {
  final int memberId;

  const MemberFriendsScreen({required this.memberId});

  @override
  State<MemberFriendsScreen> createState() => _MemberFriendsScreenState();
}

class _MemberFriendsScreenState extends State<MemberFriendsScreen> {
  List<FriendRequestModel> membersList = [];
  late Future<List<FriendRequestModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  int friendCount=0;

  @override
  void initState() {
   init();
    setStatusBarColor(Colors.transparent);
    super.initState();
  }

 /* Future<List<FriendRequestModel>> friendsList() async {
    appStore.setLoading(true);

    await getFriendList(page: mPage, userId: widget.memberId,membersList: membersList).then((value) {
      if (mPage == 1) membersList.clear();

      mIsLastPage = value.length != 20;
      membersList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      setState(() {});
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return membersList;
  }*/
  Future<void> init({bool showLoader = true}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }

    future = getFriendList(
      page: mPage,
      membersList: membersList,
      userId: appStore.loginUserId.toInt(),
      lastPageCallback: (b) => mIsLastPage = b,
      countCall: (p0) => friendCount = p0,
    ).whenComplete(() {
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      throw e;
    });
  }

  Future<void> onRefresh() async {
    isError = false;
    mPage = 1;
    init();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: context.iconColor),
          title: Text(language.friends, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            FutureBuilder<List<FriendRequestModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      onRefresh();
                    },
                    retryText: '   ${language.clickToRefresh}   ',
                  ).center();
                }

                if (snap.hasData) {
                  if (snap.data.validate().isEmpty) {
                    return NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError ? language.somethingWentWrong : language.noDataFound,
                      onRetry: () {
                        onRefresh();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center();
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(
                        delay: 80.milliseconds,
                        verticalOffset: 300,
                      ),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: membersList.length,
                      itemBuilder: (context, index) {
                        FriendRequestModel friend = membersList[index];

                        return Row(
                          children: [
                            cachedImage(
                              friend.userImage.validate(),
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(100),
                            20.width,
                            Column(
                              children: [
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(text: '${friend.userName.validate()} ', style: boldTextStyle(fontFamily: fontFamily)),
                                      if (friend.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                                    ],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.start,
                                ),
                                Text(friend.userMentionName.validate(), style: secondaryTextStyle()),
                              ],
                              crossAxisAlignment: CrossAxisAlignment.start,
                            ).expand(),
                          ],
                        ).onTap(() async {
                          MemberProfileScreen(memberId: friend.userId.validate()).launch(context);
                        }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8);
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          init();
                        }
                      },
                    );
                  }
                }
                return Offstage();
              },
            ),
            Observer(
              builder: (_) {
                if (appStore.isLoading) {
                  return Positioned(
                    bottom: mPage != 1 ? 10 : null,
                    child: LoadingWidget(isBlurBackground: mPage == 1 ? true : false),
                  );
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
