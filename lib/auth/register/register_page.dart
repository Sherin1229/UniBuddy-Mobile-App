import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateFullName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Full name is required';
    }
    if (name.length < 2) {
      return 'Full name must be at least 2 characters';
    }
    if (!RegExp(r'^[A-Za-z][A-Za-z\s\.-]*$').hasMatch(name)) {
      return 'Enter a valid full name';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Password must contain at least 1 uppercase letter';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'Password must contain at least 1 lowercase letter';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Password must contain at least 1 number';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final confirmPassword = value ?? '';
    if (confirmPassword.isEmpty) {
      return 'Please confirm your password';
    }
    if (confirmPassword != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> _submitRegistration() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _autoValidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    if (_isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final fullName = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password)
          .timeout(
            _requestTimeout,
            onTimeout: () {
              throw TimeoutException(
                'Registration is taking too long. Please try again.',
              );
            },
          );

      final user = userCredential.user;
      if (user != null) {
        unawaited(
          user.updateDisplayName(fullName).timeout(_requestTimeout).catchError((
            error,
          ) {
            debugPrint('Failed to update display name: $error');
          }),
        );

        unawaited(
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .set({
                'uid': user.uid,
                'fullName': fullName,
                'email': email,
                'createdAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true))
              .timeout(_requestTimeout)
              .catchError((error) {
                debugPrint('Failed to save user profile: $error');
              }),
        );
      }

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully')),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
        (route) => false,
      );
    } on TimeoutException {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Registration is taking too long. Check your connection and try again.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) {
        return;
      }

      final message = switch (e.code) {
        'email-already-in-use' => 'This email is already in use',
        'invalid-email' => 'Email address is invalid',
        'weak-password' => 'Password is too weak',
        'network-request-failed' =>
          'Network error. Check your connection and try again',
        _ => e.message ?? 'Registration failed. Please try again',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Brand Colors
    const Color primaryBrand = Color(0xFF0F766E);
    const Color accentButton = Color(0xFF14B8A6);

    // Background Colors
    const Color cardBackground = Color(0xFFFFFFFF);
    const Color borderColor = Color(0xFFE2E8F0);

    // Text Colors
    const Color primaryText = Color(0xFF1E293B);
    const Color secondaryText = Color(0xFF475569);

    return Scaffold(
      body: Container(
        // Background Image Setup
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/login_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          // Teal & Dark overlay to blend image with brand color
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                primaryBrand.withOpacity(0.7),
                const Color(
                  0xFF042F2E,
                ).withOpacity(0.9), // Darker teal shade for bottom
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Header Section (App Name)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: const Center(
                        child: Text(
                          'UniBuddy',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            shadows: [
                              Shadow(
                                color: Colors.black26,
                                offset: Offset(0, 4),
                                blurRadius: 8.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16.0),

                    // Glassmorphism Register Card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28.0),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
                          child: Container(
                            padding: const EdgeInsets.all(32.0),
                            decoration: BoxDecoration(
                              color: cardBackground.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(28.0),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 30.0,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Title
                                const Center(
                                  child: Text(
                                    'Create Account',
                                    style: TextStyle(
                                      color: primaryText,
                                      fontSize: 26.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 32.0),

                                Form(
                                  key: _formKey,
                                  autovalidateMode: _autoValidateMode,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Full Name Input Field
                                      TextFormField(
                                        controller: _nameController,
                                        validator: _validateFullName,
                                        decoration: InputDecoration(
                                          hintText: 'Full Name',
                                          hintStyle: const TextStyle(
                                            color: secondaryText,
                                          ),
                                          filled: true,
                                          fillColor: cardBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: primaryBrand,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 18.0,
                                              ),
                                        ),
                                        keyboardType: TextInputType.name,
                                        autofillHints: const [
                                          AutofillHints.name,
                                        ],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 20.0),

                                      // Email Input Field
                                      TextFormField(
                                        controller: _emailController,
                                        validator: _validateEmail,
                                        decoration: InputDecoration(
                                          hintText: 'Email',
                                          hintStyle: const TextStyle(
                                            color: secondaryText,
                                          ),
                                          filled: true,
                                          fillColor: cardBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: primaryBrand,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 18.0,
                                              ),
                                        ),
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        autofillHints: const [
                                          AutofillHints.username,
                                          AutofillHints.email,
                                        ],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 20.0),

                                      // Password Input Field
                                      TextFormField(
                                        controller: _passwordController,
                                        validator: _validatePassword,
                                        obscureText: _obscurePassword,
                                        decoration: InputDecoration(
                                          hintText: 'Password',
                                          hintStyle: const TextStyle(
                                            color: secondaryText,
                                          ),
                                          filled: true,
                                          fillColor: cardBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: primaryBrand,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 18.0,
                                              ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: secondaryText,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                          ),
                                        ),
                                        autofillHints: const [
                                          AutofillHints.newPassword,
                                        ],
                                        textInputAction: TextInputAction.next,
                                      ),
                                      const SizedBox(height: 20.0),

                                      // Confirm Password Input Field
                                      TextFormField(
                                        controller: _confirmPasswordController,
                                        validator: _validateConfirmPassword,
                                        obscureText: _obscureConfirmPassword,
                                        decoration: InputDecoration(
                                          hintText: 'Confirm Password',
                                          hintStyle: const TextStyle(
                                            color: secondaryText,
                                          ),
                                          filled: true,
                                          fillColor: cardBackground,
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: borderColor,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(
                                              16.0,
                                            ),
                                            borderSide: const BorderSide(
                                              color: primaryBrand,
                                              width: 2.0,
                                            ),
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 20.0,
                                                vertical: 18.0,
                                              ),
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _obscureConfirmPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: secondaryText,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _obscureConfirmPassword =
                                                    !_obscureConfirmPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) =>
                                            _submitRegistration(),
                                      ),
                                      const SizedBox(height: 32.0),

                                      // Register Button
                                      SizedBox(
                                        width: double.infinity,
                                        height: 56.0,
                                        child: ElevatedButton(
                                          onPressed: _isSubmitting
                                              ? null
                                              : _submitRegistration,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: accentButton,
                                            foregroundColor: Colors.white,
                                            elevation: 8,
                                            shadowColor: accentButton
                                                .withOpacity(0.5),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16.0),
                                            ),
                                          ),
                                          child: _isSubmitting
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                        color: Colors.white,
                                                      ),
                                                )
                                              : const Text(
                                                  'Register',
                                                  style: TextStyle(
                                                    fontSize: 18.0,
                                                    fontWeight: FontWeight.bold,
                                                    letterSpacing: 0.5,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32.0),

                    // Bottom Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Already have an account? ",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16.0,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              color: accentButton,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32.0),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
