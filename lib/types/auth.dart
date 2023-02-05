class AuthData {
  final String o365AccessToken;
  final String o365RefreshToken;
  final String o365TokenExpiryTime;
  final String eCitieToken;
  final String personID;

  const AuthData({
    required this.o365AccessToken,
    required this.o365RefreshToken,
    required this.o365TokenExpiryTime,
    required this.eCitieToken,
    required this.personID,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) {
    return AuthData(
      o365AccessToken: json['o365AccessToken'],
      o365RefreshToken: json['o365RefreshToken'],
      o365TokenExpiryTime: json['o365TokenExpiryTime'],
      eCitieToken: json['ecitieToken'],
      personID: json['username'],
    );
  }
}
