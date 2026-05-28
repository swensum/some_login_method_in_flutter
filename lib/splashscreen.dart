// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:test/sqllite/login.dart';
// import 'package:test/sqllite/profile.dart';

// class Splashscreen extends StatefulWidget {
//   const Splashscreen({super.key});

//   @override
//   State<Splashscreen> createState() => _SplashscreenState();
// }

// class _SplashscreenState extends State<Splashscreen> {
//   @override
//   void initState() {
//     super.initState();
// _checkLoginStatus();
//   }
//    Future<void> _checkLoginStatus() async {
//     await Future.delayed(const Duration(seconds: 3)); 
//     final prefs = await SharedPreferences.getInstance();
//     final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//     if (mounted) {
//       if (isLoggedIn) {
//        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
//       } else {
//         Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const Loginpage()));
//       }
//     }
//    }
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0A1929), 
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//           Icon(
//             Icons.flutter_dash,
//             size: 100,
//             color: Colors.white,
//           ),
//           SizedBox(height: 20),
//           Text(
//             'Welcome to My App',
//             style: TextStyle(
//               fontSize: 24,
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           ],
//         ),
//       ),
//     );
//   }
// }




//=-----------------------firebase-----------------------//
import 'package:flutter/material.dart';
import 'firebase/auth_service.dart';
import 'firebase/loginpage.dart';
import 'firebase/verification.dart';
import 'sqllite/profile.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait 2 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    
    // Get current user
    final user = _authService.currentUser;
    
    if (user != null) {
      // User is logged in
      if (user.emailVerified) {
        // Email verified - go to homepage
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        // Email not verified - go to verification screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => VerifyEmailScreen(userEmail: user.email ?? ''),
          ),
        );
      }
    } else {
      // No user logged in - go to login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Loginpage2()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1929), 
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.flutter_dash,
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'Welcome to My App',
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}