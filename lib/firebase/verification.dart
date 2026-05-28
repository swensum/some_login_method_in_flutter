import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'loginpage.dart';
import '../sqllite/profile.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String userEmail;
  const VerifyEmailScreen({super.key, required this.userEmail});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthService _authService = AuthService();
  bool _isResending = false;
  bool _isAutoChecking = true;
  
  @override
  void initState() {
    super.initState();
    _startAutoVerificationCheck();
  }

  @override
  void dispose() {
    _isAutoChecking = false;
    super.dispose();
  }

  void _startAutoVerificationCheck() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_isAutoChecking && mounted) {
        _checkEmailVerified();
      }
    });
  }

  Future<void> _checkEmailVerified() async {
    try {
      await _authService.reloadUser();
      
      final user = _authService.currentUser;
      if (user != null && user.emailVerified) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Email verified! Redirecting to login...'), 
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
          
          
          
         if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomePage()), 
              (route) => false,
            );
          }
        }
      } else if (mounted && _isAutoChecking) {
        _startAutoVerificationCheck();
      }
    } catch (e) {
      if (mounted && _isAutoChecking) {
        _startAutoVerificationCheck();
      }
    }
  }

  Future<void> _resendVerificationEmail() async {
    if (_isResending) return;
    setState(() => _isResending = true);
    
    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception("No user signed in");
      
      await _authService.sendEmailVerification();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent!'), 
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _logoutAndGoToLogin() async {
    _isAutoChecking = false;
    await _authService.signOut();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const Loginpage2()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: const Icon(
                  Icons.mark_email_unread, 
                  size: 120, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              
              Text(
                'Verification sent to:',
                style: TextStyle(fontSize: 16, color: Colors.grey[400]),
              ),
              const SizedBox(height: 8),
              
              Text(
                widget.userEmail,
                style: const TextStyle(
                  fontSize: 18, 
                  fontWeight: FontWeight.bold, 
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              // Auto-scan indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Auto-scanning for verification...',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Resend button
              ElevatedButton.icon(
                onPressed: _isResending ? null : _resendVerificationEmail,
                icon: _isResending 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                    : const Icon(Icons.email),
                label: Text(_isResending ? 'Sending...' : 'Resend Verification Email', style: const TextStyle(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, 
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              
              TextButton(
                onPressed: _logoutAndGoToLogin, 
                child: const Text('Back to Login', style: TextStyle(color: Colors.orange)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}