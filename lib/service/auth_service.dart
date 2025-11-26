import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // User profile changes stream
  Stream<User?> get userChanges => _auth.userChanges();

  Future<User?> register(String email, String password, {String? displayName}) async {
    try {
      debugPrint('Attempting to register user: $email');
      
      // Create user with email and password
      final UserCredential creds = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update profile with display name if provided
      if (displayName != null && displayName.trim().isNotEmpty) {
        await creds.user?.updateDisplayName(displayName.trim());
        
        // Reload user to get updated profile
        await creds.user?.reload();
        
        debugPrint('User profile updated with display name: $displayName');
      }

      debugPrint('User registered successfully: ${creds.user?.uid}');
      return creds.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during registration: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during registration: $e');
      throw 'Une erreur inattendue s\'est produite lors de l\'inscription';
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      debugPrint('Attempting to login user: $email');
      
      final UserCredential creds = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      debugPrint('User logged in successfully: ${creds.user?.uid}');
      return creds.user;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during login: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during login: $e');
      throw 'Une erreur inattendue s\'est produite lors de la connexion';
    }
  }

  Future<void> logout() async {
    try {
      debugPrint('Attempting to logout user: ${_auth.currentUser?.uid}');
      await _auth.signOut();
      debugPrint('User logged out successfully');
    } catch (e) {
      debugPrint('Error during logout: $e');
      throw 'Erreur lors de la déconnexion';
    }
  }

  // Password reset functionality
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('Sending password reset email to: $email');
      await _auth.sendPasswordResetEmail(email: email.trim());
      debugPrint('Password reset email sent successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during password reset: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      throw 'Une erreur inattendue s\'est produite lors de l\'envoi de l\'email de réinitialisation';
    }
  }

  // Update user profile
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    try {
      debugPrint('Updating user profile for: ${_auth.currentUser?.uid}');
      
      await _auth.currentUser?.updateDisplayName(displayName);
      if (photoURL != null) {
        await _auth.currentUser?.updatePhotoURL(photoURL);
      }
      
      // Reload to get updated user data
      await _auth.currentUser?.reload();
      
      debugPrint('User profile updated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during profile update: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during profile update: $e');
      throw 'Une erreur inattendue s\'est produite lors de la mise à jour du profil';
    }
  }

  // Update user email
  Future<void> updateEmail(String newEmail) async {
    try {
      debugPrint('Updating email for user: ${_auth.currentUser?.uid}');
      await _auth.currentUser?.verifyBeforeUpdateEmail(newEmail.trim());
      debugPrint('Email update initiated successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during email update: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during email update: $e');
      throw 'Une erreur inattendue s\'est produite lors de la mise à jour de l\'email';
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      debugPrint('Deleting account for user: ${_auth.currentUser?.uid}');
      await _auth.currentUser?.delete();
      debugPrint('Account deleted successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during account deletion: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during account deletion: $e');
      throw 'Une erreur inattendue s\'est produite lors de la suppression du compte';
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => _auth.currentUser != null;

  // Get user display name
  String? get userDisplayName => _auth.currentUser?.displayName;

  // Get user email
  String? get userEmail => _auth.currentUser?.email;

  // Get user ID
  String? get userId => _auth.currentUser?.uid;

  // Get user photo URL
  String? get userPhotoUrl => _auth.currentUser?.photoURL;

  // Check if email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      debugPrint('Sending email verification for user: ${_auth.currentUser?.uid}');
      await _auth.currentUser?.sendEmailVerification();
      debugPrint('Email verification sent successfully');
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuthException during email verification: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('Unexpected error during email verification: $e');
      throw 'Une erreur inattendue s\'est produite lors de l\'envoi de la vérification d\'email';
    }
  }

  // Reload user data
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      debugPrint('Error reloading user: $e');
    }
  }

  // Helper method to handle FirebaseAuthException
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé par un autre compte';
      case 'invalid-email':
        return 'L\'adresse email est invalide';
      case 'operation-not-allowed':
        return 'La connexion par email/mot de passe n\'est pas activée';
      case 'weak-password':
        return 'Le mot de passe est trop faible';
      case 'user-disabled':
        return 'Ce compte a été désactivé';
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email';
      case 'wrong-password':
        return 'Mot de passe incorrect';
      case 'too-many-requests':
        return 'Trop de tentatives de connexion. Veuillez réessayer plus tard';
      case 'network-request-failed':
        return 'Erreur de connexion réseau. Vérifiez votre connexion internet';
      case 'requires-recent-login':
        return 'Cette opération nécessite une reconnexion récente';
      default:
        return 'Erreur d\'authentification: ${e.message ?? e.code}';
    }
  }
}