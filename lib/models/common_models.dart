import 'dart:io';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/screens/blog/screens/blog_list_screen.dart';
import 'package:Biii_Life/screens/custom/app_web.dart';
import 'package:Biii_Life/screens/forums/screens/my_forums_screen.dart';
import 'package:Biii_Life/screens/gamipress/screens/badge_list_screen.dart';
import 'package:Biii_Life/screens/gamipress/screens/levels_screen.dart';
import 'package:Biii_Life/screens/groups/screens/group_screen.dart';
import 'package:Biii_Life/screens/lms/screens/course_list_screen.dart';
import 'package:Biii_Life/screens/membership/screens/membership_plans_screen.dart';
import 'package:Biii_Life/screens/membership/screens/my_membership_screen.dart';
import 'package:Biii_Life/screens/messages/components/friends_tab_component.dart';
import 'package:Biii_Life/screens/messages/components/group_tab_component.dart';
import 'package:Biii_Life/screens/messages/components/messages_tab_component.dart';
import 'package:Biii_Life/screens/profile/screens/profile_friends_screen.dart';
import 'package:Biii_Life/screens/settings/screens/settings_screen.dart';
import 'package:Biii_Life/screens/shop/screens/cart_screen.dart';
import 'package:Biii_Life/screens/shop/screens/orders_screen.dart';
import 'package:Biii_Life/screens/shop/screens/shop_screen.dart';
import 'package:Biii_Life/screens/shop/screens/wishlist_screen.dart';
import 'package:Biii_Life/screens/stories/screen/user_story_screen.dart';

import '../screens/lms/screens/cource_orders_screen.dart';
import '../utils/app_constants.dart';

class DrawerModel {
  String? title;
  String? image;
  Widget? attachedScreen;
  bool isNew;

  DrawerModel({this.image, this.title, this.attachedScreen, this.isNew = false});
}

List<DrawerModel> getDrawerOptions() {
  List<DrawerModel> list = [];

  // list.add(DrawerModel(
  //   image: ic_story,
  //   title: language.myStories,
  //   attachedScreen: UserStoryScreen(),
  // ));
  if (appStore.showMemberShip)
    list.add(DrawerModel(
      image: ic_ticket_star,
      title: language.membership,
      attachedScreen: MyMembershipScreen(),
    ));
  list.add(DrawerModel(
    image: ic_two_user,
    title: language.friends,
    attachedScreen: ProfileFriendsScreen(),
  ));
  list.add(DrawerModel(
    image: ic_three_user,
    title: language.groups,
    attachedScreen: pmpStore.viewGroups ? GroupScreen() : MembershipPlansScreen(),
  ));
  // if(appStore.showForums)list.add(DrawerModel(
  //   image: ic_document,
  //   title: language.forums,
  //   attachedScreen: MyForumsScreen(),
  // ));
  if (appStore.showBlogs)
    list.add(DrawerModel(
      image: ic_blog,
      title: language.blogs,
      attachedScreen: BlogListScreen(),
    ));
  if (appStore.showGamiPress) {
    list.add(DrawerModel(
      image: ic_shield_done,
      title: language.badges,
      attachedScreen: BadgeListScreen(),
      isNew: true,
    ));
    list.add(DrawerModel(
      image: ic_game,
      title: language.levels,
      attachedScreen: LevelsScreen(),
      isNew: true,
    ));
  }

  if (appStore.showLearnPress) {
    list.add(DrawerModel(
      image: ic_book,
      title: language.courses,
      attachedScreen: CourseListScreen(),
    ));
    list.add(DrawerModel(
      image: ic_books,
      title: language.courseOrders,
      attachedScreen: CourseOrdersScreen(),
    ));
  }

  if (appStore.showShop) {
    list.add(DrawerModel(
      image: ic_store,
      title: language.shop,
      attachedScreen: ShopScreen(),
    ));
    list.add(DrawerModel(
      image: ic_buy,
      title: language.cart,
      attachedScreen: CartScreen(isFromHome: true),
    ));
    list.add(DrawerModel(
      image: ic_heart,
      title: language.wishlist,
      attachedScreen: WishlistScreen(),
    ));
    list.add(DrawerModel(
      image: ic_bag,
      title: language.myOrders,
      attachedScreen: OrdersScreen(),
    ));
  }
  list.add(DrawerModel(
    image: ic_bag,
    title: 'Biii B2B',
    attachedScreen: AppWebScreen(title: 'Biii B2B', selectedUrl: 'https://biii-b2b.com/'),
  ));

  list.add(DrawerModel(
    image: ic_setting,
    title: language.settings,
    attachedScreen: SettingsScreen(),
  ));
  return list;
}

List<DrawerModel> getCourseTabs() {
  List<DrawerModel> list = [];

  list.add(DrawerModel(title: language.theCourseIncludes));
  list.add(DrawerModel(title: language.overview));
  list.add(DrawerModel(title: language.curriculum));
  list.add(DrawerModel(title: language.instructor));
  list.add(DrawerModel(title: language.faqs));
  list.add(DrawerModel(title: language.reviews));

  return list;
}

List<DrawerModel> messageTabs() {
  List<DrawerModel> list = [];
  list.add(DrawerModel(title: language.messages, image: ic_chat, attachedScreen: MessagesTabComponent()));
  list.add(DrawerModel(title: language.friends, image: ic_two_user, attachedScreen: FriendsTabComponent()));
  list.add(DrawerModel(title: language.groups, image: ic_three_user, attachedScreen: GroupTabComponent()));

  return list;
}

class FilterModel {
  String? title;
  String? value;

  FilterModel({this.value, this.title});
}

List<FilterModel> getProductFilters() {
  List<FilterModel> list = [];

  list.add(FilterModel(value: ProductFilters.date, title: language.latest));
  list.add(FilterModel(value: ProductFilters.rating, title: language.averageRating));
  list.add(FilterModel(value: ProductFilters.popularity, title: language.popularity));
  list.add(FilterModel(value: ProductFilters.price, title: language.price));

  return list;
}

List<FilterModel> getOrderStatus() {
  List<FilterModel> list = [];

  list.add(FilterModel(value: OrderStatus.any, title: language.any));
  list.add(FilterModel(value: OrderStatus.pending, title: language.pending));
  list.add(FilterModel(value: OrderStatus.processing, title: language.processing));
  list.add(FilterModel(value: OrderStatus.onHold, title: language.onHold));
  list.add(FilterModel(value: OrderStatus.completed, title: language.completed));
  list.add(FilterModel(value: OrderStatus.cancelled, title: language.cancelled));
  list.add(FilterModel(value: OrderStatus.refunded, title: language.refunded));
  list.add(FilterModel(value: OrderStatus.failed, title: language.failed));
  list.add(FilterModel(value: OrderStatus.trash, title: language.trash));

  return list;
}

class PostMedia {
  File? file;
  String? link;
  bool isLink;

  PostMedia({this.file, this.link, this.isLink = false});
}

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 1, name: 'English', subTitle: 'English', languageCode: 'en', fullLanguageCode: 'en_en-US', flag: 'assets/flag/ic_us.png'),
    LanguageDataModel(id: 2, name: 'Hindi', subTitle: 'हिंदी', languageCode: 'hi', fullLanguageCode: 'hi_hi-IN', flag: 'assets/flag/ic_hi.png'),
    LanguageDataModel(id: 3, name: 'Arabic', subTitle: 'عربي', languageCode: 'ar', fullLanguageCode: 'ar_ar-AR', flag: 'assets/flag/ic_ar.png'),
    LanguageDataModel(id: 4, name: 'French', subTitle: 'français', languageCode: 'fr', fullLanguageCode: 'fr_fr-FR', flag: 'assets/flag/ic_fr.png'),
    LanguageDataModel(id: 5, name: 'Spanish', subTitle: 'español', languageCode: 'es', fullLanguageCode: 'es_es-ES', flag: 'assets/flag/ic_es.png'),
    LanguageDataModel(id: 6, name: 'German', subTitle: 'Deutsch', languageCode: 'de', fullLanguageCode: 'de_de-De', flag: 'assets/flag/ic_de.png'),
    LanguageDataModel(id: 7, name: 'Portuguese', subTitle: 'Português', languageCode: 'pt', fullLanguageCode: 'pt_pt-PT', flag: 'assets/flag/ic_pt.jpg'),
  ];
}
