import 'package:flutter/material.dart';
import 'package:test/models/database.dart';
import 'package:test/models/user.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController customQuestionController = TextEditingController();
  final TextEditingController securityAnswerController = TextEditingController();
  
  bool _isLoading = false;
  bool _obscurePassword = true;  
  bool _obscureConfirmPassword = true; 
  final _formKey = GlobalKey<FormState>();
  
  String? _selectedSecurityQuestion;
  bool _useCustomQuestion = false;

  final List<String> _securityQuestions = [
    'What is your mother\'s maiden name?',
    'What was the name of your first pet?',
    'What is your favorite book?',
    'What city were you born in?',
    'What was your first school?',
    'What is your favorite movie?',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    customQuestionController.dispose();
    securityAnswerController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    return null;
  }
  
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }
    if (value != passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  String? _validateSecurityAnswer(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please provide an answer to your security question';
    }
    if (value.length < 2) {
      return 'Answer must be at least 2 characters';
    }
    return null;
  }

  String? _validateSecurityQuestion() {
    if (!_useCustomQuestion && _selectedSecurityQuestion == null) {
      return 'Please select a security question';
    }
    if (_useCustomQuestion && customQuestionController.text.trim().isEmpty) {
      return 'Please enter your security question';
    }
    return null;
  }

  Future<void> signupUser() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Validate security question separately
    final questionError = _validateSecurityQuestion();
    if (questionError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(questionError),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim().toLowerCase();
      final password = passwordController.text;
      
      // Get security question
      final securityQuestion = _useCustomQuestion 
          ? customQuestionController.text.trim()
          : _selectedSecurityQuestion;
      
      // Get security answer (store in lowercase for case-insensitive comparison)
      final securityAnswer = securityAnswerController.text.trim().toLowerCase();

      // Create user with security question and answer
      final user = UserModel(
        name: name, 
        email: email, 
        password: password,
        securityQuestion: securityQuestion,
        securityAnswer: securityAnswer,
      );

      await DatabaseHelper.instance.createUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Clear form
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();
      customQuestionController.clear();
      securityAnswerController.clear();
      setState(() {
        _selectedSecurityQuestion = null;
        _useCustomQuestion = false;
      });

      // Wait a moment to show the snackbar
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate back to login
      if (mounted) {
        Navigator.pop(context, true); // Pass true to indicate success
      }
    } catch (e, stackTrace) {
      debugPrint("❌ ERROR: $e");
      debugPrint(stackTrace.toString());

      String errorMessage = 'An error occurred. Please try again.';

      // Handle specific error messages
      if (e.toString().contains('Email already registered')) {
        errorMessage = 'This email is already registered. Please use a different email or login.';
      } else if (e.toString().contains('UNIQUE constraint failed')) {
        errorMessage = 'This email is already registered. Please use a different email.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.flutter_dash, size: 100, color: Colors.white),
                  const SizedBox(height: 20),
                  const Text(
                    'Signup Page',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Full Name Field
                  TextFormField(
                    controller: nameController,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Full Name',
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Email Field
                  TextFormField(
                    controller: emailController,
                    enabled: !_isLoading,
                    validator: _validateEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Password Field
                  TextFormField(
                    controller: passwordController,
                    enabled: !_isLoading,
                    validator: _validatePassword,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Password',                             
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),     
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Confirm Password Field
                  TextFormField(
                    controller: confirmPasswordController,
                    enabled: !_isLoading,
                    validator: _validateConfirmPassword,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      hintText: 'Confirm Password',                             
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8)),     
                        borderSide: BorderSide.none,
                      ),
                      errorStyle: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Security Question Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Security Question (For password recovery)',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Security Question Dropdown
                        DropdownButtonFormField<String>(
                          value: _useCustomQuestion ? null : _selectedSecurityQuestion,
                          hint: const Text('Select a security question'),
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: [
                            ..._securityQuestions.map((question) {
                              return DropdownMenuItem(
                                value: question,
                                child: Text(question),
                              );
                            }),
                            const DropdownMenuItem(
                              value: 'custom',
                              child: Text('✏️ Write my own question...'),
                            ),
                          ],
                          onChanged: _isLoading ? null : (value) {
                            setState(() {
                              if (value == 'custom') {
                                _useCustomQuestion = true;
                                _selectedSecurityQuestion = null;
                              } else {
                                _useCustomQuestion = false;
                                _selectedSecurityQuestion = value;
                                customQuestionController.clear();
                              }
                            });
                          },
                        ),
                        
                        // Custom Question Field
                        if (_useCustomQuestion) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: customQuestionController,
                            enabled: !_isLoading,
                            maxLines: 2,
                            decoration: const InputDecoration(
                              hintText: 'Enter your custom security question',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.edit_note, color: Colors.grey),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ],
                        
                        const SizedBox(height: 16),
                        
                        // Security Answer Field
                        TextFormField(
                          controller: securityAnswerController,
                          enabled: !_isLoading,
                          validator: _validateSecurityAnswer,
                          decoration: const InputDecoration(
                            hintText: 'Answer to your security question',
                            hintStyle: TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(Icons.question_answer, color: Colors.grey),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        const Text(
                          '⚠️ Save this answer! You\'ll need it to reset your password.',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Sign Up Button
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: signupUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  
                  // Back to Login Button
                  TextButton(
                    onPressed: _isLoading ? null : () => Navigator.pop(context),
                    child: const Text(
                      'Already have an account? Login',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}