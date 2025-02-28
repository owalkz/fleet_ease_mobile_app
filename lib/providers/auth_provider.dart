import 'package:fleet_ease/models/user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  User build() {
    return User(
      name: '',
      accountType: '',
      emailAddress: '',
    );
  }

  void setUserDetails(name, accountType, emailAddress) {
    state = state.copyWith(
      name: name,
      accountType: accountType,
      emailAddress: emailAddress,
    );
  }

  void unsetUserDetails() {
    state = state.copyWith(
      name: '',
      accountType: '',
      emailAddress: '',
    );
  }
}
