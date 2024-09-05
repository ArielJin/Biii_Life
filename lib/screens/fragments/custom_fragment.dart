
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utils/images.dart';
import '../blog/screens/blog_list_screen.dart';
import '../custom/donate_screen.dart';
import '../dashboard_screen.dart';

class CustomFragment extends StatefulWidget {
  final ScrollController? controller;

  const CustomFragment({this.controller});

  @override
  State<StatefulWidget> createState() => _CustomFragmentState();

}

class _CustomFragmentState extends State<CustomFragment> {

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(() {
      if (selectedIndex == 2) {
        if (widget.controller?.position.pixels == widget.controller?.position.maxScrollExtent) {
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        16.height,
        Row(
          children: [
            16.width,
            Expanded(
                child: GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFBA7A), // 容器填充颜色
                      borderRadius: BorderRadius.circular(10), // 设置圆角半径
                    ),
                    child: Stack(
                      children: [
                        Text('Blog', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),).paddingSymmetric(vertical: 20, horizontal: 20),
                        Positioned(
                          bottom: 10,
                            left: 0,
                            right: 0,
                            child: Image.asset(ic_blog_a, width: 100, height: 100,)
                        ),
                      ],
                    ),
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => BlogListScreen()));
                  },
                )
            ),
            16.width,
            Expanded(
                child: GestureDetector(
                  child: Container(
                    width: double.infinity,
                    height: 190,
                    decoration: BoxDecoration(
                      color: Color(0xFF85C9FF), // 容器填充颜色
                      borderRadius: BorderRadius.circular(10), // 设置圆角半径
                    ),
                    child: Stack(
                      children: [
                        Text('Creat\nNew Blog', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),).paddingSymmetric(vertical: 20, horizontal: 20),
                        Positioned(
                            bottom: 10,
                            left: 0,
                            right: 0,
                            child: Image.asset(ic_create_blog, width: 100, height: 100,)
                        ),
                      ],
                    )
                  ),
                  onTap: () async {
                    await _launchUrl('https://biii.life/create-new/');
                    // Navigator.push(context, MaterialPageRoute(builder: (ctx) => AppWebScreen(title: 'Creat New Blog', selectedUrl: "https://biii.life/create-new/")));
                  },
                )
            ),
            16.width,
          ],
        ),
        16.height,
        Row(
          children: [
            16.width,
            Expanded(child: GestureDetector(
              child: Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Color(0xFF2CE8C1), // 容器填充颜色
                  borderRadius: BorderRadius.circular(10), // 设置圆角半径
                ),
                child: Stack(
                  children: [
                    Text('Donate\nNow', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),).paddingSymmetric(vertical: 20, horizontal: 20),
                    Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Image.asset(ic_donate, width: 100, height: 100,)
                    ),
                  ],
                )

              ),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (ctx) => DonateScreen()));
              },
            )),
            16.width,
            Expanded(child: GestureDetector(
              child: Container(
                width: double.infinity,
                height: 190,
                decoration: BoxDecoration(
                  color: Color(0xFF5AF485), // 容器填充颜色
                  borderRadius: BorderRadius.circular(10), // 设置圆角半径
                ),
                child: Stack(
                  children: [
                    Text('Earth\nChampions', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),).paddingSymmetric(vertical: 20, horizontal: 20),
                    Positioned(
                        bottom: 10,
                        left: 0,
                        right: 0,
                        child: Image.asset(ic_earth_champion, width: 100, height: 100,)
                    ),
                  ],
                )
              ),
              onTap: () async {
                await _launchUrl('https://biii.life/earth-champions/');
                // Navigator.push(context, MaterialPageRoute(builder: (ctx) => AppWebScreen(title: 'Creat New Blog', selectedUrl: "https://biii.life/earth-champions/")));
              },
            )),
            16.width,
          ],
        )
      ],
    );
  }

  Future<void> _launchUrl(String url) async {
    final Uri _url = Uri.parse(url);
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

}