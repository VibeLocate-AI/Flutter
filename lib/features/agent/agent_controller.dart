import 'package:get/get.dart';

import 'data/datasources/agent_remote_data_source.dart';
import 'data/models/agent_property.dart';

class AgentController extends GetxController {
  AgentController({AgentRemoteDataSource? dataSource})
      : dataSource = dataSource ?? AgentRemoteDataSource();

  final AgentRemoteDataSource dataSource;

  final pending = <AgentProperty>[].obs;
  final approved = <AgentProperty>[].obs;
  final rejected = <AgentProperty>[].obs;
  final pois = <Map<String, dynamic>>[].obs;

  final isLoading = false.obs;
  final error = RxnString();
  final hasLoaded = false.obs;

  Future<void> load() async {
    if (isLoading.value) return;

    isLoading.value = true;
    error.value = null;
    try {
      final results = await Future.wait([
        dataSource.getProperties('pending'),
        dataSource.getProperties('approved'),
        dataSource.getProperties('rejected'),
        dataSource.getPois(),
      ]);

      pending.assignAll(results[0] as List<AgentProperty>);
      approved.assignAll(results[1] as List<AgentProperty>);
      rejected.assignAll(results[2] as List<AgentProperty>);
      pois.assignAll(results[3] as List<Map<String, dynamic>>);
      hasLoaded.value = true;
    } catch (e) {
      error.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createPoi(Map<String, dynamic> body) async {
    await dataSource.createPoi(body);
    await load();
  }

  Future<void> updatePoi(
    int id,
    Map<String, dynamic> body,
  ) async {
    await dataSource.updatePoi(id, body);
    await load();
  }

  Future<void> deletePoi(int id) async {
    await dataSource.deletePoi(id);
    pois.removeWhere((poi) {
      final poiId = int.tryParse((poi['id'] ?? '').toString());
      return poiId == id;
    });
    pois.refresh();
  }

  Future<void> submitLicense() => dataSource.submitLicense();

  Future<void> approve(int id) async {
    await dataSource.approveProperty(id);
    await load();
  }

  Future<void> reject(int id) async {
    await dataSource.rejectProperty(id);
    await load();
  }
}
