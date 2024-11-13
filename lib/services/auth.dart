import 'package:app_atex_gpt_exam/models/appUser.dart';
import 'package:app_atex_gpt_exam/services/database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AppUser? _userFromFirebaseUser(User? firebaseUser) {
    return firebaseUser != null ? AppUser(uid: firebaseUser.uid ,email: firebaseUser.email!) : null;
  }

  Stream<AppUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;
      return _userFromFirebaseUser(firebaseUser);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future registerWithEmailAndPassword(String email, String password, String name) async {
    {
      // criar usuário no Auth
      print("Tentando cadastrar usuário no Auth");
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? firebaseUser = result.user;

      // criar o appUser (userdata) no Firestore
      print("Tentando criar userData no Firestore");
      await DatabaseService(uid: firebaseUser!.uid)
        .updateUserData(firebaseUser.uid, email, name, null); //TODO?

      return _userFromFirebaseUser(firebaseUser);
    }
  }

  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}