import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/utils/app_constants.dart';

import '../../utils/images.dart';
import 'app_web.dart';

class DonateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _DonateScreenState();

}

class _DonateScreenState extends State<DonateScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Donate", style: boldTextStyle(size: 20)),
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
        children: [
          Positioned(child: Image.asset(donate_now_image, fit: BoxFit.cover, width: double.infinity, height: double.infinity,)),
          Positioned(
              top: 40,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Text('SUPPORT OUR CAUSE', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                  SizedBox(height: 20,),
                  Text('Our goals are committed to providing a transparent social platform focused on a positive outlook for humanity and our future with planet earth.', style: TextStyle(color: Colors.white, fontSize: 15),),
                  SizedBox(height: 40,),
                  MaterialButton(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: 50.0,
                    minWidth: 150.0,
                    color: appColorPrimary,
                    child: Text(
                      'Donate now',
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (ctx) => AppWebScreen(title: 'Donate now', selectedUrl: "https://www.paypal.com/donate/?hosted_button_id=KMSJM9NT5R3RE")));
                    },

                  ),
                  SizedBox(height: 30,),
                  Text('THANK YOU FOR YOUR SUPPORT. BIII.INC', style: TextStyle(color: Colors.white, fontSize: 15),),

                ],
              ))
        ],
      ),
    );
  }

}