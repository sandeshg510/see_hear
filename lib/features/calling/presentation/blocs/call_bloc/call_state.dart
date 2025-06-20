// lib/features/calling/presentation/blocs/call_bloc/call_state.dart
import 'package:equatable/equatable.dart';

enum CallStatus { initial, active, ended, ringing, error }

abstract class CallState extends Equatable {
  const CallState();

  @override
  List<Object> get props => [];
}

class CallInitial extends CallState {
  @override
  List<Object> get props => [];
}

class CallActive extends CallState {
  final CallStatus status;
  final String channelId;
  final int? localUid;
  final int? remoteUid;
  final bool isVideoCall;
  final bool isMicMuted;
  final bool isCameraEnabled; // Renamed from isCameraOff for consistency
  final String? errorMessage;

  const CallActive({
    this.status = CallStatus.active,
    required this.channelId,
    this.localUid,
    this.remoteUid,
    required this.isVideoCall,
    this.isMicMuted = false,
    this.isCameraEnabled = true, // Default to true (camera enabled)
    this.errorMessage,
  });

  CallActive copyWith({
    CallStatus? status,
    String? channelId,
    int? localUid,
    int? remoteUid,
    bool? isVideoCall,
    bool? isMicMuted,
    bool? isCameraEnabled, // Updated copyWith parameter
    String? errorMessage,
  }) {
    return CallActive(
      status: status ?? this.status,
      channelId: channelId ?? this.channelId,
      localUid: localUid ?? this.localUid,
      remoteUid: remoteUid, // RemoteUid can be null when user leaves
      isVideoCall: isVideoCall ?? this.isVideoCall,
      isMicMuted: isMicMuted ?? this.isMicMuted,
      isCameraEnabled:
          isCameraEnabled ?? this.isCameraEnabled, // Updated assignment
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object> get props => [
        status,
        channelId,
        localUid ?? -1, // Use a default for nullable if needed in props
        remoteUid ?? -1,
        isVideoCall,
        isMicMuted,
        isCameraEnabled,
        errorMessage ?? '',
      ];
}

class CallRinging extends CallState {
  final String channelId;
  final String callerName; // Example for incoming call
  final bool isVideoCall;

  const CallRinging({
    required this.channelId,
    required this.callerName,
    this.isVideoCall = true,
  });

  @override
  List<Object> get props => [channelId, callerName, isVideoCall];
}

class CallEndedState extends CallState {
  @override
  List<Object> get props => [];
}

class CallFailure extends CallState {
  final String message;

  const CallFailure(this.message);

  @override
  List<Object> get props => [message];
}
