import 'package:easy_localization/easy_localization.dart';
import 'package:farmodo/core/components/message/snack_messages.dart';
import 'package:farmodo/core/utility/extension/route_helper.dart';
import 'package:farmodo/data/services/auth_service.dart';
import 'package:farmodo/data/services/sample_data_service.dart';
import 'package:farmodo/feature/navigation/app_navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Trans;

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final AuthService authService;


  LoginController(this.authService);
  

  final _isLoading = false.obs;
  final _googleLoading = false.obs;
  final _appleLoading = false.obs;
  final _deleteGoogleAccountLoading = false.obs;
  final _rememberMeCheckbox = false.obs;
  final _deletionObscurePassword = true.obs;
  final _agreeToTerms = false.obs;

  var errorMessage = ''.obs;
  RxBool get isLoading => _isLoading;
  RxBool get googleLoading => _googleLoading;
  RxBool get appleLoading => _appleLoading;
  RxBool get deleteGoogleAccountLoading => _deleteGoogleAccountLoading;
  RxBool get rememberMeCheckBox => _rememberMeCheckbox;
  RxBool get deletionObscurePassword => _deletionObscurePassword;
  RxBool get agreeToTerms => _agreeToTerms;

  final _obsecurePassword = true.obs;
  RxBool get obsecurePassword => _obsecurePassword;

  final RxInt _userXp = 0.obs;
  RxInt get userXp => _userXp;


  @override
  void onReady() {
    _userXp.value = authService.currentUser?.xp ?? 0;
    authService.fetchAndSetCurrentUser().then((_) {
      _userXp.value = authService.currentUser?.xp ?? 0;
    });
    super.onReady();
  }

  void refreshUserXp() {
    _userXp.value = authService.currentUser?.xp ?? 0;
  }

  @override
  void onClose() {
    emailController.clear();
    passwordController.clear();
    super.onClose();
  }

  void toggleLoginPasswordVisibility() {
    _obsecurePassword.value = !_obsecurePassword.value;
  }

  void setLoading(RxBool value){
    isLoading.value = value.value;
  }

  void setDeleteGoogleAccountLoading(RxBool value){
    deleteGoogleAccountLoading.value = value.value;
  }

  void setGoogleLoading(RxBool value){
    googleLoading.value = value.value;
  }

  void setAppleLoading(RxBool value){
    appleLoading.value = value.value;
  }

  void toggleRememberMe(bool? value){
    _rememberMeCheckbox.value = value ?? false;
  }


  Future<void> handleLogin(BuildContext context) async {
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      errorMessage.value = 'Fill all the blanks';
      return;
    }
    
    setLoading(true.obs);
    try {
      await authService.loginUser(email: emailController.text.trim(), password: passwordController.text);
      _userXp.value = authService.currentUser?.xp ?? 0;
      errorMessage.value = '';
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await SampleDataService().checkExistingData(user.uid);
      }

      if (context.mounted) {
        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      emailController.clear();
      passwordController.clear();
      setLoading(false.obs);
    }
  }

  Future<void> handleAppleSignIn(BuildContext context) async {
    setAppleLoading(true.obs);
    try {
      await authService.signInWithApple();
      if (context.mounted) RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
    } catch (e) {
      debugPrint('$e');
    } finally {
      setAppleLoading(false.obs);
    }
  }

  Future<void> handleDeleteAccount(BuildContext context, {required String password}) async {
    setLoading(true.obs);
    errorMessage.value = "";
    try {
      final user = authService.firebaseUser;
      if (user == null) {
        errorMessage.value = 'user not found';
        return;
      }
      final credential = EmailAuthProvider.credential(email: user.email!, password: password);

      await user.reauthenticateWithCredential(credential);
      await authService.deleteUserAccount();
      await user.delete();

      if (context.mounted) {
        SnackMessages().showSuccessSnack("Account has been deleted successfully");
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        errorMessage.value = "Hesap silme hatası";
        if(e.code == 'wrong-password') {
          errorMessage.value = "Yanlış parola";
        } else if(e.code == "requires-recent-login"){
          errorMessage.value = "Tekrar giriş gerekli";
        } else if(e.code == "user-not-found"){
          errorMessage.value = "Kullanıcı bulunamadı";
        }
      }
      rethrow;
    } finally{
      setLoading(false.obs);
    }
  }

  Future<void> handleDeleteGoogleAccount(BuildContext context) async {
    setDeleteGoogleAccountLoading(true.obs);
    errorMessage.value = "";
    try {
      await authService.deleteGoogleAccount();
      if (context.mounted) {
        SnackMessages().showSuccessSnack("messages.successful".tr());
      }
    } on FirebaseAuthException catch  (e) {
      if (context.mounted) {
        errorMessage.value = e.toString();
         if(e.code == "requires-recent-login"){
          errorMessage.value = "requires_login_again".tr();
        }
      }
      rethrow;
    } finally{
      setDeleteGoogleAccountLoading(false.obs);
    }
  }

  Future<void> handleLogout() async {
    setLoading(true.obs);
    try {
      await authService.logout();
    } catch (e) {
      errorMessage.value = '$e';
    } finally {
      emailController.clear();
      passwordController.clear();
      setLoading(false.obs);
    }
  }

  Future<void> handleGoogleSignIn(BuildContext context) async {
    setGoogleLoading(true.obs);
    
    try {
      await authService.signInWithGoogle();
      _userXp.value = authService.currentUser?.xp ?? 0;
      if (context.mounted) {
        RouteHelper.pushAndCloseOther(context, AppNavigation(initialIndex: 0));
      }
    } catch (e) {
      if (context.mounted) {
        String errorMessage = 'error: ${e.toString()}';
        
        if (e.toString().contains('network')) {
          errorMessage = 'network_error';
        } else if (e.toString().contains('account-exists-with-different-credential')) {
          errorMessage = 'account_exists_different_credential';
        } else if (e.toString().contains('invalid-credential')) {
          errorMessage = 'invalid_credential';
        } else if (e.toString().contains('operation-not-allowed')) {
          errorMessage = 'operation_not_allowed';
        } else if (e.toString().contains('user-disabled')) {
          errorMessage = 'user_disabled';
        } else if (e.toString().contains('user-not-found')) {
          errorMessage = 'user_not_found_google';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.redAccent,
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    } finally {
      setGoogleLoading(false.obs);
    }
  }
}