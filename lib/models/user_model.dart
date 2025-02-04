class UserModel {
  UserModel({
    required this.name,
    required this.accountType,
    required this.emailAddress,
    required this.password,
    required this.licenseExpiryDate,
    required this.profilePhoto,
  });
  
  String name;
  String accountType;
  String emailAddress;
  String password;
  String licenseExpiryDate;
  String profilePhoto;
}