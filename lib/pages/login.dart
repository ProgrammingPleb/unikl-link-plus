import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/types/auth.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:new_unikl_link/utils/token_tools.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/server/urls.dart';

class LoginPage extends StatefulWidget {
  final ECitieURLs eCitieURL;
  final ECitieQuery eCitieQ;
  final Future<SharedPreferences> storeFuture;
  final bool relogin;

  const LoginPage({
    Key? key,
    required this.eCitieURL,
    required this.eCitieQ,
    required this.storeFuture,
    this.relogin = false,
  }) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.relogin) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text("Invalid saved credentials! Please re-enter your current "
                  "login credentials.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);

        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
            appBar: AppBar(
              title: const Text("UniKL eCitie Login"),
              automaticallyImplyLeading: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Form(
                    key: _formKey,
                    child: AutofillGroup(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Email",
                            ),
                            autofillHints: const [
                              AutofillHints.email,
                            ],
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              RegExp emailCheck =
                                  RegExp(r"@(?:[st]\.)?unikl\.edu\.my");
                              if (emailCheck.hasMatch(value ?? "")) {
                                return null;
                              }
                              return "Please enter a valid UniKL email address.";
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: TextFormField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: "Password",
                              ),
                              autofillHints: const [AutofillHints.password],
                              validator: (value) {
                                if (value != "") {
                                  return null;
                                }
                                return "Please enter the password "
                                    "for your account.";
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: FilledButton.tonal(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          http
                              .get(Uri.parse(widget.eCitieURL.auth(
                                  usernameController.text,
                                  passwordController.text)))
                              .then((resp) {
                            Map<String, dynamic> json = jsonDecode(resp.body);
                            if (json["status"] == "0") {
                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Invalid username or/and password!"),
                                ),
                              );
                            } else {
                              AuthData auth = AuthData.fromJson(json);
                              http
                                  .get(Uri.parse(widget.eCitieURL.serverQuery(
                                      auth.eCitieToken,
                                      widget.eCitieQ.studentProfile
                                          .replaceFirst("|STAFFEMAIL|",
                                              usernameController.text))))
                                  .then((resp) {
                                List rawResp = jsonDecode(resp.body);
                                StudentData studentData =
                                    StudentData.fromJson(rawResp[0]);
                                widget.storeFuture.then(
                                  (store) {
                                    store.setString(
                                        "eCitieToken", auth.eCitieToken);
                                    store.setString("o365AccessToken",
                                        auth.o365AccessToken);
                                    store.setString("o365RefreshToken",
                                        auth.o365RefreshToken);
                                    store.setString("o365TokenExpiryTime",
                                        auth.o365TokenExpiryTime);
                                    store.setString("personID", auth.personID);
                                    store.setString(
                                        "username", usernameController.text);
                                    store.setString(
                                        "password", passwordController.text);
                                    store.setString(
                                        "profile", studentData.toJson());
                                    setTokenExpiry(
                                        storeFuture: widget.storeFuture);
                                    FocusScopeNode currentFocus =
                                        FocusScope.of(context);

                                    if (!currentFocus.hasPrimaryFocus) {
                                      currentFocus.unfocus();
                                    }

                                    Navigator.of(context).pop(studentData);
                                  },
                                );
                              });
                            }
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        elevation: 5.0,
                        textStyle: const TextStyle(color: Colors.white),
                      ),
                      child: const Text('Login'),
                    ),
                  )
                ],
              ),
            )),
      ),
    );
  }
}
