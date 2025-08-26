import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:farmodo/data/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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
      return Future.error('Invalid email');
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
        return Future.error('Please confirm your email');
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
        level: 0,
        xp: 0,
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
        return Future.error('User not found');
      } else if(e.code == 'wrong-password'){
        return Future.error('Wrong password');
      } else if(e.code == 'invalid-email'){
        return Future.error('Invalid email');
      } else {
        return Future.error('Login failed');
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

  Future<UserModel> signInWithGoogle() async {
    try {
      // Check if Google Play Services is available
      if (!await _googleSignIn.isSignedIn()) {
        // Force sign out to clear any cached state
        await _googleSignIn.signOut();
      }

      // Google Sign-In'i başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google Sign-In iptal edildi');
      }

      // Google authentication bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Google authentication token alınamadı');
      }

      // Firebase credential oluştur
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user == null) {
        throw Exception('Firebase authentication başarısız');
      }

      // Firestore'dan kullanıcı bilgilerini al veya oluştur
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      UserModel userModel;
      
      if (doc.exists) {
        userModel = UserModel.fromFirestore(doc);
        // Son giriş zamanını güncelle
        userModel = userModel.copyWith(lastLoginAt: DateTime.now());
        await createUserInFirestore(userModel);
      } else {
        userModel = UserModel(
          id: user.uid,
          email: user.email ?? '',
          displayName: user.displayName ?? '',
          level: 0,
          xp: 0,
          totalPomodoro: 0,
          avatarUrl: user.photoURL,
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
      String errorMessage = 'Google Sign-In hatası';
      
      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Bu email adresi farklı bir yöntemle kayıtlı';
          break;
        case 'invalid-credential':
          errorMessage = 'Geçersiz kimlik bilgileri';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Google Sign-In etkin değil';
          break;
        case 'user-disabled':
          errorMessage = 'Kullanıcı hesabı devre dışı';
          break;
        case 'user-not-found':
          errorMessage = 'Kullanıcı bulunamadı';
          break;
        case 'network-request-failed':
          errorMessage = 'Ağ bağlantısı hatası';
          break;
        default:
          errorMessage = 'Google Sign-In hatası: ${e.message}';
      }
      
      throw Exception(errorMessage);
    } catch (e) {
      if (e.toString().contains('network')) {
        throw Exception('İnternet bağlantısı hatası. Lütfen bağlantınızı kontrol edin.');
      }
      
      // Handle Google Sign-In specific errors
      if (e.toString().contains('ApiException: 10')) {
        throw Exception('Google Sign-In yapılandırma hatası. Lütfen SHA-1 sertifika parmak izini kontrol edin.');
      }
      
      throw Exception('Google Sign-In hatası: $e');
    }
  }

  Future<void> signOutGoogle() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

}