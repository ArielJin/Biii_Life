import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/main.dart';
import 'package:Biii_Life/models/common_models/wp_embedded_model.dart';
import 'package:Biii_Life/models/posts/wp_post_response.dart';
import 'package:Biii_Life/screens/blog/screens/blog_detail_screen.dart';
import 'package:Biii_Life/screens/membership/screens/membership_plans_screen.dart';
import 'package:Biii_Life/utils/app_constants.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

class BlogCardComponent extends StatefulWidget {
  final WpPostResponse data;

  BlogCardComponent({required this.data});

  @override
  State<BlogCardComponent> createState() => _BlogCardComponentState();
}

class _BlogCardComponentState extends State<BlogCardComponent> {
  List<String> tags = [];
  String category = '';

  @override
  void initState() {
    super.initState();

    getTags();
  }

  void getTags() {
    widget.data.embedded!.wpTerms!.forEach((element) {
      element.forEach((e) {
        WpTermsModel terms = WpTermsModel.fromJson(e);
        if (terms.taxonomy.validate() == 'category') {
          category = terms.name.validate();
        } else if (terms.taxonomy.validate() == 'post_tag') {
          tags.add(terms.name.validate());
        }
      });
    });

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        if (widget.data.is_restricted.validate()) {
          MembershipPlansScreen().launch(context);
        } else {
          BlogDetailScreen(blogId: widget.data.id.validate(), data: widget.data).launch(context);
        }
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: context.cardColor, borderRadius: radius(commonRadius)),
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.data.embedded != null)
              RichText(
                text: TextSpan(
                  children: [
                    if (widget.data.embedded!.author!.first.name.validate().isNotEmpty) ...[
                      TextSpan(
                        text: widget.data.embedded!.author!.first.name.validate(),
                        style: secondaryTextStyle(size: 14, fontFamily: fontFamily),
                      ),
                      if (widget.data.embedded!.author!.first.is_user_verified.validate())
                        WidgetSpan(
                          child: Image.asset(ic_tick_filled, height: 16, width: 16, color: blueTickColor, fit: BoxFit.cover),
                        ),
                      TextSpan(text: '  |  ', style: secondaryTextStyle(size: 14, fontFamily: fontFamily)),
                    ],
                    TextSpan(text: '${convertToAgo(widget.data.date.validate())}  |', style: secondaryTextStyle(size: 14, fontFamily: fontFamily)),
                    TextSpan(text: '  $category', style: secondaryTextStyle(size: 14, fontFamily: fontFamily, color: context.primaryColor))
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.start,
              ),
            16.height,
            Text(parseHtmlString(widget.data.title!.rendered.validate()), style: boldTextStyle()),
            16.height,
            Text(parseHtmlString(widget.data.excerpt!.rendered.validate()), style: secondaryTextStyle(size: 16)),
            if (widget.data.embedded != null && widget.data.embedded!.featuredMedia != null)
              cachedImage(widget.data.embedded!.featuredMedia!.first.source_url.validate()).cornerRadiusWithClipRRect(commonRadius),
            if (tags.isNotEmpty)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${language.tags}: ', style: boldTextStyle(size: 14)),
                  Wrap(
                    children: tags.map((e) {
                      return Text('$e, ', style: secondaryTextStyle());
                    }).toList(),
                  ).expand(),
                ],
              ).paddingTop(16),
          ],
        ),
      ),
    );
  }
}
