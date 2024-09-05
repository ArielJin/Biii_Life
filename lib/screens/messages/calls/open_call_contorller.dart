import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/models/calls/call_model.dart';
import 'package:Biii_Life/screens/messages/calls/pickup_screen.dart';

class OpenCallController {
  StreamController<CallModel> searchStream = StreamController<CallModel>();

  void initializeStream(BuildContext context) {
    searchStream.stream.listen(
      (call) {
        log('call.hasDialed.validate() - ${call.hasDialed.validate()}');
        if (!call.hasDialed.validate()) {
          navigatorKey.currentState!.push(
            MaterialPageRoute(builder: (context) {
              return PickUpScreen(callModel: call);
            }),
          );
        }
      },
    );
  }

  void closeStream() {
    searchStream.close();
  }
}
