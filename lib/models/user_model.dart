import 'package:flutter/foundation.dart';

@immutable
class User {
  final String name;
  final String accountType;
  final String emailAddress;

  const User({
    required this.name,
    required this.accountType,
    required this.emailAddress,
  });

  // Add copyWith to help update state properly
  User copyWith({
    String? name,
    String? accountType,
    String? emailAddress,
  }) {
    return User(
      name: name ?? this.name,
      accountType: accountType ?? this.accountType,
      emailAddress: emailAddress ?? this.emailAddress,
    );
  }
}
