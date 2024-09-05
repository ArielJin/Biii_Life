import 'package:Biii_Life/models/gamipress/common_gamipress_model.dart';
import 'package:Biii_Life/models/gamipress/rewards_model.dart';
import 'package:Biii_Life/network/network_utils.dart';
import 'package:Biii_Life/utils/app_constants.dart';

Future<List<CommonGamiPressModel>> badgesList({int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.badges}?page=$page&per_page=$PER_PAGE', method: HttpMethod.GET));
  return it.map((e) => CommonGamiPressModel.fromJson(e)).toList();
}

Future<List<CommonGamiPressModel>> levelsList({int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.levels}?page=$page&per_page=$PER_PAGE', method: HttpMethod.GET));
  return it.map((e) => CommonGamiPressModel.fromJson(e)).toList();
}

Future<RewardsModel> rewards({required int userID}) async {
  return RewardsModel.fromJson(await handleResponse(await buildHttpResponse('${APIEndPoint.userEarnings}?user_id=$userID')));
}

Future<List<Rank>> userAchievements({required int userID, int page = 1}) async {
  Iterable it = await handleResponse(await buildHttpResponse('${APIEndPoint.userAchievements}?user_id=$userID&page=$page&per_page=$PER_PAGE', method: HttpMethod.GET));
  return it.map((e) => Rank.fromJson(e)).toList();
}
