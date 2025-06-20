// // lib/features/calling/presentation/blocs/call_bloc/call_event.dart
// import 'package:agora_rtc_ng/agora_rtc_ng.dart';
// import 'package:equatable/equatable.dart';
// import 'package:seehear/features/auth/domain/entities/user_entity.dart'; // Import for UserOfflineReasonType
//
// abstract class CallEvent extends Equatable {
//   const CallEvent();
//
//   @override
//   List<Object> get props => [];
// }
//
// class CallStarted extends CallEvent {
//   final String channelId;
//   final UserEntity caller; // Assuming User entity for caller details
//   final bool isVideoCall;
//
//   const CallStarted({
//     required this.channelId,
//     required this.caller,
//     this.isVideoCall = true,
//   });
//
//   @override
//   List<Object> get props => [channelId, caller, isVideoCall];
// }
//
// class CallAnswered extends CallEvent {
//   final String channelId;
//   final bool isVideoCall;
//
//   const CallAnswered({
//     required this.channelId,
//     this.isVideoCall = true,
//   });
//
//   @override
//   List<Object> get props => [channelId, isVideoCall];
// }
//
// class CallEnded extends CallEvent {
//   const CallEnded();
// }
//
// class ToggleMic extends CallEvent {
//   final bool mute;
//   const ToggleMic({required this.mute});
//   @override
//   List<Object> get props => [mute];
// }
//
// class ToggleCamera extends CallEvent {
//   // Use 'disable' to align with Agora's enableLocalVideo(!disable)
//   final bool disable;
//   const ToggleCamera({required this.disable});
//   @override
//   List<Object> get props => [disable];
// }
//
// class SwitchCamera extends CallEvent {
//   const SwitchCamera();
// }
//
// class RemoteUserJoined extends CallEvent {
//   final int uid;
//   final int elapsed; // Time elapsed since the user joined
//
//   const RemoteUserJoined(this.uid, this.elapsed);
//
//   @override
//   List<Object> get props => [uid, elapsed];
// }
//
// class RemoteUserLeft extends CallEvent {
//   final int uid;
//   final UserOfflineReasonType reason; // Corrected type
//
//   const RemoteUserLeft(this.uid, this.reason);
//
//   @override
//   List<Object> get props => [uid, reason];
// }
