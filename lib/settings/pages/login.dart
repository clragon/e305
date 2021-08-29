import 'package:e305/client/data/client.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  final Function? onSuccess;

  const LoginPage({this.onSuccess});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool authFailed = false;
  String? username;
  String? apiKey;

  String apiKeyExample = '1ca1d165e973d7f8d35b7deb7a2ae54c';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(32),
        child: Form(
          child: ListView(
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () async {
                    if (username != null) {
                      launch(
                          'https://${await client.host}/users/$username/api_key');
                    } else {
                      launch('https://${await client.host}');
                    }
                  },
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.3,
                    ),
                    child: Image(
                      image: AssetImage(
                        'assets/e6.png',
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'Username',
                  ),
                  autofillHints: [AutofillHints.username],
                  onChanged: (value) => username = value,
                  validator: (value) {
                    if (authFailed) {
                      return 'Failed to login. Please check username.';
                    }
                    if (value == null || value.trim().isEmpty) {
                      return 'You must provide a username.';
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: TextFormField(
                  autocorrect: false,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    helperText: 'e.g. $apiKeyExample',
                  ),
                  autofillHints: [AutofillHints.password],
                  onChanged: (value) => apiKey = value,
                  validator: (value) {
                    if (authFailed) {
                      return 'Failed to login. Please check API key.\n'
                          'e.g. $apiKeyExample';
                    }

                    if (value == null || value.trim().isEmpty) {
                      return 'You must provide an API key.\n'
                          'e.g. $apiKeyExample';
                    }

                    if (!RegExp(r'^[A-z0-9]{24,32}$').hasMatch(value)) {
                      return 'API key is a 24 or 32-character sequence of {A..z} and {0..9}\n'
                          'e.g. $apiKeyExample';
                    }

                    return null;
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Builder(
                  builder: (context) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      ElevatedButton(
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            Theme.of(context).accentColor,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'LOGIN',
                                style: Theme.of(context).accentTextTheme.button,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () async {
                          setState(() {
                            authFailed = false;
                          });
                          FormState form = Form.of(context)!..save();
                          if (form.validate()) {
                            showDialog(
                              context: context,
                              builder: (context) => LoginDialog(
                                username: username!,
                                apiKey: apiKey!,
                                onResult: (value) {
                                  if (value) {
                                    widget.onSuccess?.call();
                                  } else {
                                    setState(() {
                                      authFailed = true;
                                    });
                                    form.validate();
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      duration: Duration(seconds: 3),
                                      content: Text('Failed to login. '
                                          'Check your network connection and login details'),
                                    ));
                                  }
                                },
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class LoginDialog extends StatefulWidget {
  final String username;
  final String apiKey;
  final Function(bool value) onResult;

  LoginDialog(
      {required this.username, required this.apiKey, required this.onResult});

  @override
  _LoginDialogState createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  @override
  void initState() {
    super.initState();
    client.saveLogin(widget.username, widget.apiKey).then((value) async {
      await Navigator.of(context).maybePop();
      widget.onResult(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Container(
      padding: EdgeInsets.all(20.0),
      child: Row(children: [
        Padding(
          padding: EdgeInsets.all(4),
          child: Container(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('Logging in as ${widget.username}'),
        )
      ]),
    ));
  }
}
