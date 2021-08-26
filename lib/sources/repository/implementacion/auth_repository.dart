import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:proyecto_final/sources/repository/auth_repository.dart';

class AuthRepository extends AuthRepositoryBase {
  final _firebaseAuth = FirebaseAuth.instance;
  final userReference = FirebaseDatabase.instance.reference().child('cliente');

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
    print(authResult.user!.uid);
    checaExistencia(authResult.user!.uid, authResult.user!.email);
    return _userFromFirebase(authResult.user);
  }

  @override
  Future<AuthUser?> createUserWithEmailAndPassword(
      String email, String password) async {
    final result = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
    checaExistencia(result.user!.uid, result.user!.email);
    return _userFromFirebase(result.user);
  }

  @override
  Future<AuthUser?> signInWithEmailAndPassword(
      String email, String password) async {
    final result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
    checaExistencia(result.user!.uid, result.user!.email);

    return _userFromFirebase(result.user);
  }

  Future<void> checaExistencia(String id_user, String? mail) async {
    print(id_user);
    await userReference
        .orderByKey()
        .equalTo(id_user)
        .once()
        .then((DataSnapshot snapshot) {
      if (!snapshot.exists) {
        creaUsuario(id_user, mail);
      } else {
        Map<dynamic, dynamic> map = snapshot.value;
        print(map.values.toList()[0]["email"]);
      }
    });
  }

  void creaUsuario(String id_user, String? name) {
    userReference.child(id_user).set({"email": name});
  }
}
