import 'dart:io';

import 'package:flutter/material.dart';
import 'package:musik_streaming_app/main.dart';
import 'package:musik_streaming_app/screens/forgot_password_screen.dart';
import 'package:musik_streaming_app/screens/songs_screen.dart';
import 'dart:ui';
import 'dart:async';
import "package:musik_streaming_app/services/auth_service.dart";
import 'package:musik_streaming_app/screens/sign_up_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SigninScreenState createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _positionAnimation;
  late Animation<double> _sizeAnimation;

  late AnimationController _gradientController;
  // ignore: unused_field
  late Animation<Color?> _gradientColorAnimation;

  late StreamController<Offset> _particleStreamController;
  final List<Offset> _particles = [];
  late AnimationController _buttonAnimationController;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isNotShowingPassword = true;

  final AuthService _authService = AuthService();
  @override
  void initState() {
    super.initState();
    _emailController.text = "1@gmail.com";
    _passwordController.text = "raean11221122";

    // Ball Animation Controller
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _positionAnimation = Tween<double>(begin: -100.0, end: 200.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _sizeAnimation = Tween<double>(begin: 50.0, end: 100.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Gradient Color Animation Controller
    _gradientController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat(reverse: true);

    _gradientColorAnimation = ColorTween(
      begin: Color(0xFF14213D), // Dark Blue
      end: Color(0xFFFCA311), // Orange
    ).animate(CurvedAnimation(
      parent: _gradientController,
      curve: Curves.easeInOut,
    ));

    // Particle Stream Controller
    _particleStreamController = StreamController<Offset>.broadcast();
    Timer.periodic(const Duration(milliseconds: 30), _generateParticles);

    // Button Animation
    _buttonAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _gradientController.dispose();
    _buttonAnimationController.dispose();
    _particleStreamController.close();

    super.dispose();
  }

  // Particle generation logic
  void _generateParticles(Timer timer) {
    if (_particles.length > 100) _particles.clear();
    if (mounted) {
      _particles.add(
        Offset(
          (MediaQuery.of(context).size.width * 0.5) + (20 - 40 * 0.5),
          (200 - 100.0) + (40 - 60 * 0.5),
        ),
      );
      _particleStreamController.add(_particles.last);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated Gradient Background
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.black],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: [
                      _animationController.value,
                      1 - _animationController.value,
                    ],
                  ),
                ),
                height: MediaQuery.of(context).size.height,
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                      sigmaX: 5.0, sigmaY: 5.0), // Enhanced blur
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              );
            },
          ),
          // Animated Ball with Particle Animation
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Positioned(
                left: MediaQuery.of(context).size.width / 2 -
                    _sizeAnimation.value / 2,
                top: _positionAnimation.value,
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
                  child: AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    width: _sizeAnimation.value,
                    height: _sizeAnimation.value,
                    decoration: BoxDecoration(
                      color: const Color(0xFF52D7BF)
                          .withOpacity(0.6), // Increased opacity
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.5),
                          offset: Offset(4, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          // Particle Stream Effect with Scaling and Fading
          StreamBuilder<Offset>(
            stream: _particleStreamController.stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const SizedBox.shrink();
              return Positioned(
                left: snapshot.data!.dx,
                top: snapshot.data!.dy,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 8 + (8 * _animationController.value),
                  height: 8 + (8 * _animationController.value),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            },
          ),
          // Main content (Login Fields)
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(38, 60, 38, 24),
              child: Column(
                children: [
                  SizedBox(
                    width: 400,
                    height: 200,
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFD9D9D9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: _emailController,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 168, 137),
                          fontSize: 18,
                        ),
                        decoration: InputDecoration(
                          labelText: "Email",
                          labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 0, 168, 137),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color(0xFFD9D9D9),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: TextField(
                        controller: _passwordController,
                        style: TextStyle(
                          color: const Color.fromARGB(255, 0, 168, 137),
                          fontSize: 18,
                        ),
                        obscureText: isNotShowingPassword,
                        decoration: InputDecoration(
                          labelText: "Password",
                          labelStyle: TextStyle(
                            color: const Color.fromARGB(255, 0, 168, 137),
                            fontSize: 14,
                          ),
                          // icon: Icon(
                          //   Icons.password,
                          //   color: const Color.fromARGB(255, 0, 168, 137),
                          // ),
                          border: InputBorder.none,
                          suffix: IconButton(
                            onPressed: () {
                              setState(() {
                                isNotShowingPassword = !isNotShowingPassword;
                              });
                            },
                            icon: Icon(Icons.remove_red_eye),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      // crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(50),
                            color: const Color.fromARGB(199, 255, 255, 255),
                          ),
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ForgotPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "Forgot password",
                              style: TextStyle(
                                  color: const Color.fromARGB(255, 0, 168, 137),
                                  // fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  GestureDetector(
                    onTap: () {
                      _buttonAnimationController.forward();
                      _authService
                          .signIn(
                              _emailController.text, _passwordController.text)
                          .then((user) {
                        if (user != null) {
                          // Login successful
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (context) => SongsListScreen(),
                            ),
                          );
                        } else {
                          // Failed (optional: display an error message)
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    "Login failed! Please check your credentials.")),
                          );
                        }
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("An error occurred: $error")),
                        );
                      });
                    },
                    child: AnimatedBuilder(
                      animation: _buttonAnimationController,
                      builder: (context, child) {
                        return Container(
                          height: 52,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xFF52D7BF),
                          ),
                          child: Center(
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Platform.isAndroid || Platform.isIOS
                      ? Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: MaterialButton(
                            onPressed: () {
                              _authService.signInWithGoogle().then((user) {
                                if (user != null) {
                                  Navigator.push(
                                    // ignore: use_build_context_synchronously
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => SongsListScreen(),
                                    ),
                                  );
                                }
                              });
                            },
                            child: Image.asset(
                              "assets/google_logo.png",
                              // fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Sign up!",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 0, 168, 137),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.sizeOf(context).height * .05,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SongsListScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Go, without account",
                      style: TextStyle(
                        color: Colors.yellow,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
