import 'package:cast/cast.dart';

class CastService {
  CastDiscoveryService service = CastDiscoveryService();

  Future<List<CastDevice>> searchCastDevices(Duration duration) async {
    List<CastDevice> list;

    list = await service.search();

    return list;
  }

  void connectToDevice(CastDevice device) async {
    CastSessionManager sessionManager = CastSessionManager();

    await sessionManager.startSession(device);
  }
}
