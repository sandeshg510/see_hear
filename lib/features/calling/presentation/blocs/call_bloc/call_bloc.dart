// // lib/features/calling/presentation/blocs/call_bloc/call_bloc.dart
// import 'dart:async';
//
// import 'package:agora_rtc_ng/agora_rtc_ng.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// import '../../../domain/repositories/call_repository.dart';
// import 'call_event.dart';
// import 'call_state.dart';
//
// class CallBloc extends Bloc<CallEvent, CallState> {
//   final CallRepository callRepository;
//   StreamSubscription? _callEventsSubscription;
//
//   CallBloc({required this.callRepository}) : super(CallInitial()) {
//     _initEngineAndListenEvents(); // Initialize engine and set up listeners on BLoC creation
//
//     on<CallStarted>(_onCallStarted);
//     on<CallAnswered>(_onCallAnswered);
//     on<CallEnded>(_onCallEnded);
//     on<ToggleMic>(_onToggleMic);
//     on<ToggleCamera>(_onToggleCamera);
//     on<SwitchCamera>(_onSwitchCamera);
//     on<RemoteUserJoined>(_onRemoteUserJoined);
//     on<RemoteUserLeft>(_onRemoteUserLeft);
//   }
//
//   Future<void> _initEngineAndListenEvents() async {
//     try {
//       await callRepository.initCallEngine();
//       _callEventsSubscription = callRepository.callEvents.listen((event) {
//         final type = event['type'];
//         final connection = event['connection'] as RtcConnection?;
//
//         switch (type) {
//           case 'userJoined':
//             add(RemoteUserJoined(
//                 event['remoteUid'] as int, event['elapsed'] as int));
//             break;
//           case 'userOffline':
//             add(RemoteUserLeft(
//                 event['remoteUid'] as int,
//                 event['reason']
//                     as UserOfflineReasonType)); // Corrected: No .index
//             break;
//           case 'joinChannelSuccess':
//             if (state is CallActive) {
//               emit((state as CallActive)
//                   .copyWith(localUid: connection?.localUid));
//             }
//             break;
//           case 'leaveChannel':
//             add(const CallEnded()); // End call when local user leaves
//             break;
//           case 'connectionStateChanged':
//             final connectionState = event['state'] as ConnectionStateType;
//             if (connectionState ==
//                     ConnectionStateType.connectionStateDisconnected ||
//                 connectionState == ConnectionStateType.connectionStateFailed) {
//               print('CallBloc: Connection State Changed: $connectionState');
//             }
//             break;
//         }
//       });
//     } catch (e) {
//       emit(CallFailure('Failed to initialize call engine: $e'));
//       print('CallBloc Init Error: $e');
//     }
//   }
//
//   Future<void> _onCallStarted(
//       CallStarted event, Emitter<CallState> emit) async {
//     emit(CallActive(
//       channelId: event.channelId,
//       localUid: 0, // Placeholder until onJoinChannelSuccess gives actual UID
//       isVideoCall: event.isVideoCall,
//       remoteUid: null,
//       isMicMuted: false, // Default initial state
//       isCameraEnabled: true, // Default initial state
//     ));
//     try {
//       final localUid = int.parse(event.caller.uid.hashCode
//           .toString()
//           .substring(0, 9)); // Simple hash for UID for now
//       // startCall takes 3 arguments: channelId, localUid, isVideoCall (no 'info' for 6.0.0-beta.2)
//       await callRepository.startCall(
//           event.channelId, localUid, event.isVideoCall);
//       emit((state as CallActive).copyWith(localUid: localUid));
//       print('CallBloc: Call started with channel ${event.channelId}');
//     } catch (e) {
//       emit(CallFailure('Failed to start call: $e'));
//       print('CallBloc Error: Failed to start call: $e');
//     }
//   }
//
//   Future<void> _onCallAnswered(
//       CallAnswered event, Emitter<CallState> emit) async {
//     emit(CallActive(
//       channelId: event.channelId,
//       localUid: 0, // Placeholder
//       isVideoCall: event.isVideoCall,
//       remoteUid: null,
//       isMicMuted: false, // Default initial state
//       isCameraEnabled: true, // Default initial state
//     ));
//     try {
//       final localUid =
//           DateTime.now().millisecondsSinceEpoch % 100000; // Simple random UID
//       // startCall takes 3 arguments: channelId, localUid, isVideoCall (no 'info' for 6.0.0-beta.2)
//       await callRepository.startCall(
//           event.channelId, localUid, event.isVideoCall);
//       emit((state as CallActive).copyWith(localUid: localUid));
//       print('CallBloc: Call answered on channel ${event.channelId}');
//     } catch (e) {
//       emit(CallFailure('Failed to answer call: $e'));
//       print('CallBloc Error: Failed to answer call: $e');
//     }
//   }
//
//   Future<void> _onCallEnded(CallEnded event, Emitter<CallState> emit) async {
//     try {
//       await callRepository.endCall();
//       emit(CallEndedState());
//       print('CallBloc: Call ended.');
//     } catch (e) {
//       emit(CallFailure('Failed to end call: $e'));
//       print('CallBloc Error: Failed to end call: $e');
//     } finally {
//       _callEventsSubscription?.cancel(); // Cancel subscription when call ends
//     }
//   }
//
//   Future<void> _onToggleMic(ToggleMic event, Emitter<CallState> emit) async {
//     if (state is CallActive) {
//       final newMuteState = event.mute; // Use directly from event
//       await callRepository.toggleMic(newMuteState);
//       emit((state as CallActive).copyWith(isMicMuted: newMuteState));
//       print('CallBloc: Toggled mic to ${newMuteState}');
//     }
//   }
//
//   Future<void> _onToggleCamera(
//       ToggleCamera event, Emitter<CallState> emit) async {
//     if (state is CallActive) {
//       final newCameraEnabledState =
//           !event.disable; // Invert 'disable' to get 'enabled'
//       await callRepository
//           .toggleCamera(event.disable); // Pass disable directly to repo
//       emit((state as CallActive)
//           .copyWith(isCameraEnabled: newCameraEnabledState));
//       print('CallBloc: Toggled camera to ${newCameraEnabledState}');
//     }
//   }
//
//   Future<void> _onSwitchCamera(
//       SwitchCamera event, Emitter<CallState> emit) async {
//     if (state is CallActive) {
//       await callRepository.switchCamera();
//       print('CallBloc: Switched camera.');
//     }
//   }
//
//   void _onRemoteUserJoined(RemoteUserJoined event, Emitter<CallState> emit) {
//     if (state is CallActive) {
//       emit((state as CallActive).copyWith(remoteUid: event.uid));
//       print('CallBloc: Remote user ${event.uid} joined.');
//     }
//   }
//
//   void _onRemoteUserLeft(RemoteUserLeft event, Emitter<CallState> emit) {
//     if (state is CallActive) {
//       emit((state as CallActive).copyWith(remoteUid: null)); // Remote user left
//       print('CallBloc: Remote user ${event.uid} left.');
//     }
//   }
//
//   @override
//   Future<void> close() {
//     _callEventsSubscription?.cancel();
//     callRepository.endCall(); // Ensure engine is disposed on bloc close
//     return super.close();
//   }
// }
