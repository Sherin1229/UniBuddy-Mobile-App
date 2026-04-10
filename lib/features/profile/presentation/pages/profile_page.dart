import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../shared/widgets/animated_app_background.dart';
import 'resource_analytics_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  AutovalidateMode _autoValidateMode = AutovalidateMode.disabled;

  final _fullNameController = TextEditingController(text: 'Silomy A C S');
  final _emailController = TextEditingController(
    text: 'it23774070@my.sliit.lk',
  );
  final _studentIdController = TextEditingController(text: 'IT23774070');
  final _universityController = TextEditingController(text: 'SLIIT');
  final _facultyController = TextEditingController(
    text: 'Faculty of Computing',
  );
  final _phoneController = TextEditingController(text: '+94 71 234 5678');
  final _bioController = TextEditingController(
    text: 'Third-year undergraduate student',
  );

  static const _years = [
    'Year 1',
    'Year 2',
    'Year 3',
    'Year 4',
    'Postgraduate',
  ];

  String _selectedYear = 'Year 3';
  bool _isLoadingProfile = true;
  bool _isSavingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _studentIdController.dispose();
    _universityController.dispose();
    _facultyController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();

      if (!mounted) {
        return;
      }

      if (data != null) {
        _fullNameController.text =
            (data['fullName'] ?? '').toString().trim().isEmpty
            ? (_fullNameController.text)
            : (data['fullName'] ?? '').toString();
        _emailController.text = (data['email'] ?? '').toString().trim().isEmpty
            ? (user.email ?? _emailController.text)
            : (data['email'] ?? '').toString();
        _studentIdController.text = (data['studentId'] ?? '').toString();
        _universityController.text = (data['university'] ?? '').toString();
        _facultyController.text = (data['faculty'] ?? '').toString();
        _phoneController.text = (data['phone'] ?? '').toString();
        _bioController.text = (data['bio'] ?? '').toString();

        final year = (data['academicYear'] ?? '').toString();
        if (_years.contains(year)) {
          _selectedYear = year;
        }
      } else if (user.email != null && user.email!.isNotEmpty) {
        _emailController.text = user.email!;
      }
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load profile data. Showing local values.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autoValidateMode = AutovalidateMode.always);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please correct the highlighted fields.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    if (_isSavingProfile) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to save your profile.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
      return;
    }

    setState(() {
      _isSavingProfile = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'studentId': _studentIdController.text.trim(),
        'university': _universityController.text.trim(),
        'faculty': _facultyController.text.trim(),
        'academicYear': _selectedYear,
        'phone': _phoneController.text.trim(),
        'bio': _bioController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await user.updateDisplayName(_fullNameController.text.trim());

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile saved successfully.'),
          backgroundColor: Color(0xFF15803D),
        ),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save profile. Please try again.'),
          backgroundColor: Color(0xFFB91C1C),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSavingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryBrand = Color(0xFF0F766E);

    return Scaffold(
      backgroundColor: const Color(0xFFE6FFFB),
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: primaryBrand,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          const Positioned.fill(
            child: AnimatedAppBackground(
              durationSeconds: 24,
              motionScale: 0.8,
              opacityScale: 0.95,
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              autovalidateMode: _autoValidateMode,
              child: Opacity(
                opacity: _isLoadingProfile ? 0.7 : 1,
                child: IgnorePointer(
                  ignoring: _isLoadingProfile || _isSavingProfile,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFF0FDFA).withOpacity(0.95),
                          const Color(0xFFDDF7F4).withOpacity(0.9),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF99F6E4).withOpacity(0.65),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: Color(0xFFE6FFFB),
                              child: Icon(
                                Icons.person,
                                size: 30,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Student Profile',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Keep your details updated for group and resource collaboration.',
                                    style: TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ResourceAnalyticsPage(),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF115E59,
                                  ).withOpacity(0.28),
                                  blurRadius: 16,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(
                                        Icons.analytics_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    const Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Resource Analytics',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w800,
                                              fontSize: 16,
                                            ),
                                          ),
                                          SizedBox(height: 2),
                                          Text(
                                            'Track your impact across the library',
                                            style: TextStyle(
                                              color: Color(0xFFCCFBF1),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: const [
                                    _AnalyticsPreviewChip(
                                      icon: Icons.upload_file_rounded,
                                      label: 'Uploads',
                                    ),
                                    _AnalyticsPreviewChip(
                                      icon: Icons.download_rounded,
                                      label: 'Downloads',
                                    ),
                                    _AnalyticsPreviewChip(
                                      icon: Icons.visibility_rounded,
                                      label: 'Views',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildField(
                          controller: _fullNameController,
                          label: 'Full Name *',
                          icon: Icons.badge_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Full name is required.';
                            if (text.length < 3) {
                              return 'Full name must be at least 3 characters.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _emailController,
                          label: 'University Email *',
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Email is required.';
                            final isEmail = RegExp(
                              r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                            ).hasMatch(text);
                            if (!isEmail) return 'Enter a valid email address.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _studentIdController,
                          label: 'Student ID *',
                          icon: Icons.perm_identity_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'Student ID is required.';
                            if (text.length < 5)
                              return 'Enter a valid student ID.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _universityController,
                          label: 'University *',
                          icon: Icons.school_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) return 'University is required.';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _facultyController,
                          label: 'Faculty / Department *',
                          icon: Icons.account_balance_outlined,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty) {
                              return 'Faculty or department is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedYear,
                          decoration: _inputDecoration(
                            label: 'Academic Year *',
                            icon: Icons.calendar_month_outlined,
                          ),
                          items: _years
                              .map(
                                (year) => DropdownMenuItem(
                                  value: year,
                                  child: Text(year),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedYear = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _phoneController,
                          label: 'Phone Number *',
                          icon: Icons.phone_outlined,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            final text = value?.trim() ?? '';
                            if (text.isEmpty)
                              return 'Phone number is required.';
                            final numbers = text.replaceAll(
                              RegExp(r'[^0-9]'),
                              '',
                            );
                            if (numbers.length < 9) {
                              return 'Enter a valid phone number.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          controller: _bioController,
                          label: 'Bio',
                          icon: Icons.edit_note_outlined,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton.icon(
                          onPressed: _saveProfile,
                          icon: _isSavingProfile
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.save_outlined),
                          label: Text(
                            _isSavingProfile ? 'Saving...' : 'Save Profile',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBrand,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_isLoadingProfile)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: CircularProgressIndicator(color: Color(0xFF0F766E)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: _inputDecoration(label: label, icon: icon),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white.withOpacity(0.85),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.6),
      ),
    );
  }
}

class _AnalyticsPreviewChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AnalyticsPreviewChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.16),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
