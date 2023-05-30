import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

import 'package:shop_app/models/http_exception.dart';

import '../providers/auth.dart';

class AuthScreen extends StatelessWidget {
  static const routName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20),
                      padding:
                          EdgeInsets.symmetric(vertical: 8, horizontal: 94),
                      transform: Matrix4.rotationZ(-8 * (pi / 180))
                        ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8.0,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'My Shop',
                        style: TextStyle(
                            color: Theme.of(context)
                                .accentTextTheme
                                .headline6!
                                .color,
                            fontSize: 60,
                            fontFamily: 'Anton'),
                      ),
                    ),
                  ),
                  Flexible(
                    child: AuthCard(),
                    flex: (deviceSize.width > 600) ? 2 : 1,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  @override
  State<AuthCard> createState() => _AuthCardState();
}

enum AuthMode { Login, SignUp }

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _AuthData = {
    'email': "",
    "password": "",
  };
  var isLoading = false;
  var passwordController = TextEditingController();
  AnimationController? _controller;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _opacityAnimation;

  @override
  void initState() {
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, -0.15),
      end: Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller!,
      curve: Curves.fastOutSlowIn,
    ));

    super.initState();
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    _formKey.currentState!.save();
    setState(() {
      isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false)
            .login(_AuthData['email']!, _AuthData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false)
            .signUp(_AuthData['email']!, _AuthData['password']!);
      }
    } on HttpException catch (error) {
      var errorMessage = 'Authentication failed';
      showErrorDialog(errorMessage);
      if (error.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'this email address is already in use';
      } else if (error.toString().contains('INVALID_EMAIL')) {
        errorMessage = 'this is not a valid email';
      } else if (error.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is too weak';
      } else if (error.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Couild not find a user with that email.';
      } else if (error.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid password';
      }
    } catch (error) {
      const errorMessage =
          ' Could not authenticate you. please try again later.';
      showErrorDialog(errorMessage);
    }
    setState(() {
      isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.SignUp;
      });
      _controller!.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controller!.reverse();
    }
  }

  void showErrorDialog(String error) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('An error Occured'),
              content: Text(error),
              actions: [
                FlatButton(
                  onPressed: () => Navigator.of(ctx).pop,
                  child: Text('Ok'),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 8,
      child: AnimatedContainer(
        //color: Colors.purple.shade50,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
        height: _authMode == AuthMode.SignUp ? 320 : 260,
        constraints: BoxConstraints(
          minHeight: _authMode == AuthMode.SignUp ? 320 : 260,
        ),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  key: ValueKey('email'),
                  decoration: InputDecoration(
                    labelText: 'Email',
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val!.isEmpty || !val.contains('@')) {
                      return 'Invalid email';
                    } else
                      return null;
                  },
                  onSaved: (val) {
                    _AuthData['email'] = val!;
                  },
                ),
                TextFormField(
                  key: ValueKey('password'),
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                  ),
                  obscureText: true,
                  validator: (val) {
                    if (val!.isEmpty || val.length < 5) {
                      return 'password is too short';
                    } else
                      return null;
                  },
                  onSaved: (val) {
                    _AuthData['password'] = val!;
                  },
                ),
                AnimatedContainer(
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.SignUp ? 60 : 0,
                    maxHeight: _authMode == AuthMode.SignUp ? 120 : 0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                  child: FadeTransition(
                    opacity: _opacityAnimation!,
                    child: SlideTransition(
                      position: _slideAnimation!,
                      child: TextFormField(
                        key: ValueKey('confirm password'),
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                        ),
                        obscureText: true,
                        enabled: _authMode == AuthMode.SignUp ? true : false,
                        validator: _authMode == AuthMode.SignUp
                            ? (val) {
                                if (val != passwordController.text) {
                                  return 'Password did not match';
                                } else
                                  return null;
                              }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                if (isLoading) CircularProgressIndicator(),
                RaisedButton(
                  child: Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SignUp'),
                  onPressed: submit,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 30, horizontal: 8),
                  color: Theme.of(context).primaryColor,
                  textColor:
                      Theme.of(context).primaryTextTheme.headline6!.color,
                ),
                FlatButton(
                    onPressed: _switchAuthMode,
                    child: Text(
                        '${_authMode == AuthMode.Login ? 'SignUp' : 'LOGIN'} Instead'),
                    padding: EdgeInsets.symmetric(vertical: 30, horizontal: 4),
                    textColor: Theme.of(context).primaryColor),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
