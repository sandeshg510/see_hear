//
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:fake/core/config/agora_config.dart';
// import 'package:fake/features/auth/domain/entities/user_entity.dart';
// import 'package:fake/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:permission_handler/permission_handler.dart';
//
//
// class CallScreen extends StatefulWidget {
//   final UserEntity otherUser;
//
//   const CallScreen({super.key, required this.otherUser});
//
//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }
//
// class _CallScreenState extends State<CallScreen> {
//   @override
//   void dispose() {
//     _dispose();
//     super.dispose();
//   }
//
//   // @override
//   // void initState() {
//   //   initAgora();
//   //   super.initState();
//   // }
//
//   late RtcEngine _engine;
//   bool _localUserJoined = false;
//   int? _remoteUid;
//   void initAgora() async {
//     await [Permission.microphone, Permission.camera].request();
//     _engine = await createAgoraRtcEngine();
//     await _engine.initialize(
//       const RtcEngineContext(
//         appId: AgoraConfig.appId,
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//       ),
//     );
//
//     await _engine.enableAudio();
//     await _engine.enableVideo();
//     await _engine.startPreview();
//     await _engine.joinChannel(
//       token: AgoraConfig.token,
//       channelId: AgoraConfig.channel,
//       uid: 0,
//       options: const ChannelMediaOptions(
//         autoSubscribeAudio: true,
//         autoSubscribeVideo: true,
//         publishCameraTrack: true,
//         publishMicrophoneTrack: true,
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//       ),
//     );
//
//     _engine.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//           debugPrint("local user ${connection.localUid} joined");
//           setState(() {
//             _localUserJoined = true;
//           });
//         },
//         onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline:
//             (
//             RtcConnection connection,
//             int remoteUid,
//             UserOfflineReasonType reason,
//             ) {
//           debugPrint("remote user $remoteUid joined");
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentUser = context.select<AuthBloc, UserEntity?>(
//           (bloc) => bloc.state is Authenticated
//           ? (bloc.state as Authenticated).user
//           : null,
//     );
//
//     if (currentUser == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Scaffold(
//       backgroundColor: Colors.black, // Or a dark grey similar to the image
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Profile Picture
//             Container(
//               width: 150,
//               height: 150,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 // image: const DecorationImage(
//                 //   image: AssetImage(
//                 //     'assets/images/chirag_profile.jpg',
//                 //   ), // Replace with actual profile image path
//                 //   fit: BoxFit.cover,
//                 // ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.white.withOpacity(0.1),
//                     blurRadius: 20,
//                     spreadRadius: 5,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 30),
//
//             Text(
//               widget.otherUser.name,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 34,
//                 fontWeight: FontWeight.bold,
//                 letterSpacing: 1.2,
//               ),
//             ),
//             const SizedBox(height: 80), // Space between name and buttons
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 AudioCallButton(onPressed: () {}),
//                 VideoCallButton(onPressed: () {}),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _remoteVideo() {
//     if (_remoteUid != null) {
//       return AgoraVideoView(
//         controller: VideoViewController.remote(
//           rtcEngine: _engine,
//           canvas: VideoCanvas(uid: _remoteUid),
//           connection: const RtcConnection(channelId: AgoraConfig.channel),
//         ),
//       );
//     } else {
//       return const Text(
//         'Please wait for remote user to join',
//         textAlign: TextAlign.center,
//       );
//     }
//   }
//
//   Future<void> _dispose() async {
//     await _engine.leaveChannel();
//     await _engine.release();
//   }
// }
//
// class AudioCallButton extends StatelessWidget {
//   final VoidCallback onPressed;
//
//   const AudioCallButton({super.key, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(50),
//           child: Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [Colors.green.shade700, Colors.green.shade500],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.green.shade700.withOpacity(0.4),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: const Icon(Icons.call, color: Colors.white, size: 40),
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Audio Call',
//           style: TextStyle(color: Colors.white70, fontSize: 16),
//         ),
//       ],
//     );
//   }
// }
//
// // --- New: VideoCallButton Widget ---
// class VideoCallButton extends StatelessWidget {
//   final VoidCallback onPressed;
//
//   const VideoCallButton({super.key, required this.onPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         InkWell(
//           onTap: onPressed,
//           borderRadius: BorderRadius.circular(50),
//           child: Container(
//             width: 80,
//             height: 80,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: LinearGradient(
//                 colors: [Colors.purple.shade700, Colors.purple.shade500],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.purple.shade700.withOpacity(0.4),
//                   blurRadius: 10,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: const Icon(Icons.videocam, color: Colors.white, size: 40),
//           ),
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Video Call',
//           style: TextStyle(color: Colors.white70, fontSize: 16),
//         ),
//       ],
//     );
//   }
// }
