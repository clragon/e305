import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'credentials.g.dart';

@JsonSerializable()
class Credentials {
  final String username;
  final String password;

  Credentials({
    required this.username,
    required this.password,
  });

  String toAuth() {
    String auth = base64Encode(utf8.encode('$username:$password'));
    return 'Basic $auth';
  }

  factory Credentials.fromJson(Map<String, dynamic> json) =>
      _$CredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsToJson(this);
}
