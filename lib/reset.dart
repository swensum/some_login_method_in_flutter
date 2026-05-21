import 'package:flutter/material.dart';
import 'package:test/models/database.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isLoading = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  
  // Step tracking
  int _step = 1; // 1=Email, 2=Security Question, 3=New Password
  String _userEmail = '';
  String _securityQuestion = '';

  @override
  void dispose() {
    _emailController.dispose();
    _answerController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // Step 1: Check email and get security question
  Future<void> _checkEmail() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final email = _emailController.text.trim().toLowerCase();
      final exists = await DatabaseHelper.instance.isEmailExists(email);
      
      if (!exists) {
        _showMessage('Email not found', Colors.red);
        setState(() => _isLoading = false);
        return;
      }
      
      final question = await DatabaseHelper.instance.getSecurityQuestion(email);
      
      if (question == null || question.isEmpty) {
        _showMessage('No security question found', Colors.orange);
        setState(() => _isLoading = false);
        return;
      }
      
      _userEmail = email;
      _securityQuestion = question;
      setState(() {
        _step = 2;
        _isLoading = false;
      });
      
    } catch (e) {
      _showMessage('Error: ${e.toString()}', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // Step 2: Verify security answer
  Future<void> _verifyAnswer() async {
    if (_answerController.text.trim().isEmpty) {
      _showMessage('Please answer the security question', Colors.red);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final isCorrect = await DatabaseHelper.instance.verifySecurityAnswer(
        _userEmail, 
        _answerController.text.trim()
      );
      
      if (!isCorrect) {
        _showMessage('Incorrect answer', Colors.red);
        setState(() => _isLoading = false);
        return;
      }
      
      setState(() {
        _step = 3;
        _isLoading = false;
      });
      
    } catch (e) {
      _showMessage('Error: ${e.toString()}', Colors.red);
      setState(() => _isLoading = false);
    }
  }

  // Step 3: Reset password
  Future<void> _resetPassword() async {
    final newPass = _newPasswordController.text;
    final confirmPass = _confirmPasswordController.text;
    
    if (newPass.isEmpty) {
      _showMessage('Enter new password', Colors.red);
      return;
    }
    if (newPass.length < 6) {
      _showMessage('Password must be at least 6 characters', Colors.red);
      return;
    }
    if (newPass != confirmPass) {
      _showMessage('Passwords do not match', Colors.red);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final success = await DatabaseHelper.instance.updatePassword(_userEmail, newPass);
      
      if (success) {
        _showMessage('Password reset successful!', Colors.green);
        Future.delayed(const Duration(seconds: 2), () => Navigator.pop(context));
      } else {
        throw Exception('Failed to update');
      }
      
    } catch (e) {
      _showMessage('Reset failed: ${e.toString()}', Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A1929),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Reset Password', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Step 1: Email
                  if (_step == 1) ...[
                    const Icon(Icons.lock_reset, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text('Reset Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    const Text('Enter your email address', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      validator: (v) => v == null || v.isEmpty ? 'Enter email' : null,
                      decoration: const InputDecoration(
                        hintText: 'Email',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading 
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _checkEmail,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, minimumSize: const Size(double.infinity, 50)),
                          child: const Text('Continue', style: TextStyle(color: Colors.white)),
                        ),
                  ],
                  
                  // Step 2: Security Question
                  if (_step == 2) ...[
                    const Icon(Icons.security, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text('Security Verification', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(_userEmail, style: const TextStyle(color: Colors.blue)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_securityQuestion, style: const TextStyle(color: Colors.white, fontSize: 16), textAlign: TextAlign.center),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _answerController,
                      decoration: const InputDecoration(
                        hintText: 'Your answer',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.question_answer),
                        border: OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading) 
                   const CircularProgressIndicator()
else
  Row(
    children: [
      Expanded(
        child: TextButton(
          onPressed: () => setState(() => _step = 1),
          style: TextButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue, width: 1.5), // Border only
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12), // Smaller height
          ),
          child: const Text('Back'),
        ),
      ),
      const SizedBox(width: 12), // Gap between buttons
      Expanded(
        child: ElevatedButton(
          onPressed: _verifyAnswer,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12), // Smaller height
          ),
          child: const Text('Verify'),
        ),
      ),
    ],
  ),
                  ],
                  
                  // Step 3: New Password
                  if (_step == 3) ...[
                    const Icon(Icons.password, size: 80, color: Colors.white),
                    const SizedBox(height: 20),
                    const Text('New Password', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        hintText: 'New password (min 6 chars)',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(
                          icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _showPassword = !_showPassword),
                        ),
                        border: const OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_showConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'Confirm password',
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_showConfirmPassword ? Icons.visibility : Icons.visibility_off),
                          onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                        ),
                        border: const OutlineInputBorder(borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 30),
                    if (_isLoading)
                     const CircularProgressIndicator()
else
  Row(
    children: [
      Expanded(
        child: OutlinedButton(  // Using OutlinedButton for border-only style
          onPressed: () => setState(() => _step = 2),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.blue,
            side: const BorderSide(color: Colors.blue, width: 1.5), // Blue border only
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), // Smaller height
          ),
          child: const Text('Back', style: TextStyle(fontSize: 14)),
        ),
      ),
      const SizedBox(width: 12), // Gap between buttons
      Expanded(
        child: ElevatedButton(
          onPressed: _resetPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green, // Keeping original green color
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10), // Smaller height
          ),
          child: const Text('Reset', style: TextStyle(fontSize: 14)),
        ),
      ),
    ],
  ),
                  ],
                  
                  const SizedBox(height: 20),
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Back to Login', style: TextStyle(color: Colors.blue))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}