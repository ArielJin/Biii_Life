import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:fluttericon/elusive_icons.dart';
import 'package:fluttericon/octicons_icons.dart';
import 'package:fluttericon/zocial_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/dashboard_api_response.dart';
import 'package:Biii_Life/models/pmp_models/membership_model.dart';
import 'package:Biii_Life/models/reactions/reactions_model.dart';
import 'package:Biii_Life/network/pmp_repositry.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/fragments/forums_fragment.dart';
import 'package:Biii_Life/screens/fragments/home_fragment.dart';
import 'package:Biii_Life/screens/fragments/notification_fragment.dart';
import 'package:Biii_Life/screens/fragments/profile_fragment.dart';
import 'package:Biii_Life/screens/fragments/search_fragment.dart';
import 'package:Biii_Life/screens/home/components/user_detail_bottomsheet_widget.dart';
import 'package:Biii_Life/screens/membership/screens/membership_plans_screen.dart';
import 'package:Biii_Life/screens/messages/functions.dart';
import 'package:Biii_Life/screens/notification/components/latest_activity_component.dart';
import 'package:Biii_Life/screens/post/screens/add_post_screen.dart';
import 'package:Biii_Life/screens/shop/screens/shop_screen.dart';
import 'package:Biii_Life/utils/app_constants.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';
import 'package:Biii_Life/utils/push_notification_service.dart';

import '../utils/chat_reaction_list.dart';
import 'fragments/custom_fragment.dart';
import 'messages/screens/message_screen.dart';

int selectedIndex = 0;

class DashboardScreen extends StatefulWidget {
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

List<VisibilityOptions>? visibilities;
List<StoryActions>? storyActions;
List<VisibilityOptions>? accountPrivacyVisibility;
List<ReportType>? reportTypes;
List<ReactionsModel> reactions = [];

class _DashboardScreenState extends State<DashboardScreen> with TickerProviderStateMixin {
  bool hasUpdate = false;
  late AnimationController _animationController;

  ScrollController _controller = ScrollController();

  late TabController tabController;

  bool onAnimationEnd = true;

  List<Widget> appFragments = [];

  @override
  void initState() {
    _animationController = BottomSheet.createAnimationController(this);
    _animationController.duration = const Duration(milliseconds: 500);
    _animationController.drive(CurveTween(curve: Curves.easeOutQuad));

    super.initState();
    tabController = TabController(length: 5, vsync: this);
    getChatEmojiList();
    PushNotificationService().registerFCMAndTopics();

    init();
  }



  Future<void> init() async {
    appFragments.addAll([
      HomeFragment(controller: _controller),
      // SearchFragment(controller: _controller),
      ForumsFragment(controller: _controller),
      CustomFragment(controller: _controller),
      NotificationFragment(controller: _controller),
      ProfileFragment(controller: _controller),
    ]);


    await getReactionsList();
    defaultReactionsList();

    _controller.addListener(() {
      //
    });

    selectedIndex = 0;
    setState(() {});

    getDetails();

    Map req = {"firebase_token": getStringAsync(SharePreferencesKey.firebaseToken), "add": 1};

    await setPlayerId(req).then((value) {
      //
    }).catchError((e) {
      log("Player id error : ${e.toString()}");
    });

    getNonce().then((value) {
      appStore.setNonce(value.storeApiNonce.validate());
    }).catchError(onError);

    setStatusBarColorBasedOnTheme();

    activeUser();
    getNotificationCount();
    getMediaList();
    if (pmpStore.pmpEnable) getUsersLevel();
    callStream(context);
  }

  Future<void> getMediaList() async {
    await getMediaTypes().then((value) {
      if (value.any((element) => element.type == MediaTypes.gif)) {
        appStore.setShowGif(true);
      }
    }).catchError((e) {
      //
    });
    setState(() {});
  }

  Future<void> getDetails() async {
    await getDashboardDetails().then((value) {
      appStore.setNotificationCount(value.notificationCount.validate());
      appStore.setWebsocketEnable(value.isWebsocketEnable.validate());
      appStore.setVerificationStatus(value.verificationStatus.validate());
      visibilities = value.visibilities.validate();
      accountPrivacyVisibility = value.accountPrivacyVisibility.validate();
      reportTypes = value.reportTypes.validate();
      appStore.setShowStoryHighlight(value.isHighlightStoryEnable.validate());
      appStore.suggestedUserList = value.suggestedUser.validate();
      appStore.suggestedGroupsList = value.suggestedGroups.validate();
      appStore.setShowWooCommerce(value.isWoocommerceEnable.validate());
      appStore.setWooCurrency(parseHtmlString(value.wooCurrency.validate()));
      appStore.setGiphyKey(parseHtmlString(value.giphyKey.validate()));
      appStore.setReactionsEnable(value.isReactionEnable.validate());
      appStore.setLMSEnable(value.isLMSEnable.validate());
      appStore.setCourseEnable(value.isCourseEnable.validate());
      appStore.setDisplayPostCount(value.displayPostCount.validate());
      appStore.setDisplayPostCommentsCount(value.displayPostCommentsCount.validate());
      appStore.setDisplayFriendRequestBtn(value.displayFriendRequestBtn.validate());
      appStore.setShopEnable(value.isShopEnable.validate());
      appStore.setIOSGiphyKey(parseHtmlString(value.iosGiphyKey.validate()));
      appStore.setGamiPressEnable(value.isGamipressEnable.validate() == 1);
      messageStore.setMessageCount(value.unreadMessagesCount.validate());
      storyActions = value.storyActions.validate();
    }).catchError(onError);
  }

  Future<void> getReactionsList() async {
    await getReactions().then((value) {
      reactions = value;
      log('Reactions: ${reactions.length}');
    }).catchError((e) {
      log('Error: ${e.toString()}');
    });

    log('Reactions: ${reactions.length}');

    setState(() {});
  }

  Future<void> defaultReactionsList() async {
    await getDefaultReaction().then((value) {
      if (value.isNotEmpty) {
        appStore.setDefaultReaction(value.first);
      } else {
        if (reactions.isNotEmpty) appStore.setDefaultReaction(reactions.first);
      }
    }).catchError((e) {
      log('Error: ${e.toString()}');
    });
    setState(() {});
  }

  Future<void> getUsersLevel() async {
    await getMembershipLevelForUser(userId: appStore.loginUserId.toInt()).then((value) {
      String? levelId;
      if (value != null) {
        MembershipModel membership = MembershipModel.fromJson(value);

        levelId = membership.id;
        setState(() {});
        pmpStore.setPmpMembership(levelId.validate());
      }

      setRestrictions(levelId: levelId);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      onWillPop: () {
        if (selectedIndex != 0) {
          selectedIndex = 0;
          tabController.index = 0;
          setState(() {});
          return Future.value(true);
        }
        return Future.value(true);
      },
      child: RefreshIndicator(
        onRefresh: () {
          if (tabController.index == 0) {
            LiveStream().emit(GetUserStories);
            LiveStream().emit(OnAddPost);
          } else if (tabController.index == 1) {
            LiveStream().emit(RefreshForumsFragment);
          } else if (tabController.index == 3) {
            LiveStream().emit(RefreshNotifications);
          } else if (tabController.index == 4) {
            LiveStream().emit(OnAddPostProfile);
          }
          return Future.value(true);
        },
        color: context.primaryColor,
        child: Scaffold(
          body: CustomScrollView(
            controller: _controller,
            slivers: <Widget>[
              Theme(
                data: ThemeData(useMaterial3: false),
                child: SliverAppBar(
                  forceElevated: true,
                  elevation: 0.5,
                  expandedHeight: 110,
                  floating: true,
                  pinned: true,
                  backgroundColor: context.scaffoldBackgroundColor,
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Image.asset(APP_ICON, width: 26),
                      Image.asset(APP_ICON, width: 46),
                      // 4.width,
                      // Text(APP_NAME, style: boldTextStyle(color: context.primaryColor, size: 24, fontFamily: fontFamily)),
                    ],
                  ),
                  actions: [
                    IconButton(
                      onPressed: () {
                        AddPostScreen().launch(context).then((value) {
                          if (value ?? false) {
                            selectedIndex = 0;
                            tabController.index = 0;
                            setState(() {});
                          }
                        });
                      },
                      highlightColor: Colors.transparent,
                      splashColor: Colors.transparent,
                      icon: Image.asset(ic_plus, height: 22, width: 22, fit: BoxFit.fitWidth, color: context.iconColor),
                    ),
                    if (appStore.showShop)
                      Image.asset(ic_bag, height: 24, width: 24, fit: BoxFit.fitWidth, color: context.iconColor).onTap(() {
                        ShopScreen().launch(context);
                      }, splashColor: Colors.transparent, highlightColor: Colors.transparent).paddingSymmetric(horizontal: 8),
                    Observer(
                      builder: (_) => IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: () {
                          showModalBottomSheet(
                            elevation: 0,
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            transitionAnimationController: _animationController,
                            builder: (context) {
                              return FractionallySizedBox(
                                heightFactor: 0.93,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 45,
                                      height: 5,
                                      //clipBehavior: Clip.hardEdge,
                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                                    ),
                                    8.height,
                                    Container(
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      decoration: BoxDecoration(
                                        color: context.cardColor,
                                        borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                      ),
                                      child: UserDetailBottomSheetWidget(
                                        callback: () {
                                          //mPage = 1;
                                          //future = getPostList();
                                        },
                                      ),
                                    ).expand(),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        icon: cachedImage(appStore.loginAvatarUrl, height: 30, width: 30, fit: BoxFit.cover).cornerRadiusWithClipRRect(15),
                      ),
                    ),
                  ],
                  bottom: TabBar(
                    indicatorColor: context.primaryColor,
                    controller: tabController,
                    onTap: (val) async {
                      selectedIndex = val;
                      setState(() {});
                    },
                    tabs: [
                      Tooltip(
                        richMessage: TextSpan(text: language.home, style: secondaryTextStyle(color: Colors.white)),
                        // child: Image.asset(
                        //   selectedIndex == 0 ? ic_home_selected : ic_home,
                        //   height: 24,
                        //   width: 24,
                        //   fit: BoxFit.cover,
                        //   color: selectedIndex == 0 ? context.primaryColor : context.iconColor,
                        // ).paddingSymmetric(vertical: 11),
                        child: Icon(Octicons.globe, size: 24, color: selectedIndex == 0 ? context.primaryColor : context.iconColor,),
                      ),
                      // Tooltip(
                      //   richMessage: TextSpan(text: language.searchHere, style: secondaryTextStyle(color: Colors.white)),
                      //   child: Image.asset(
                      //     selectedIndex == 1 ? ic_search_selected : ic_search,
                      //     height: 24,
                      //     width: 24,
                      //     fit: BoxFit.cover,
                      //     color: selectedIndex == 1 ? context.primaryColor : context.iconColor,
                      //   ).paddingSymmetric(vertical: 11),
                      // ),
                      Tooltip(
                        richMessage: TextSpan(text: language.forums, style: secondaryTextStyle(color: Colors.white)),
                        // child: Image.asset(
                        //   selectedIndex == 2 ? ic_three_user_filled : ic_three_user,
                        //   height: 28,
                        //   width: 28,
                        //   fit: BoxFit.fill,
                        //   color: selectedIndex == 2 ? context.primaryColor : context.iconColor,
                        // ).paddingSymmetric(vertical: 9),
                        child: Icon(Icons.record_voice_over, size: 24, color: selectedIndex == 1 ? context.primaryColor : context.iconColor,),
                      ),
                      Tooltip(
                        richMessage: TextSpan(text: 'custom', style: secondaryTextStyle(color: Colors.white)),
                        child: Icon(Elusive.leaf, size: 24, color: selectedIndex == 2 ? context.primaryColor : context.iconColor,),
                      ),
                      Tooltip(
                        richMessage: TextSpan(text: language.notifications, style: secondaryTextStyle(color: Colors.white)),
                        child: selectedIndex == 3
                            ? Image.asset(ic_notification_selected, height: 24, width: 24, fit: BoxFit.cover).paddingSymmetric(vertical: 11)
                            : Observer(
                                builder: (_) => Stack(
                                  clipBehavior: Clip.none,
                                  alignment: Alignment.center,
                                  children: [
                                    Image.asset(
                                      ic_notification,
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.cover,
                                      color: context.iconColor,
                                    ).paddingSymmetric(vertical: 11),
                                    if (appStore.notificationCount != 0)
                                      Positioned(
                                        right: appStore.notificationCount.toString().length > 1 ? -6 : -4,
                                        top: 3,
                                        child: Container(
                                          padding: EdgeInsets.all(appStore.notificationCount.toString().length > 1 ? 4 : 6),
                                          decoration: BoxDecoration(color: appColorPrimary, shape: BoxShape.circle),
                                          child: Text(
                                            appStore.notificationCount.toString(),
                                            style: boldTextStyle(color: Colors.white, size: 10, weight: FontWeight.w700, letterSpacing: 0.7),
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                      ),
                      Tooltip(
                        richMessage: TextSpan(
                            text: language.profile,
                            style: secondaryTextStyle(
                              color: Colors.white,
                            )),
                        child: Image.asset(
                          selectedIndex == 4? ic_profile_filled : ic_profile,
                          height: 24,
                          width: 24,
                          fit: BoxFit.cover,
                          color: selectedIndex == 3 ? context.primaryColor : context.iconColor,
                        ).paddingSymmetric(vertical: 11),
                      ),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    return appFragments[tabController.index];
                  },
                  childCount: 1,
                ),
              ),
            ],
          ),
          floatingActionButton: tabController.index == 4
              ? FloatingActionButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      elevation: 0,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      transitionAnimationController: _animationController,
                      builder: (context) {
                        return FractionallySizedBox(
                          heightFactor: 0.7,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 45,
                                height: 5,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), color: Colors.white),
                              ),
                              8.height,
                              Container(
                                padding: EdgeInsets.all(16),
                                width: context.width(),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                ),
                                child: LatestActivityComponent(),
                              ).expand(),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: cachedImage(ic_history, width: 26, height: 26, fit: BoxFit.cover, color: Colors.white),
                  backgroundColor: context.primaryColor,
                )
              : Observer(
                  builder: (_) => Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          if (pmpStore.privateMessaging) {
                            messageStore.setMessageCount(0);
                            MessageScreen().launch(context);
                          } else {
                            MembershipPlansScreen().launch(context);
                          }
                        },
                        child: cachedImage(ic_chat, width: 26, height: 26, fit: BoxFit.cover, color: Colors.white),
                        backgroundColor: context.primaryColor,
                      ),
                      if (messageStore.messageCount != 0)
                        Positioned(
                          left: messageStore.messageCount.toString().length > 1 ? -6 : -4,
                          top: -5,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(color: blueTickColor, shape: BoxShape.circle),
                            child: Text(
                              messageStore.messageCount.toString(),
                              style: boldTextStyle(color: Colors.white, size: 10, weight: FontWeight.w700, letterSpacing: 0.7),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
