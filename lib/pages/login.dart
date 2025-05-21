import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:new_unikl_link/server/query.dart';
import 'package:new_unikl_link/server/urls.dart';
import 'package:new_unikl_link/types/auth.dart';
import 'package:new_unikl_link/types/info/student_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  final Future<SharedPreferences> sharedPrefs;
  final bool relogin;

  const LoginPage({
    super.key,
    required this.sharedPrefs,
    this.relogin = false,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ECitieURLs eCitieURL = ECitieURLs();
  final ECitieQuery eCitieQ = ECitieQuery();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    if (widget.relogin) {
      Future.delayed(Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).clearSnackBars();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  "Invalid saved credentials! Please re-enter your current "
                  "login credentials.")));
        }
      });
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
      child: PopScope(
        canPop: false,
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
                                labelText: "eCitie Password",
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
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          http.Response resp = await http.get(Uri.parse(
                              eCitieURL.auth(usernameController.text,
                                  passwordController.text)));
                          Map<String, dynamic> json = jsonDecode(resp.body);
                          if (json["status"] == "0" && context.mounted) {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text("Invalid username or/and password!"),
                              ),
                            );
                          } else {
                            SharedPreferences store = await widget.sharedPrefs;
                            AuthData auth = AuthData.fromJson(json);
                            store.setString("eCitieToken", auth.eCitieToken);
                            store.setString("personID", auth.personID);
                            resp = await eCitieURL.sendQuery(
                                widget.sharedPrefs,
                                eCitieQ.buildQuery(
                                    auth.eCitieToken,
                                    eCitieQ.studentProfile(
                                        usernameController.text)));
                            List rawResp = jsonDecode(resp.body);
                            StudentData studentData =
                                StudentData.fromJson(rawResp[0]);
                            store.setString(
                                "username", usernameController.text);
                            store.setString(
                                "password", passwordController.text);
                            store.setString("profile", studentData.toJson());
                            if (context.mounted) {
                              FocusScopeNode currentFocus =
                                  FocusScope.of(context);
                              if (!currentFocus.hasPrimaryFocus) {
                                currentFocus.unfocus();
                              }
                              Navigator.of(context).pop(studentData);
                            }
                          }
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
