class SignUpStrings {
  static const String accountExistResponse = "email already exist";
  static const String registrationFailedResponse = "registration failed";
  static const String registrationSuccessResponse = "registration success";

  static const String accountExistString =
      "An account using the specified email address already exists. Please use another email.";
  static const String failedString =
      "A server error occured during the registration process. Please try again later or send an email to us.";
  static const String successString =
      "Your account has been successfully created. You can now sign in with its credentials. Thank you for trying out Rockland!";
}

class LoginStrings {
  static const String invalidAccountRes = "account not found";
  static const String invalidPasswordRes = "password doesn't match";

  static const String invalidAccountStr =
      "No account was found with the specified email address. Please register a new account with said email address.";
  static const String invalidPasswordStr =
      "The password entered was not correct. Please try again.";
}

class ConnectionStrings {
  static const String connectionErrResponse = "connection error";

  static const String connectionErrString =
      "Failed to establish a connection to the server. Please check your internet connection.";
  static const String unknownErrorString =
      "Something nasty happened to either the connection or the server";
}
