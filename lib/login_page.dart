import 'package:activity_firebase/auth_service.dart';
import 'package:activity_firebase/home_page.dart';
import 'package:activity_firebase/register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final TextEditingController emailCtrl = TextEditingController();
    final TextEditingController passwordCtrl = TextEditingController();
  
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailCtrl,
                decoration: InputDecoration(
                  label: Text('Email'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12,),
              TextField(
                controller: passwordCtrl,
                decoration: InputDecoration(
                  label: Text('Password'),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12,),
              ElevatedButton(
                child: loading ? CircularProgressIndicator(color: Colors.white,) : Text('Login with email'),
                onPressed: () async {
                  setState(() => loading = true);
                  final user = await auth.signInWithEmail(emailCtrl.text, passwordCtrl.text);
                  if (!mounted) return;
                  setState(() => loading = false);

                  if (user != null) {
                    if (!user.emailVerified) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please verify your email before logging in.')
                        )
                      );
                    } else {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => HomePage())
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Invalid email or password'))
                    );
                  }
                },
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  child: Text('Forgot your password?'),
                  onPressed: () {
                    final TextEditingController resetEmailCtrl = TextEditingController(text: emailCtrl.text);
                    showDialog(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text('Reset Password'),
                        content: TextField(
                          controller: resetEmailCtrl,
                          decoration: InputDecoration(
                            labelText: 'Enter your email',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                          ElevatedButton(
                            child: Text('Send Reset Link'),
                            onPressed: () async {
                              final email = resetEmailCtrl.text.trim();
                              if (email.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Please enter your email')),
                                );
                                return;
                              }
                              try {
                                await auth.sendPasswordResetEmail(email);
                                if (!mounted) return;
                                Navigator.pop(dialogContext);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Password reset link sent to $email')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to send reset email: $e')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 24,),
              Row(
                children: [
                  Expanded(child: Divider(),),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider(),),
                ],
              ),
              SizedBox(height: 24,),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Sign in with Google'),
                onPressed: () async {
                  setState(() => loading = true);
                  try {
                    final user = await auth.signInWithGoogle();
                    if (!mounted) return;
                    setState(() => loading = false);
                    if (user != null) {
                      Navigator.pushReplacement(
                        context, 
                        MaterialPageRoute(builder: (_) => HomePage())
                      );
                    }
                  } catch (e) {
                    if (!mounted) return;
                    setState(() => loading = false);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e is FirebaseAuthException && e.message != null ? e.message! : 'Sign-in failed: $e')),
                    );
                  }
                },
              ),
              SizedBox(height: 12,),
              TextButton(
                child: Text('Dont have an account? Register'),
                onPressed: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => RegisterPage())
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
