// lib/features/calling/domain/repositories/call_repository.dart

abstract class CallRepository {
  Future<void> initCallEngine();
  Future<void> startCall(String channelId, int localUid, bool isVideoCall);
  Future<void> endCall();
  Future<void> toggleMic(bool mute);
  Future<void> toggleCamera(bool disable);
  Future<void> switchCamera();

  // Stream of events to be exposed to the BLoC
  Stream<Map<String, dynamic>> get callEvents;
}
