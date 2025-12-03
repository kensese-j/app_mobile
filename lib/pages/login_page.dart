import 'package:flutter/material.dart';
import '../service/auth_service.dart';
import 'home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  final AuthService auth = AuthService();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ========== CREDENTIALS MANAGEMENT ==========
  void _loadSavedCredentials() {
    // TODO: Implémenter la récupération des identifiants sauvegardés
    // Utiliser SharedPreferences pour "Se souvenir de moi"
  }

  void _saveCredentials() {
    // TODO: Implémenter la sauvegarde sécurisée des identifiants
    // Utiliser SharedPreferences si _rememberMe est true
  }

  // ========== VALIDATION METHODS ==========
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Format d\'email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez entrer votre mot de passe';
    }
    return null;
  }

  // ========== AUTH METHODS ==========
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await auth.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      if (mounted) {
        if (_rememberMe) {
          _saveCredentials();
        }
        
        if (!auth.isEmailVerified) {
          _showEmailVerificationDialog();
          return;
        }
        
        _showSuccessMessage();
        
        await Future.delayed(const Duration(milliseconds: 1000));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _sendVerificationEmail() async {
    try {
      await auth.sendEmailVerification();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email de vérification envoyé !'),
            backgroundColor: Colors.blue.shade600,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    
    if (email.isEmpty) {
      _showErrorMessage('Veuillez entrer votre email pour réinitialiser le mot de passe');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showErrorMessage('Veuillez entrer un email valide');
      return;
    }

    try {
      await auth.sendPasswordResetEmail(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email de réinitialisation envoyé !'),
            backgroundColor: Colors.green.shade600,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage(e.toString());
      }
    }
  }

  // ========== UI FEEDBACK METHODS ==========
  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Connexion réussie !'),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(error)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _showEmailVerificationDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.email_outlined),
            SizedBox(width: 8),
            Text('Vérification requise'),
          ],
        ),
        content: const Text(
          'Votre adresse email n\'a pas été vérifiée. '
          'Voulez-vous recevoir un nouvel email de vérification ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _sendVerificationEmail();
            },
            child: const Text('Recevoir l\'email'),
          ),
        ],
      ),
    );
  }

  // ========== NAVIGATION METHODS ==========
  void _navigateToRegister() {
    if (!_isLoading) {
      Navigator.push(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const RegisterPage(),
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      );
    }
  }

  // ========== UI BUILD ==========
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                
                // Header
                _buildHeader(colorScheme, textTheme),
                const SizedBox(height: 48),

                // Email Field
                _buildEmailField(colorScheme),
                const SizedBox(height: 16),

                // Password Field
                _buildPasswordField(colorScheme),
                const SizedBox(height: 16),

                // Remember me & Forgot password
                _buildRememberMeRow(colorScheme, textTheme),
                const SizedBox(height: 32),

                // Login Button
                _buildLoginButton(colorScheme),
                const SizedBox(height: 32),

                // Divider
                _buildDivider(colorScheme, textTheme),
                const SizedBox(height: 32),

                // Social Login Buttons
                _buildSocialLoginButtons(colorScheme),
                const SizedBox(height: 32),

                // Register Link
                _buildRegisterLink(colorScheme, textTheme),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ========== WIDGET BUILDING METHODS ==========
  Widget _buildHeader(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              size: 40,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Content de vous revoir !",
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Connectez-vous à votre compte",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: "Email",
        prefixIcon: Icon(Icons.email_outlined, color: colorScheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: _validateEmail,
      autovalidateMode: AutovalidateMode.onUserInteraction,
    );
  }

  Widget _buildPasswordField(ColorScheme colorScheme) {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: "Mot de passe",
        prefixIcon: Icon(Icons.lock_outline, color: colorScheme.onSurfaceVariant),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: colorScheme.onSurfaceVariant,
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: _validatePassword,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      onFieldSubmitted: (_) => _login(),
    );
  }

  Widget _buildRememberMeRow(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Transform.scale(
          scale: 0.9,
          child: Checkbox.adaptive(
            value: _rememberMe,
            onChanged: _isLoading 
                ? null 
                : (value) => setState(() => _rememberMe = value ?? false),
          ),
        ),
        GestureDetector(
          onTap: _isLoading 
              ? null 
              : () => setState(() => _rememberMe = !_rememberMe),
          child: Text(
            "Se souvenir de moi",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: _isLoading ? null : _resetPassword,
          child: Text(
            "Mot de passe oublié ?",
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: _isLoading ? null : _login,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : const Text(
                "Se connecter",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  Widget _buildDivider(ColorScheme colorScheme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: colorScheme.outline.withOpacity(0.4),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            "Ou",
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: colorScheme.outline.withOpacity(0.4),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildSocialLoginButtons(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Google Button
        IconButton.filledTonal(
          onPressed: () async {
            final user = await auth.signInWithGoogle();
            if (user != null && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          },
          icon: Image.network(
            "https://upload.wikimedia.org/wikipedia/commons/0/09/IOS_Google_icon.png",
            width: 28,
            height: 28,
          ),
          style: IconButton.styleFrom(
            fixedSize: const Size(58, 58),
            backgroundColor: colorScheme.surface,
          ),
        ),
        const SizedBox(width: 20),
        // GitHub Button
        IconButton.filledTonal(
          onPressed: () async {
            final user = await auth.signInWithGithub();
            if (user != null && mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomePage()),
              );
            }
          },
          icon: Image.network(
            "https://github.githubassets.com/images/modules/logos_page/GitHub-Mark.png",
            width: 28,
            height: 28,
          ),
          style: IconButton.styleFrom(
            fixedSize: const Size(58, 58),
            backgroundColor: colorScheme.surface,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterLink(ColorScheme colorScheme, TextTheme textTheme) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            "Nouveau ici ? ",
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          GestureDetector(
            onTap: _navigateToRegister,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Text(
                "Créer un compte",
                style: TextStyle(
                  color: colorScheme.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}