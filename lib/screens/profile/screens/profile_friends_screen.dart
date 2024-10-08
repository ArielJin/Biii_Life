import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/screens/profile/components/friends_component.dart';
import 'package:Biii_Life/screens/profile/components/request_sent_component.dart';
import 'package:Biii_Life/screens/profile/components/requests_received_component.dart';

import '../../../utils/app_constants.dart';

class ProfileFriendsScreen extends StatefulWidget {
  @override
  State<ProfileFriendsScreen> createState() => _ProfileFriendsScreenState();
}

class _ProfileFriendsScreenState extends State<ProfileFriendsScreen> with SingleTickerProviderStateMixin {
  late TabController tabController;

  bool isCallback = false;

  @override
  void initState() {
    setStatusBarColor(Colors.transparent);
    super.initState();
    tabController = TabController(length: 3, vsync: this);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (appStore.isLoading) appStore.setLoading(true);
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        appStore.setLoading(false);

        finish(context, isCallback);
        return Future.value(true);
      },
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(language.friends, style: boldTextStyle(size: 20)),
            elevation: 0,
            centerTitle: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: context.primaryColor,
                  borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius),
                ),
                padding: EdgeInsets.fromLTRB(22, 12, 22, 0),
                child: TabBar(
                  unselectedLabelColor: Colors.white54,
                  labelColor: Colors.white,
                  labelStyle: boldTextStyle(),
                  unselectedLabelStyle: primaryTextStyle(),
                  controller: tabController,
                  indicatorSize: TabBarIndicatorSize.label,
                  indicator: TabIndicator(),
                  tabs: [
                    FittedBox(child: Text(language.friends, style: boldTextStyle(color: Colors.white)).paddingSymmetric(vertical: 12)),
                    FittedBox(child: Text(language.sent, style: boldTextStyle(color: Colors.white)).paddingSymmetric(vertical: 12)),
                    FittedBox(child: Text(language.requests, style: boldTextStyle(color: Colors.white)).paddingSymmetric(vertical: 12)),
                  ],
                ),
              ),
              Container(
                color: context.primaryColor,
                child: TabBarView(
                  controller: tabController,
                  children: [
                    FriendsComponent(
                      callback: () {
                        isCallback = true;
                      },
                    ),
                    RequestSentComponent(),
                    RequestsReceivedComponent(),
                  ],
                ),
              ).expand(),
            ],
          ),
        ),
      ),
    );
  }
}
