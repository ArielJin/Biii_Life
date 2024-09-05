import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/components/loading_widget.dart';
import 'package:Biii_Life/components/no_data_lottie_widget.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/forums/forum_model.dart';
import 'package:Biii_Life/network/rest_apis.dart';
import 'package:Biii_Life/screens/dashboard_screen.dart';
import 'package:Biii_Life/screens/forums/components/forums_card_component.dart';
import 'package:Biii_Life/screens/forums/screens/forum_detail_screen.dart';

import '../../../utils/app_constants.dart';

class ForumsFragment extends StatefulWidget {
  final ScrollController controller;

  const ForumsFragment({super.key, required this.controller});

  @override
  State<ForumsFragment> createState() => _ForumsFragment();
}

class _ForumsFragment extends State<ForumsFragment> {
  List<ForumModel> forumsList = [];
  late Future<List<ForumModel>> future;
  List<String> appForums = ["Animal", "Air", "Earth/Land", "Water", "Fire", "Human"];
  List<String> appForumsImg = [forum_animal_image, forum_air_image, forum_earth_land_image, forum_water_image, forum_fire_image, forum_human_image];


  TextEditingController searchController = TextEditingController();

  int mPage = 1;
  bool mIsLastPage = false;

  bool hasShowClearTextIcon = false;
  bool isError = false;

  @override
  void initState() {
    future = getForums();
    super.initState();

    widget.controller.addListener(() {
      /// pagination
      if (selectedIndex == 1) {
        if (widget.controller.position.pixels == widget.controller.position.maxScrollExtent) {
          if (!mIsLastPage) {
            mPage++;
            setState(() {});

            future = getForums();
          }
        }
      }
    });

    searchController.addListener(() {
      if (searchController.text.isNotEmpty) {
        showClearTextIcon();
      } else {
        hasShowClearTextIcon = false;
        setState(() {});
      }
    });

    LiveStream().on(RefreshForumsFragment, (p0) {
      appStore.setLoading(true);
      forumsList.clear();
      mPage = 1;
      setState(() {});
      future = getForums();
    });
  }

  void showClearTextIcon() {
    if (!hasShowClearTextIcon) {
      hasShowClearTextIcon = true;
      setState(() {});
    } else {
      return;
    }
  }

  Future<List<ForumModel>> getForums() async {
    appStore.setLoading(true);
    await getForumList(page: mPage, keyword: searchController.text).then((value) {
      if (mPage == 1) forumsList.clear();
      mIsLastPage = value.length != PER_PAGE;
      for (int i = 0; i < value.length; i++) {
        ForumModel forumModel = value[i];
        if ((forumModel.title??'') != '' && appForums.contains(forumModel.title!)) {
          forumsList.add(forumModel);
        }
      }
      forumsList.sort((a, b) =>appForums.indexOf(a.title!).compareTo(appForums.indexOf(b.title!)));
      // forumsList.addAll(value);
      setState(() {});

      appStore.setLoading(false);
    }).catchError((e) {
      isError = true;
      appStore.setLoading(false);
      toast(e.toString(), print: true);
    });

    return forumsList;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    searchController.dispose();
    LiveStream().dispose(RefreshForumsFragment);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        16.height,
        // Container(
        //   width: context.width() - 32,
        //   margin: EdgeInsets.only(left: 16, right: 8),
        //   decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
        //   child: AppTextField(
        //     controller: searchController,
        //     textFieldType: TextFieldType.USERNAME,
        //     onFieldSubmitted: (text) {
        //       mPage = 1;
        //       future = getForums();
        //     },
        //     decoration: InputDecoration(
        //       border: InputBorder.none,
        //       hintText: language.searchHere,
        //       hintStyle: secondaryTextStyle(),
        //       prefixIcon: Image.asset(
        //         ic_search,
        //         height: 16,
        //         width: 16,
        //         fit: BoxFit.cover,
        //         color: appStore.isDarkMode ? bodyDark : bodyWhite,
        //       ).paddingAll(16),
        //       suffixIcon: hasShowClearTextIcon
        //           ? IconButton(
        //               icon: Icon(Icons.cancel, color: appStore.isDarkMode ? bodyDark : bodyWhite, size: 18),
        //               onPressed: () {
        //                 hideKeyboard(context);
        //                 hasShowClearTextIcon = false;
        //                 searchController.clear();
        //
        //                 mPage = 1;
        //                 getForums();
        //                 setState(() {});
        //               },
        //             )
        //           : null,
        //     ),
        //   ),
        // ),
        Stack(
          alignment: Alignment.topCenter,
          children: [
            FutureBuilder<List<ForumModel>>(
              future: future,
              builder: (ctx, snap) {
                if (snap.hasError) {
                  return SizedBox(
                    height: context.height() * 0.5,
                    child: NoDataWidget(
                      imageWidget: NoDataLottieWidget(),
                      title: isError ? language.somethingWentWrong : language.noDataFound,
                      onRetry: () {
                        LiveStream().emit(RefreshForumsFragment);
                      },
                      retryText: '   ${language.clickToRefresh}   ',
                    ).center(),
                  );
                }

                if (snap.hasData) {
                  if (snap.data.validate().isEmpty) {
                    return SizedBox(
                      height: context.height() * 0.5,
                      child: NoDataWidget(
                        imageWidget: NoDataLottieWidget(),
                        title: isError ? language.somethingWentWrong : language.noDataFound,
                        onRetry: () {
                          LiveStream().emit(RefreshForumsFragment);
                        },
                        retryText: '   ${language.clickToRefresh}   ',
                      ).center(),
                    );
                  } else {
                    return AnimatedListView(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      slideConfiguration: SlideConfiguration(delay: 80.milliseconds, verticalOffset: 300),
                      padding: EdgeInsets.only(left: 16, right: 16, bottom: 50, top: 16),
                      itemCount: forumsList.length,
                      itemBuilder: (context, index) {
                        ForumModel data = forumsList[index];
                        return InkWell(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () {
                            ForumDetailScreen(
                              forumId: data.id.validate(),
                              type: data.type.validate(),
                            ).launch(context).then((value) {
                              if (value ?? false) {
                                mPage = 1;
                                future = getForums();
                              }
                            });
                          },
                          child: Stack(
                            children: [
                              Image.asset(appForumsImg[appForums.indexOf(data.title!)], width: double.infinity, fit: BoxFit.fitWidth,),
                              Positioned.fill(child: Container(
                                // color: Colors.black.withOpacity(0.5),
                                child: Center(
                                  child: Text(data.title!.toUpperCase(), style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800),),
                                ).paddingOnly(bottom: 100),
                              ))
                            ],
                          ),
                          // ForumsCardComponent(
                          //   title: data.title,
                          //   description: data.description,
                          //   postCount: data.postCount,
                          //   topicCount: data.topicCount,
                          //   freshness: data.freshness,
                          // ),
                        );
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
                  if (mPage != 1) {
                    return Positioned(
                      bottom: 10,
                      child: LoadingWidget(isBlurBackground: false),
                    );
                  } else {
                    return LoadingWidget(isBlurBackground: false).paddingTop(context.height() * 0.3);
                  }
                } else {
                  return Offstage();
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
