import 'dart:convert'; // Added for json encoding/decoding

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http; // Added for HTTP requests
import 'package:permission_handler/permission_handler.dart';
import 'package:see_hear/core/config/agora_config.dart';
import 'package:see_hear/features/auth/domain/entities/user_entity.dart';
import 'package:see_hear/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:see_hear/features/auth/presentation/blocs/auth_bloc/auth_state.dart';

class CallScreen extends StatefulWidget {
  final UserEntity otherUser;
  const CallScreen({super.key, required this.otherUser});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  RtcEngine? _engine;
  int? _remoteUid;
  bool _isInCall = false;
  bool _isVideoCall = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isLocalVideoEnabled = true;
  bool _isInitialized = false; // Tracks if Agora engine is initialized for call
  bool _isLoading = false; // Tracks if call is being initiated/joined
  String? _channelName;

  @override
  void dispose() {
    _disposeEngine();
    super.dispose();
  }

  Future<void> _disposeEngine() async {
    try {
      if (_engine != null) {
        await _engine!.leaveChannel();
        await _engine!.release();
        _engine = null;
      }
    } catch (e) {
      debugPrint("Error disposing engine: $e");
    }
  }

  Future<void> _initiateCall(bool isVideoCall) async {
    if (_isLoading || _isInCall) return; // Prevent multiple call initiations

    setState(() {
      _isLoading = true;
      _isVideoCall = isVideoCall;
      _isLocalVideoEnabled =
          isVideoCall; // Local video enabled by default for video calls
    });

    try {
      // 1. Request permissions
      final micStatus = await Permission.microphone.request();
      if (isVideoCall) {
        await Permission.camera.request();
      }

      if (!micStatus.isGranted ||
          (isVideoCall && !await Permission.camera.isGranted)) {
        if (mounted) {
          // Check if the widget is still in the tree
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Microphone and Camera permissions required for video calls',
              ),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // 2. Get current user for channel naming
      final currentUser = context.read<AuthBloc>().state is Authenticated
          ? (context.read<AuthBloc>().state as Authenticated).user
          : null;

      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Current user not found. Cannot initiate call.'),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // --- NEW: Get Firebase ID Token ---
      final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
      String? idToken;
      if (firebaseUser != null) {
        try {
          idToken = await firebaseUser.getIdToken();
          debugPrint('Firebase ID Token fetched successfully.');
        } catch (e) {
          debugPrint('Error getting Firebase ID Token: $e');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Error getting Firebase ID Token: ${e.toString()}',
                ),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      } else {
        debugPrint('No Firebase user logged in.');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No authenticated Firebase user found.'),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (idToken == null || idToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Firebase ID Token is null or empty.'),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      // --- END NEW ---

      // 3. Create unique channel name based on user IDs
      final userIDs = [currentUser.uid, widget.otherUser.uid]..sort();
      _channelName = 'call_${userIDs.join('_')}';
      debugPrint("Attempting to join channel: $_channelName");

      // --- Fetch Token from Server (updated with Authorization header) ---
      String? fetchedToken;
      try {
        final response = await http.post(
          Uri.parse('${AgoraConfig.tokenServerBaseUrl}/rtc-token'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $idToken', // <--- ADD THIS HEADER
          },
          body: json.encode({
            'channelName': _channelName,
            // 'uid': currentUser.uid, // UID is now extracted from the verified token on server
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          fetchedToken = data['token'];
          debugPrint(
            'Fetched token successfully. Status: ${response.statusCode}',
          );
          debugPrint(
            'Fetched token (first 20 chars): ${fetchedToken?.substring(0, fetchedToken.length > 20 ? 20 : fetchedToken.length)}...',
          );
        } else {
          debugPrint(
            'Failed to fetch token: ${response.statusCode} - ${response.body}',
          );
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to fetch token: ${response.statusCode}'),
              ),
            );
          }
          setState(() => _isLoading = false);
          return;
        }
      } catch (e) {
        debugPrint('Error fetching token: ${e.toString()}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching token: ${e.toString()}')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      if (fetchedToken == null || fetchedToken.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Token is null or empty after fetching.'),
            ),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      // --- END FETCH TOKEN ---

      // 4. Create and initialize Agora engine instance
      _engine = createAgoraRtcEngine();
      await _engine!.initialize(
        RtcEngineContext(
          appId: AgoraConfig.appId,
          channelProfile: ChannelProfileType.channelProfileCommunication,
        ),
      );

      // 5. Register event handlers
      _engine!.registerEventHandler(
        RtcEngineEventHandler(
          onJoinChannelSuccess: (connection, elapsed) {
            debugPrint(
              "Local user joined: ${connection.localUid} to channel ${connection.channelId}",
            );
            if (mounted) {
              setState(() {
                _isInCall = true;
                _isLoading = false;
                _isInitialized = true;
              });
            }
          },
          onUserJoined: (connection, remoteUid, elapsed) {
            debugPrint(
              "Remote user joined: $remoteUid in channel ${connection.channelId}",
            );
            if (mounted) {
              setState(() => _remoteUid = remoteUid);
            }
          },
          onUserOffline: (connection, remoteUid, reason) {
            debugPrint("Remote user offline: $remoteUid");
            if (mounted) {
              setState(() => _remoteUid = null);
              _endCall(); // End call if remote user leaves
            }
          },
          onError: (error, msg) {
            // IMPORTANT: Log the error code and message here!
            debugPrint("Agora Error: Code: $error, Message: $msg");
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Call error: $msg (Code: $error)')),
              ); // Display code in snackbar
              _endCall();
            }
          },
          onTokenPrivilegeWillExpire: (connection, currentToken) {
            debugPrint(
              "Token will expire soon for channel: ${connection.channelId}",
            );
            // IMPORTANT: In a real app, make another HTTP call to your token server to get a new token
            // and then call _engine.renewToken(newToken);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Call token expiring. Please renew token.'),
                ),
              );
            }
          },
          onRemoteVideoStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
                debugPrint(
                  "Remote video state changed for $remoteUid: $state, reason: $reason",
                );
              },
          onLocalVideoStateChanged: (source, state, error) {
            debugPrint("Local video state changed: $state, error: $error");
          },
          onRemoteAudioStateChanged:
              (connection, remoteUid, state, reason, elapsed) {
                debugPrint(
                  "Remote audio state changed for $remoteUid: $state, reason: $reason",
                );
              },
          onLocalAudioStateChanged: (connection, state, reason) {
            debugPrint("Local audio state changed: $state, reason: $reason");
          },
        ),
      );

      // 6. Configure video/audio based on call type
      if (isVideoCall) {
        await _engine!.enableVideo();
        await _engine!.startPreview(); // Start local video preview
        await _engine!.setVideoEncoderConfiguration(
          const VideoEncoderConfiguration(
            dimensions: VideoDimensions(width: 640, height: 360),
            frameRate: 15,
          ),
        );
      } else {
        await _engine!.disableVideo();
        await _engine!
            .enableAudio(); // Explicitly enable audio for audio-only calls
      }

      debugPrint(
        'Joining channel with token: ${fetchedToken.substring(0, fetchedToken.length > 20 ? 20 : fetchedToken.length)}... and channelId: $_channelName',
      );

      // 7. Join channel - Now using the fetchedToken and dynamic _channelName!
      await _engine!.joinChannel(
        token: fetchedToken, // Use the fetched token
        channelId:
            _channelName!, // IMPORTANT: Using the dynamic channel name here
        uid: 0, // Let Agora assign a UID
        options: ChannelMediaOptions(
          autoSubscribeAudio: true,
          autoSubscribeVideo: isVideoCall,
          publishCameraTrack: isVideoCall,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster,
        ),
      );
    } catch (e) {
      debugPrint("Call initiation error: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Call failed: ${e.toString()}')));
      }
      setState(() => _isLoading = false);
    }
  }

  void _endCall() {
    _disposeEngine();
    if (mounted) {
      setState(() {
        _isInCall = false;
        _isLoading = false;
        _remoteUid = null;
        _isInitialized = false;
        _isMuted = false;
        _isSpeakerOn = true;
        _isLocalVideoEnabled = true;
      });
      // Optionally navigate back after call ends
      Navigator.pop(context);
    }
  }

  void _toggleMute() {
    if (_engine == null || !_isInCall) return;
    _engine?.muteLocalAudioStream(!_isMuted);
    setState(() => _isMuted = !_isMuted);
  }

  void _toggleSpeaker() {
    if (_engine == null || !_isInCall) return;
    _engine?.setEnableSpeakerphone(!_isSpeakerOn);
    setState(() => _isSpeakerOn = !_isSpeakerOn);
  }

  void _toggleVideo() {
    if (_engine == null || !_isInCall || !_isVideoCall) return;
    _engine?.muteLocalVideoStream(!_isLocalVideoEnabled);
    setState(() => _isLocalVideoEnabled = !_isLocalVideoEnabled);
  }

  Widget _buildLocalPreview() {
    // Only show local preview if it's a video call, engine is initialized, and video is enabled
    if (!_isVideoCall ||
        !_isInitialized ||
        !_isLocalVideoEnabled ||
        _engine == null) {
      return Container();
    }

    return Positioned(
      top: 20,
      right: 20,
      width: 100,
      height: 150,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: AgoraVideoView(
          controller: VideoViewController(
            rtcEngine: _engine!,
            canvas: const VideoCanvas(uid: 0), // uid 0 is for local user
          ),
        ),
      ),
    );
  }

  Widget _buildRemoteVideo() {
    if (!_isInitialized || _engine == null) {
      return Container(
        color: Colors.black,
        child: const Center(
          child:
              CircularProgressIndicator(), // Show loading while engine not ready
        ),
      );
    }

    if (_remoteUid == null || !_isVideoCall) {
      // Fallback for audio calls or when no remote video is available
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[800],
                child: Text(
                  widget.otherUser.name.isNotEmpty
                      ? widget.otherUser.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(fontSize: 48, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                widget.otherUser.name,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 10),
              Text(
                _isVideoCall
                    ? (_remoteUid == null
                          ? 'Connecting...'
                          : 'Waiting for video...')
                    : 'Audio call in progress',
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    // Display remote video for video calls
    return AgoraVideoView(
      controller: VideoViewController.remote(
        rtcEngine: _engine!,
        canvas: VideoCanvas(uid: _remoteUid),
        connection: RtcConnection(channelId: _channelName!),
      ),
    );
  }

  Widget _buildCallControls() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            color: _isMuted ? Colors.grey : Colors.white,
            bgColor: Colors.blueGrey,
            onPressed: _toggleMute,
          ),

          // Video Toggle (only for video calls)
          if (_isVideoCall)
            _buildControlButton(
              icon: _isLocalVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color: _isLocalVideoEnabled ? Colors.white : Colors.grey,
              bgColor: Colors.blueGrey,
              onPressed: _toggleVideo,
            ),

          // Speaker Toggle
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            color: _isSpeakerOn ? Colors.white : Colors.grey,
            bgColor: Colors.blueGrey,
            onPressed: _toggleSpeaker,
          ),

          // End Call Button
          _buildControlButton(
            icon: Icons.call_end,
            color: Colors.white,
            bgColor: Colors.red,
            onPressed: _endCall,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onPressed,
  }) {
    return CircleAvatar(
      backgroundColor: bgColor,
      radius: 28,
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure currentUser is available
    final currentUser = context.select<AuthBloc, UserEntity?>(
      (bloc) => bloc.state is Authenticated
          ? (bloc.state as Authenticated).user
          : null,
    );

    if (currentUser == null) {
      // Handle case where current user is not authenticated or available
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'User not authenticated.',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    if (_isLoading && !_isInCall) {
      // Show loading only during initial call setup
      return Scaffold(
        backgroundColor: const Color(0xFF1a1a2e),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Calling ${widget.otherUser.name}...',
                style: const TextStyle(color: Colors.white, fontSize: 18),
              ),
            ],
          ),
        ),
      );
    }

    // Call in progress UI
    if (_isInCall) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // Remote video/audio state
            _buildRemoteVideo(),

            // Local preview (for video calls)
            _buildLocalPreview(),

            // Call controls
            _buildCallControls(),

            // Call info (name and status)
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Center(
                child: Column(
                  children: [
                    Text(
                      widget.otherUser.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _remoteUid == null ? 'Connecting...' : 'In call',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Initial state: Display call initiation buttons
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(32.0),
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 8,
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // User Name
              Text(
                widget.otherUser.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 48.0),
              // Call Buttons Container
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Audio Call Button
                  _CallButton(
                    icon: Icons.phone,
                    label: 'Audio Call',
                    gradientColors: const [
                      Color(0xFF4CAF50),
                      Color(0xFF43A047),
                    ],
                    onPressed: () => _initiateCall(false),
                  ),
                  const SizedBox(width: 24.0),
                  // Video Call Button
                  _CallButton(
                    icon: Icons.videocam,
                    label: 'Video Call',
                    gradientColors: const [
                      Color(0xFF2196F3),
                      Color(0xFF1976D2),
                    ],
                    onPressed: () => _initiateCall(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> gradientColors;
  final VoidCallback onPressed;

  const _CallButton({
    required this.icon,
    required this.label,
    required this.gradientColors,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: 120,
          height: 120,
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(60.0),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withOpacity(0.5),
                spreadRadius: 4,
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 40.0),
              const SizedBox(height: 8.0),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
