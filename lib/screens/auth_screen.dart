import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_messaging/firebase_messaging.dart';
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
  bool _googleSignInReady = false;
  bool _googleSignInInitialized = false;
  late final Future<void> _googleSignInInitFuture;

  @override
  void initState() {
    super.initState();
    _googleSignInInitFuture = _initializeGoogleSignIn();
  }

  Future<void> _initializeGoogleSignIn() async {
    try {
      await GoogleSignIn.instance.initialize(
        serverClientId:
                defaultTargetPlatform == TargetPlatform.android
                    ? _androidServerClientId
                    : null,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _googleSignInReady = GoogleSignIn.instance.supportsAuthenticate();
        _googleSignInInitialized = true;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _googleSignInReady = false;
        _googleSignInInitialized = true;
      });
    }
  }

  Future<void> _signInWithGoogle() async {
    await _googleSignInInitFuture;

    if (!_googleSignInReady) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Google Sign-In no esta disponible en esta plataforma.',
          ),
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
      if (!_googleSignInInitialized) ...[
        const SizedBox(height: 16),
        const Center(child: CircularProgressIndicator()),
      ] else if (_googleSignInReady) ...[
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

  Future<void> _initUserDoc(User user) async {
    final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final doc = await docRef.get();
    final token = await FirebaseMessaging.instance.getToken();

    if (!doc.exists) {
      await docRef.set({
        'email': user.email,
        'username': null,
        'avatarUrl': null,
        'birthday': null,
        'deviceToken': token,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(
            providers: [EmailAuthProvider()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        size: 96,
                      ),
                    ),
                  ),
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
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primaryContainer,
                          Theme.of(context).colorScheme.secondaryContainer,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 96,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }

        return FutureBuilder(
          future: _initUserDoc(snapshot.data!),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return const TabsScreen();
          },
        );
      },
    );
  }
}
