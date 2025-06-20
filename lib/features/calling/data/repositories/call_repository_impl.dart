// // lib/features/calling/data/repositories/call_repository_impl.dart
// import 'dart:async';
//
// import '../../domain/repositories/call_repository.dart';
// import '../datasources/agora_remote_datasource.dart';
//
// class CallRepositoryImpl implements CallRepository {
//   final AgoraRemoteDataSource remoteDataSource;
//   final StreamController<Map<String, dynamic>> _callEventsController =
//       StreamController.broadcast();
//
//   CallRepositoryImpl({required this.remoteDataSource}) {
//     _setupEventHandlers();
//   }
//
//   void _setupEventHandlers() {
//     remoteDataSource.setRtcEngineEventHandler(
//       onJoinChannelSuccess: (connection, elapsed) {
//         _callEventsController.add({
//           'type': 'joinChannelSuccess',
//           'connection': connection,
//           'elapsed': elapsed,
//         });
//         print(
//             'Repo: onJoinChannelSuccess - UID: ${connection.localUid}, Channel: ${connection.channelId}');
//       },
//       onUserJoined: (connection, remoteUid, elapsed) {
//         _callEventsController.add({
//           'type': 'userJoined',
//           'connection': connection,
//           'remoteUid': remoteUid,
//           'elapsed': elapsed,
//         });
//         print('Repo: Repo: onUserJoined - Remote UID: $remoteUid');
//       },
//       onUserOffline: (connection, remoteUid, reason) {
//         _callEventsController.add({
//           'type': 'userOffline',
//           'connection': connection,
//           'remoteUid': remoteUid,
//           'reason': reason,
//         });
//         print(
//             'Repo: Repo: onUserOffline - Remote UID: $remoteUid, Reason: $reason');
//       },
//       onConnectionStateChanged: (connection, state, reason) {
//         _callEventsController.add({
//           'type': 'connectionStateChanged',
//           'connection': connection,
//           'state': state,
//           'reason': reason,
//         });
//         print(
//             'Repo: Repo: onConnectionStateChanged - State: $state, Reason: $reason');
//       },
//       onLeaveChannel: (connection, stats) {
//         _callEventsController.add({
//           'type': 'leaveChannel',
//           'connection': connection,
//           'stats': stats,
//         });
//         print('Repo: Repo: onLeaveChannel');
//       },
//       onRtcStats: (connection, stats) {
//         // You can use this for monitoring call quality etc.
//         // For now, just print
//         // print('Repo: Repo: onRtcStats - CPU: ${stats.cpuAppUsage}');
//       },
//     );
//   }
//
//   @override
//   Future<void> initCallEngine() async {
//     await remoteDataSource.initializeRtcEngine();
//   }
//
//   @override
//   Future<void> startCall(
//       String channelId, int localUid, bool isVideoCall) async {
//     // Corrected: Added the 'info' parameter, passing an empty string for now.
//     // The 'info' parameter is required by your Agora RTC version's joinChannel method.
//     await remoteDataSource.joinChannel(
//         channelId, localUid, '', isVideoCall); // <--- FIX IS HERE
//   }
//
//   @override
//   Future<void> endCall() async {
//     await remoteDataSource.leaveChannel();
//     await remoteDataSource.disposeRtcEngine(); // Dispose engine after call ends
//   }
//
//   @override
//   Future<void> toggleMic(bool mute) async {
//     await remoteDataSource.toggleMic(mute);
//   }
//
//   @override
//   Future<void> toggleCamera(bool disable) async {
//     await remoteDataSource.toggleCamera(disable);
//   }
//
//   @override
//   Future<void> switchCamera() async {
//     await remoteDataSource.switchCamera();
//   }
//
//   @override
//   Stream<Map<String, dynamic>> get callEvents => _callEventsController.stream;
// }
