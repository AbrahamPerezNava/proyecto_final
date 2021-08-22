import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_final/sources/repository/auth_repository.dart';

class AuthRepository extends AuthRepositoryBase {
  final _firebaseAuth = FirebaseAuth.instance;

  AuthUser? _userFromFirebase(User? user) =>
      user == null ? null : AuthUser(user.uid, user.uid);

  @override
  Stream<AuthUser?> get onAuthStateChanged =>
      _firebaseAuth.authStateChanges().asyncMap(_userFromFirebase);

  @override
  Future<AuthUser?> signInAnonymously() async {
    final user = await _firebaseAuth.signInAnonymously();
    return _userFromFirebase(user.user);
  }

  @override
  Future<void> singOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<AuthUser?> signInWithGoogle() async {
    // Trigger the authentication flow
    final googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    final authResult =
        await FirebaseAuth.instance.signInWithCredential(credential);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<AuthUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(result.user);
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
      String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    return _userFromFirebase(result.user);
  }
}
