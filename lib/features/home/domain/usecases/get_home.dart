import '../../data/models/home_model.dart';
import '../repositories/home_repository.dart';

class GetHome {
  const GetHome(this.repository);

  final HomeRepository repository;

  Future<HomeModel> call() {
    return repository.getHome();
  }
}