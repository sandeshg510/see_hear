import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthUserModel {
  final String uid;
  final String name;
  final String email;
  final String? profileImageUrl;

  AuthUserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImageUrl,
  });

  factory AuthUserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuthUserModel(
      uid: doc.id,
      name: data['name'] as String,
      email: data['email'] as String,
      profileImageUrl: data['profileImageUrl'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

class AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRemoteDataSource(this._firebaseAuth, this._firestore);

  User? get currentFirebaseUser => _firebaseAuth.currentUser;

  Future<User> signIn(String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred during sign in.';
    } catch (e) {
      rethrow;
    }
  }

  Future<User> signUp(String name, String email, String password) async {
    try {
      final UserCredential userCredential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = userCredential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set(AuthUserModel(
              uid: user.uid,
              name: name,
              email: email,
              profileImageUrl: null,
            ).toFirestore());
        return user;
      } else {
        throw Exception('Failed to create user.');
      }
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'An unknown error occurred during sign up.';
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<AuthUserModel?> getAuthUserModel(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return AuthUserModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching user model: $e');
      return null;
    }
  }
}
