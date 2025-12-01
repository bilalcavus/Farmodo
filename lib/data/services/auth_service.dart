import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final fb.FirebaseAuth _firebaseAuth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get firebaseUser => _firebaseAuth.currentUser;
  String? get getCurrentUserId => firebaseUser?.uid;
  bool get isLoggedIn => firebaseUser != null;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isAuthStateReady = false;
  bool get isAuthStateReady => _isAuthStateReady;

  Future<void> initializeAuthState() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _isAuthStateReady = true;
    if (isLoggedIn) {
      await loadCurrentUser();
    }
  }

  Future<String?> getUserPhotoUrl(String uid) async {
    final snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return snapshot.data()?['photoUrl'];
  }


  Future<void> fetchAndSetCurrentUser() async {
    if (firebaseUser == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(firebaseUser?.uid).get();
    if(doc.exists){
      _currentUser = UserModel.fromFirestore(doc);
    }
  }

  Future<void> createUserInFirestore(UserModel user) async {
    await FirebaseFirestore.instance.collection('users').doc(user.id).set(user.toFirestore(), SetOptions(merge: true));
  }

  Future<UserModel> registerUser({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(email)) {
      return Future.error('auth_errors.invalid_email'.tr());
    }
    final cred = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await cred.user?.sendEmailVerification();
    await cred.user?.updateDisplayName(displayName);
    await cred.user?.reload();
    final user = _firebaseAuth.currentUser;
    final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
    UserModel userModel;
    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
    } else {
      userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        level: 1,
        xp: 0,
        coins: 500,
        totalPomodoro: 0,
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
        userPreferences: null,
        isPremiumUser: false,
      );
      await createUserInFirestore(userModel);
      
    }
    _currentUser = userModel;
    return userModel;
  }
  

  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      if (!cred.user!.emailVerified) {
        await _firebaseAuth.signOut();
        return Future.error('auth_errors.email_not_verified'.tr());
      }

      final user = cred.user;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      UserModel userModel;
      if (doc.exists) {
        userModel = UserModel.fromFirestore(doc);
      } else {
        userModel = UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? '',
        level: 1,
        xp: 0,
        coins: 500,
        totalPomodoro: 0,
        avatarUrl: user.photoURL,
        createdAt: DateTime.now(),
        lastLoginAt: null,
        isActive: true,
        userPreferences: null,
        isPremiumUser: false,
      );
      await createUserInFirestore(userModel);
      }
      _currentUser = userModel;
      return userModel;
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Future.error('auth_errors.user_not_found'.tr());
      } else if(e.code == 'wrong-password'){
        return Future.error('auth_errors.wrong_password'.tr());
      } else if(e.code == 'invalid-email'){
        return Future.error('auth_errors.invalid_email'.tr());
      } else {
        return Future.error('auth_errors.login_failed'.tr());
      }
    }
  }

   Future<void> loadCurrentUser() async {
    final uid = firebaseUser?.uid;
    if (uid == null) return;

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = UserModel.fromFirestore(doc);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
    _currentUser = null;
    _isAuthStateReady = false;
  }

  Future<UserModel> signInWithApple() async {
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ]
    );

    if(appleCredential.identityToken == null){
      throw Exception('auth_errors.apple_no_identity_token'.tr());
    }

    final oauthcredential = fb.OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      accessToken: appleCredential.authorizationCode,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(oauthcredential);
    final user = userCredential.user;
    final photoUrl = firebaseUser?.photoURL;

    if (user == null) {
      throw Exception('auth_errors.apple_auth_failed'.tr());
    }

    final doc = await _firestore.collection('users').doc(user.uid).get();
    UserModel userModel;

    if (doc.exists) {
      userModel = UserModel.fromFirestore(doc);
      userModel = userModel.copyWith(lastLoginAt: DateTime.now());
      await createUserInFirestore(userModel);
    } else {
       userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          level: 1,
          xp: 0,
          coins: 500,
          totalPomodoro: 0,
          avatarUrl: photoUrl,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          userPreferences: null,
          isPremiumUser: false,
        );
        await createUserInFirestore(userModel);
    }
    _currentUser = userModel;
    return userModel;
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      if (!await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('auth_errors.google_sign_in_cancelled'.tr());
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('auth_errors.google_auth_token_error'.tr());
      }

      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      final photoUrl = firebaseUser?.photoURL;

      if (user == null) {
        throw Exception('auth_errors.google_firebase_auth_failed'.tr());
      }

      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      UserModel userModel;
      
      if (doc.exists) {
        userModel = UserModel.fromFirestore(doc);
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
        await createUserInFirestore(userModel);
      } else {
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          level: 1,
          xp: 0,
          coins: 500,
          totalPomodoro: 0,
          avatarUrl: photoUrl,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
          isActive: true,
          userPreferences: null,
          isPremiumUser: false,
        );
        await createUserInFirestore(userModel);
      }
      
      _currentUser = userModel;
      return userModel;
      
    } on fb.FirebaseAuthException catch (e) {
      String errorMessage = 'auth_errors.google_sign_in_error'.tr();
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'auth_errors.google_account_exists_with_different_credential'.tr();
          break;
        case 'invalid-credential':
          errorMessage = 'auth_errors.google_invalid_credential'.tr();
          break;
        case 'operation-not-allowed':
          errorMessage = 'auth_errors.google_operation_not_allowed'.tr();
          break;
        case 'user-disabled':
          errorMessage = 'auth_errors.google_user_disabled'.tr();
          break;
        case 'user-not-found':
          errorMessage = 'auth_errors.google_user_not_found'.tr();
          break;
        case 'network-request-failed':
          errorMessage = 'auth_errors.google_network_request_failed'.tr();
          break;
        default:
          errorMessage = 'auth_errors.google_sign_in_error_with_message'
              .tr(namedArgs: {'message': e.message ?? ''});
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('network')) {
        throw Exception('auth_errors.google_no_internet'.tr());
      }
      
      if (e.toString().contains('ApiException: 10')) {
        throw Exception('auth_errors.google_config_error'.tr());
      }
      
      throw Exception('auth_errors.google_sign_in_error_with_message'.tr(
        namedArgs: {'message': e.toString()},
      ));
    }
  }

  Future<void> deleteUserAccount() async {
    final user = _firebaseAuth.currentUser;
    if(user == null) return;

    final userId = user.uid;
    final batch = FirebaseFirestore.instance.batch();

    final userDoc = FirebaseFirestore.instance.collection("users").doc(userId);
    batch.delete(userDoc);
  }

  Future<void> deleteGoogleAccount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final googleUser = await _googleSignIn.signInSilently() ?? await _googleSignIn.signIn();
      final googleAuth = await googleUser?.authentication;
      final credentianl = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      await user?.reauthenticateWithCredential(credentianl);
      await user?.delete();
      signOutGoogle();
    } catch (e) {
      if (e is FirebaseAuthException) {
      rethrow;
    }
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }
}
