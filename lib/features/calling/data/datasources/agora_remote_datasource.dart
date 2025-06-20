// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:agora_rtm/agora_rtm.dart';
//
// import '../../../../core/config/agora_config.dart'; // Make sure this path is correct
//
// abstract class AgoraRemoteDataSource {
//   Future<void> initializeRtcEngine();
//   // Changed joinChannel signature to remove 'options'
//   Future<void> joinChannel(
//       String channelId, int uid, String info, bool isVideoCall);
//   Future<void> leaveChannel();
//   Future<void> disposeRtcEngine();
//   Future<void> toggleMic(bool mute);
//   Future<void> toggleCamera(bool disable);
//   Future<void> switchCamera();
//   RtcEngine? get rtcEngineInstance; // Add this getter
//
//   // Methods to set up event handlers
//   void setRtcEngineEventHandler({
//     required Function(RtcConnection connection, int remoteUid, int elapsed)
//         onUserJoined,
//     required Function(RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason)
//         onUserOffline,
//     required Function(RtcConnection connection, ConnectionStateType state,
//             ConnectionChangedReasonType reason)
//         onConnectionStateChanged,
//     required Function(RtcConnection connection, RtcStats stats) onRtcStats,
//     required Function(RtcConnection connection, int elapsed)
//         onJoinChannelSuccess,
//     required Function(RtcConnection connection, RtcStats stats) onLeaveChannel,
//   });
//
//   // RTM methods (optional, for call signaling/invitations)
//   Future<AgoraRtmClient?> initializeRtmClient(String uid);
//   Future<void> loginRtmClient(
//       AgoraRtmClient client, String? token, String userId);
//   Future<void> logoutRtmClient(AgoraRtmClient client);
//   Future<void> sendChannelMessage(
//       AgoraRtmClient client, String channelId, String message);
// }
//
// class AgoraRemoteDataSourceImpl implements AgoraRemoteDataSource {
//   RtcEngine? _engine;
//   AgoraRtmClient? _rtmClient;
//   bool _rtcInitialized = false;
//
//   @override
//   Future<void> initializeRtcEngine() async {
//     if (_rtcInitialized && _engine != null) {
//       return; // Already initialized
//     }
//     _engine = createAgoraRtcEngine();
//     await _engine!.initialize(const RtcEngineContext(
//       appId: AgoraConfig.appId,
//       // channelProfile: ChannelProfileType.channelProfileLiveBroadcasting, // Keep this if allowed by RtcEngineContext in your version
//     ));
//     // Important: For older versions that don't take channelProfile in RtcEngineContext
//     // or options in joinChannel, you might need to set it like this:
//     await _engine!.setChannelProfile(ChannelProfileType
//         .channelProfileCommunication); // <-- Set channel profile here
//
//     await _engine!.enableVideo(); // Enable video by default
//     await _engine!.startPreview(); // Start local video preview
//     _rtcInitialized = true;
//     print('Agora RTC Engine initialized successfully.');
//   }
//
//   @override
//   Future<AgoraRtmClient?> initializeRtmClient(String uid) async {
//     _rtmClient = await AgoraRtmClient.createInstance(AgoraConfig.appId);
//     print('Agora RTM Client created.');
//     return _rtmClient;
//   }
//
//   @override
//   Future<void> loginRtmClient(
//       AgoraRtmClient client, String? token, String userId) async {
//     await client.login(token, userId);
//     print('Agora RTM Client logged in as $userId.');
//   }
//
//   @override
//   Future<void> logoutRtmClient(AgoraRtmClient client) async {
//     await client.logout();
//     print('Agora RTM Client logged out.');
//   }
//
//   @override
//   // Adjusted joinChannel signature and implementation
//   Future<void> joinChannel(
//       String channelId, int uid, String info, bool isVideoCall) async {
//     if (_engine == null) {
//       throw Exception('RTC Engine not initialized.');
//     }
//
//     if (!isVideoCall) {
//       await _engine!.disableVideo();
//       await _engine!.enableAudio();
//     } else {
//       await _engine!.enableVideo();
//       await _engine!.enableAudio();
//     }
//
//     // Set client role before joining the channel
//     await _engine!.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
//
//     // Join the channel - strictly adhering to the provided signature
//     await _engine!.joinChannel(
//       token: AgoraConfig
//           .appId, // For testing, replace with actual token in production
//       channelId: channelId,
//       info: info,
//       uid: uid,
//       // Removed the 'options' parameter entirely as it's not in your signature
//     );
//     print('Joined channel: $channelId with UID: $uid');
//   }
//
//   @override
//   Future<void> leaveChannel() async {
//     if (_engine != null) {
//       await _engine!.leaveChannel();
//       print('Left channel.');
//     }
//   }
//
//   @override
//   Future<void> disposeRtcEngine() async {
//     if (_engine != null) {
//       await _engine!.release();
//       _engine = null;
//       _rtcInitialized = false;
//       print('Agora RTC Engine disposed.');
//     }
//   }
//
//   @override
//   Future<void> toggleMic(bool mute) async {
//     if (_engine != null) {
//       await _engine!.muteLocalAudioStream(mute);
//       print('Mic muted: $mute');
//     }
//   }
//
//   @override
//   Future<void> toggleCamera(bool disable) async {
//     if (_engine != null) {
//       await _engine!.enableLocalVideo(
//           !disable); // enableLocalVideo takes true to enable, false to disable
//       print('Camera disabled: $disable');
//     }
//   }
//
//   @override
//   Future<void> switchCamera() async {
//     if (_engine != null) {
//       await _engine!.switchCamera();
//       print('Camera switched.');
//     }
//   }
//
//   @override
//   void setRtcEngineEventHandler({
//     required Function(RtcConnection connection, int remoteUid, int elapsed)
//         onUserJoined,
//     required Function(RtcConnection connection, int remoteUid,
//             UserOfflineReasonType reason)
//         onUserOffline,
//     required Function(RtcConnection connection, ConnectionStateType state,
//             ConnectionChangedReasonType reason)
//         onConnectionStateChanged,
//     required Function(RtcConnection connection, RtcStats stats) onRtcStats,
//     required Function(RtcConnection connection, int elapsed)
//         onJoinChannelSuccess,
//     required Function(RtcConnection connection, RtcStats stats) onLeaveChannel,
//   }) {
//     _engine?.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: onJoinChannelSuccess,
//         onUserJoined: onUserJoined,
//         onUserOffline: onUserOffline,
//         onConnectionStateChanged: onConnectionStateChanged,
//         onLeaveChannel: onLeaveChannel,
//         onRtcStats: onRtcStats,
//       ),
//     );
//     print('Agora RTC Engine event handlers set.');
//   }
//
//   @override
//   Future<void> sendChannelMessage(
//       AgoraRtmClient client, String channelId, String message) {
//     throw UnimplementedError(
//         'sendChannelMessage not yet implemented for direct AgoraRtmClient use.');
//   }
//
//   @override
//   RtcEngine? get rtcEngineInstance => _engine;
// }
