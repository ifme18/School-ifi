import 'package:flutter/material.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:school_ifi/Studentsscreen.dart';
import 'package:school_ifi/admin%20menu.dart';
import 'package:school_ifi/teachers.dart';
import 'package:cloud_functions/cloud_functions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "YOUR_API_KEY",
      authDomain: "YOUR_AUTH_DOMAIN",
      projectId: "YOUR_PROJECT_ID",
      storageBucket: "YOUR_STORAGE_BUCKET",
      messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
      appId: "YOUR_APP_ID",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) =>  App(),
        '/student': (context) =>  StudentScreen(),
        '/teacher': (context) =>  EventUploaderScreen(),
        '/signin': (context) => const SignInScreen(),
        '/register': (context) => const RegistrationScreen(),
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen();

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      Navigator.of(context).pushReplacementNamed('/signin');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: Colors.yellow,
        canvasColor: Colors.white,
      ),
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/img.png"),
              const SizedBox(height: 20),
              Text(
                'School ifi',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: <Color>[
                        Colors.yellow,
                        Colors.green,
                        Colors.blue,
                      ],
                    ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  fontFamily: 'Your_Font_Family',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends StatelessWidget {
  const SignInScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: 400,
            child: Card(
              child: Column(
                children: [
                   _SignInForm(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacementNamed('/register');
                    },
                    child: const Text('Create an admin account'),
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

class _SignInForm extends StatefulWidget {
  @override
  __SignInFormState createState() => __SignInFormState();
}

class __SignInFormState extends State<_SignInForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _selectedRole = 'admin';

  Future<void> _login() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;

      switch (_selectedRole) {
        case 'admin':
        // Perform admin login
          await _loginAdmin(email, password);
          break;
        case 'student':
        // Perform student login
          await _loginStudent(email, password);
          break;
        case 'teacher':
        // Perform teacher login
          await _loginTeacher(email, password);
          break;
      }
    } catch (e) {
      print('Error logging in: $e');
      // Show error message to the user
    }
  }

  Future<void> _loginAdmin(String email, String password) async {
    // Authenticate the user and sign in
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user's ID token
    final User? user = _auth.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();

      // Check if the user has a custom claim for admin role
      final customClaims = idTokenResult.claims;
      if (customClaims != null &&
          customClaims.containsKey('role') &&
          customClaims['role'] == 'admin') {
        Navigator.of(context).pushReplacementNamed('/welcome');
      } else {
        // Show error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Invalid admin credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _loginStudent(String email, String password) async {
    // Authenticate the user and sign in
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user's ID token
    final User? user = _auth.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();

      // Check if the user has a custom claim for student role
      final customClaims = idTokenResult.claims;
      if (customClaims != null &&
          customClaims.containsKey('role') &&
          customClaims['role'] == 'student') {
        Navigator.of(context).pushReplacementNamed('/student');
      } else {
        // Show error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Invalid student credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _loginTeacher(String email, String password) async {
    // Authenticate the user and sign in
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the user's ID token
    final User? user = _auth.currentUser;
    if (user != null) {
      final idTokenResult = await user.getIdTokenResult();

      // Check if the user has a custom claim for teacher role
      final customClaims = idTokenResult.claims;
      if (customClaims != null &&
          customClaims.containsKey('role') &&
          customClaims['role'] == 'teacher') {
        Navigator.of(context).pushReplacementNamed('/teacher');
      } else {
        // Show error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Invalid teacher credentials.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Login',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 20),
        DropdownButton<String>(
          value: _selectedRole,
          onChanged: (newValue) {
            setState(() {
              _selectedRole = newValue!;
            });
          },
          items: <String>['admin', 'student', 'teacher']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Form(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Email',
                  ),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Password',
                  ),
                  obscureText: true,
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login as $_selectedRole'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create an admin account'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _RegistrationForm(),
      ),
    );
  }
}

class _RegistrationForm extends StatefulWidget {
  @override
  __RegistrationFormState createState() => __RegistrationFormState();
}

class __RegistrationFormState extends State<_RegistrationForm> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerAdmin() async {
    try {
      final email = _emailController.text;
      final name = _nameController.text;
      final schoolName = _schoolNameController.text;
      final password = _passwordController.text;

      final HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('registerAdmin');
      final response = await callable.call({
        'email': email,
        'name': name,
        'schoolName': schoolName,
        'password': password,
      });

      final data = response.data;
      if (data['status'] == 'success') {
        Navigator.of(context).pushReplacementNamed('/welcome');
      } else {
        // Show error message to the user
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Error'),
              content: const Text('Failed to create an admin account.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('Error registering: $e');
      // Show error message to the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Create an admin account',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                hintText: 'Name',
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _schoolNameController,
              decoration: const InputDecoration(
                hintText: 'School name',
              ),
              style: const TextStyle(color: Colors.black),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(
                hintText: 'Password',
              ),
              obscureText: true,
              style: const TextStyle(color: Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: _registerAdmin,
            child: const Text('Register as admin'),
          ),
        ],
      ),
    );
  }
}

