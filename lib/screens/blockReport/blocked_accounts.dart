import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/loading_widget.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/block_report/blocked_accounts_model.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/blockReport/components/unblock_member_dialog.dart';
import 'package:Biii_Life/screens/profile/screens/member_profile_screen.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

import '../../utils/app_constants.dart';

class BlockedAccounts extends StatefulWidget {
  const BlockedAccounts({Key? key}) : super(key: key);

  @override
  State<BlockedAccounts> createState() => _BlockedAccountsState();
}

class _BlockedAccountsState extends State<BlockedAccounts> {
  List<BlockedAccountsModel> membersList = [];
  late Future<List<BlockedAccountsModel>> future;

  int mPage = 1;
  bool mIsLastPage = false;
  bool isError = false;

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    future = blockedList();

    setStatusBarColor(Colors.transparent);
    super.initState();
  }

  @override
  void dispose() {
    appStore.setLoading(false);
    super.dispose();
  }

  Future<List<BlockedAccountsModel>> blockedList() async {
    appStore.setLoading(true);

    await getBlockedAccounts().then((value) {
      membersList.clear();

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
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        mPage = 1;
        future = blockedList();
      },
      color: context.primaryColor,
      child: Scaffold(
        appBar: AppBar(
          title: Text(language.blockedAccounts, style: boldTextStyle(size: 20)),
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: context.iconColor),
            onPressed: () {
              finish(context);
            },
          ),
        ),
        body: Stack(
          alignment: Alignment.topCenter,
          children: [
            FutureBuilder<List<BlockedAccountsModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return NoDataWidget(
                    imageWidget: NoDataLottieWidget(),
                    title: isError ? language.somethingWentWrong : language.noDataFound,
                    onRetry: () {
                      mPage = 1;
                      future = blockedList();
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
                        mPage = 1;
                        future = blockedList();
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center();
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                      physics: AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50),
                      itemCount: membersList.length,
                      itemBuilder: (context, index) {
                        BlockedAccountsModel user = membersList[index];

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            cachedImage(
                              user.userImage.validate(),
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ).cornerRadiusWithClipRRect(100).onTap(() async {
                              MemberProfileScreen(memberId: user.userId.validate().toInt()).launch(context).then((value) {
                                if (value ?? false) {
                                  mPage = 1;
                                  future = blockedList();
                                }
                              });
                            }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(vertical: 8),
                            20.width,
                            InkWell(
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(text: '${user.userName.validate()} ', style: boldTextStyle(fontFamily: fontFamily)),
                                        if (user.isUserVerified.validate()) WidgetSpan(child: Image.asset(ic_tick_filled, height: 18, width: 18, color: blueTickColor, fit: BoxFit.cover)),
                                      ],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ),
                                  Text(user.userMentionName.validate(), style: secondaryTextStyle()),
                                ],
                                crossAxisAlignment: CrossAxisAlignment.start,
                              ),
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              onTap: () {
                                MemberProfileScreen(memberId: user.userId.validate().toInt()).launch(context).then((value) {
                                  if (value ?? false) {
                                    mPage = 1;
                                    future = blockedList();
                                  }
                                });
                              },
                            ).expand(),
                            TextButton(
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(defaultAppButtonRadius),
                                    side: BorderSide(color: context.primaryColor),
                                  ),
                                ),
                              ),
                              onPressed: () async {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return UnblockMemberDialog(
                                      name: user.userName.validate(),
                                      mentionName: user.userMentionName.validate(),
                                      id: user.userId.validate().toInt(),
                                      callback: () {
                                        future = blockedList();
                                      },
                                    );
                                  },
                                );
                              },
                              child: Text(language.unblock, style: primaryTextStyle(size: 14, color: context.primaryColor)),
                            ),
                          ],
                        );
                      },
                      onNextPage: () {
                        if (!mIsLastPage) {
                          mPage++;
                          future = blockedList();
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
                    child: LoadingWidget(),
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
