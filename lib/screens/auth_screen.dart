import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'package:proyecto_recetas/screens/tabs.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  static const String _androidServerClientId =
      '656746746040-6ohogpj2t3cpr98q277bc93ipfhnmfit.apps.googleusercontent.com';
  bool _googleSignInLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      return;
    }

    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
            defaultTargetPlatform == TargetPlatform.android
                ? _androidServerClientId
                : null,
      );
    } catch (_) {
      // If initialization fails, the manual button still handles the error.
    }
  }

  Future<void> _signInWithGoogle() async {
    if (!GoogleSignIn.instance.supportsAuthenticate()) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Sign-In no esta disponible en esta plataforma.'),
        ),
      );
      return;
    }

    setState(() {
      _googleSignInLoading = true;
    });

    try {
      final GoogleSignInAccount googleUser =
          await GoogleSignIn.instance.authenticate();
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.description ?? 'No se pudo iniciar sesion con Google.',
            ),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.message ?? 'Firebase no pudo completar el inicio con Google.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo iniciar sesion con Google.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _googleSignInLoading = false;
        });
      }
    }
  }

  Widget _buildGoogleButton(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _googleSignInLoading ? null : _signInWithGoogle,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          side: BorderSide(color: theme.colorScheme.outlineVariant),
          backgroundColor: theme.colorScheme.surface,
          foregroundColor: theme.colorScheme.onSurface,
        ),
        child: _googleSignInLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.account_circle_outlined),
                  SizedBox(width: 12),
                  Text('Continuar con Google'),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, AuthAction _) {
    final children = <Widget>[
      if (GoogleSignIn.instance.supportsAuthenticate()) ...[
        const SizedBox(height: 16),
        _buildGoogleButton(context),
      ] else ...[
        const SizedBox(height: 16),
        const Text(
          'Google Sign-In no esta habilitado para esta plataforma en esta compilacion.',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
      const SizedBox(height: 16),
      const Text(
        'By signing in, you agree to our terms and conditions.',
        style: TextStyle(color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return const TabsScreen();
        }

        return SignInScreen(
          providers: [
            EmailAuthProvider(),
          ],
          headerBuilder: (context, constraints, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/images/photo_1.jpg'),
              ),
            );
          },
          subtitleBuilder: (context, action) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: action == AuthAction.signIn
                  ? const Text('Welcome to FlutterFire, please sign in!')
                  : const Text('Welcome to Flutterfire, please sign up!'),
            );
          },
          footerBuilder: _buildFooter,
          sideBuilder: (context, shrinkOffset) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.asset('assets/images/photo_1.jpg'),
              ),
            );
          },
        );
      },
    );
  }
}
