import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:Biii_Life/models/gamipress/rewards_model.dart';
import 'package:Biii_Life/utils/app_constants.dart';
import 'package:Biii_Life/utils/cached_network_image.dart';

class PointsComponent extends StatelessWidget {
  final List<Points> pointsList;
  const PointsComponent({required this.pointsList});

  @override
  Widget build(BuildContext context) {
    return AnimatedListView(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(16),
      itemCount: pointsList.length,
      itemBuilder: (ctx, index) {
        Points data = pointsList[index];
        return Row(
          children: [
            if (data.image.validate().isNotEmpty) cachedImage(data.image.validate(), height: 50, width: 50, fit: BoxFit.cover),
            16.width,
            Text('${data.earnings} ${parseHtmlString(data.pluralName.validate())}', style: primaryTextStyle()),
          ],
        ).paddingSymmetric(vertical: 8);
      },
    );
  }
}
