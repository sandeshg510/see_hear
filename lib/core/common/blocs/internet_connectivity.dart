// import 'dart:async';
//
// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
//
// enum ConnectivityStatus { connected, disconnected }
//
// class InternetConnectivityState {
//   final ConnectivityStatus status;
//   const InternetConnectivityState({required this.status});
// }
//
// class InternetConnectivityCubit extends Cubit<InternetConnectivityState> {
//   InternetConnectivityCubit()
//       : super(const InternetConnectivityState(
//             status: ConnectivityStatus.disconnected));
//
//   void checkConnectivity() async {
//     var connectivityResult = await Connectivity().checkConnectivity();
//     _updateConnectivityStatus(connectivityResult);
//   }
//
//   void _updateConnectivityStatus(List<ConnectivityResult> result) {
//     if (result.contains(ConnectivityResult.none)) {
//       emit(const InternetConnectivityState(
//           status: ConnectivityStatus.disconnected));
//     } else if (result.contains(ConnectivityResult.mobile) ||
//         result.contains(ConnectivityResult.wifi)) {
//       emit(const InternetConnectivityState(
//           status: ConnectivityStatus.connected));
//     }
//   }
//
//   late StreamSubscription<List<ConnectivityResult>> _internetSubscription;
//
//   void trackConnectivityChange() {
//     _internetSubscription =
//         Connectivity().onConnectivityChanged.listen((result) {
//       _updateConnectivityStatus(result);
//     });
//   }
//
//   void dispose() {
//     _internetSubscription.cancel();
//   }
// }
