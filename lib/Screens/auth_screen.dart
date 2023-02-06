import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../exceptions/http_exception.dart';
import '../provider/auth.dart';

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
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
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'MyShop',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.headline1!.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
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

class AuthCard extends StatefulWidget {
  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  final _passwordFocusNode = FocusNode();
  late AnimationController _controler;
  late Animation<Size> _heightAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    _controler = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _heightAnimation = Tween<Size>(
            begin: Size(double.infinity, 250), end: Size(double.infinity, 320))
        .animate(
      CurvedAnimation(parent: _controler, curve: Curves.easeInOut),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controler, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controler, curve: Curves.easeInOut),
    );

    // _heightAnimation.addListener(() {
    //   setState(() {});
    // });
    super.initState();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    _controler.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        await Provider.of<Auth>(context, listen: false).login(
            email: _authData['email']!, password: _authData['password']!);
      } else {
        await Provider.of<Auth>(context, listen: false).signUp(
            email: _authData['email']!, password: _authData['password']!);
      }
    } on HttpException catch (error) {
      String errMsg = "Authentication failed";
      switch (error.message) {
        case 'EMAIL_EXISTS':
          errMsg = "The email address is already in use by another account";
          break;
        case 'OPERATION_NOT_ALLOWED':
          errMsg = "Sorry password sign-in is disabled ";
          break;
        case 'TOO_MANY_ATTEMPTS_TRY_LATER':
          errMsg =
              "We have blocked all requests from this device due to unusual activity. Try again later.";
          break;
        case 'EMAIL_NOT_FOUND':
          errMsg = " There is no user wit these credentials.";
          break;
        case 'INVALID_PASSWORD':
          errMsg = "The password is invalid";
      }
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            errMsg,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).errorColor,
          actions: [
            ElevatedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: Text(
                "Close",
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      String errMsg = "failed to authenticate please retry";
      print("error message is $e");
      ScaffoldMessenger.of(context).showMaterialBanner(
        MaterialBanner(
          content: Text(
            errMsg,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onError,
            ),
          ),
          backgroundColor: Theme.of(context).errorColor,
          actions: [
            ElevatedButton(
              onPressed: () =>
                  ScaffoldMessenger.of(context).hideCurrentMaterialBanner(),
              child: Text(
                "Close",
              ),
            ),
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      _controler.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      _controler.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: AnimatedBuilder(
        animation: _heightAnimation,
        builder: (context, childArg) {
          return Container(
            height: _heightAnimation.value.height,
            constraints: BoxConstraints(
              // minHeight: _authMode == AuthMode.Signup ? 320 : 260
              minHeight: _heightAnimation.value.height,
            ),
            width: deviceSize.width * 0.75,
            padding: EdgeInsets.all(16.0),
            child: childArg,
          );
        },
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).requestFocus(_passwordFocusNode);
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        !value.contains('@')) {
                      return 'Invalid email!';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _authData['email'] = value ?? "sample@mail.com";
                  },
                ),
                TextFormField(
                  focusNode: _passwordFocusNode,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value!;
                  },
                ),
                AnimatedContainer(
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  constraints: BoxConstraints(
                    minHeight: _authMode == AuthMode.Signup ? 60 : 0,
                    maxHeight: _authMode == AuthMode.Signup ? 140 : 0,
                  ),
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: TextFormField(
                      enabled: _authMode == AuthMode.Signup,
                      decoration:
                          InputDecoration(labelText: 'Confirm Password'),
                      obscureText: true,
                      validator: _authMode == AuthMode.Signup
                          ? (value) {
                              if (value != _passwordController.text) {
                                return 'Passwords do not match!';
                              }
                            }
                          : null,
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: _isLoading
                      ? CircularProgressIndicator(
                          strokeWidth: 2.0,
                        )
                      : Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                  onPressed: _isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    backgroundColor: Theme.of(context).primaryColor,
                    textStyle: TextStyle(
                      color: Theme.of(context).primaryTextTheme.button!.color,
                    ),
                  ),
                ),
                TextButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  style: ButtonStyle().copyWith(
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
