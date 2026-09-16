import '../../data/models/home_model.dart';

abstract class HomeRepository {
  Future<HomeModel> getHome();
}