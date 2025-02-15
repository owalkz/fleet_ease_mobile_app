import 'dart:convert';
import 'package:fleet_ease/providers/auth_provider.dart';
import 'package:http/http.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:fleet_ease/utils/secure_storage.dart';

Future<int> login(String emailAddress, String password, WidgetRef ref) async {
  final url = Uri.parse("https://fleet-ease-backend.vercel.app/api/auth/login");
  try {
    final response = await post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'emailAddress': emailAddress,
        'password': password,
      }),
    );
    final responseData = json.decode(response.body);
    await SecureStorageService().saveUserData(
      responseData['token'],
    );
    ref.watch(userNotifierProvider.notifier).setUserDetails(
        responseData['user']['name'],
        responseData['user']['accountType'],
        responseData['user']['emailAddress']);
    return response.statusCode;
  } catch (error) {
    return 500; // Return 500 in case of error
  }
}

Future<int> register(String name, String accountType, String emailAddress,
    String password) async {
  final url =
      Uri.parse("https://fleet-ease-backend.vercel.app/api/auth/register");
  try {
    final response = await post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'name': name,
        'accountType': accountType,
        'emailAddress': emailAddress,
        'password': password,
      }),
    );
    return response.statusCode;
  } catch (error) {
    return 500; // Return 500 in case of error
  }
}
