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
  static const String validationServiceDown =
      "Sign in was successful, but something happened to the validation service. Please try again or contact us if the problem persists";
}

class ConnectionStrings {
  static const String connectionErrResponse = "connection error";

  static const String connectionErrString =
      "Failed to establish a connection to the server. Please check your internet connection. If this error persists, please inform us about the situation.";
  static const String unknownErrorString =
      "Something nasty happened to either the connection or the server";
  static const String internalServerError =
      "A server error has occured, we sincerely apologise for the inconvenience. Please inform us about this situation immediately.";
}

class PermissionStrings {
  static const mediaPermissionDenied =
      "You have denied access to your photos. Captured photos will not be saved to your gallery. "
      "If you change your mind, you can manually enable the permission from Android app settings.";
  static const locationServiceDenied =
      "You have denied access to your location. You will not be able to use this feature correctly since displayed "
      "rocks are supposed to be based on your location. The default location is set to the University of Wollongong, Australia";
  static const requestLocationEnable =
      "Please enable your location service to get rock posts based on your location. "
      "Default location is set to the University of Wollongong, Australia";
}

class RockIdentificationStrings {
  static const notIdentifiedResponse = "Not_A_Rock";
  static const notIdentified =
      "Sorry! We didn't find any match for the rock you've just captured. Please clean your camera lenses and "
      "make sure there is enough light in the photo. If we still can't identify, there's a possibility that "
      "the rock is not recorded in our database yet. Remember, no cheating by taking a photo from the web!";
  static const identifying =
      "We're identifying the captured rock, please wait...";
}

class CommonStrings {
  static const contactUs = "Contact us";
  static const tryAgain = "Try again";
  static const email = "therocklandproject@gmail.com";
  static const loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum feugiat at tortor ac malesuada. Phasellus sit amet arcu vehicula justo volutpat faucibus vitae vitae urna. Etiam id justo a est aliquet volutpat. Aenean varius nulla nulla, sed posuere est egestas non. Vestibulum luctus augue ut enim rutrum egestas.";
  static const loremIpsumExtension =
      " Pellentesque nec orci quam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; In tincidunt, ante vitae semper tempus, lectus dui mattis nibh, nec posuere mi tellus sit amet tellus. Quisque mattis, est vitae lobortis molestie, magna tellus consequat eros, et ultrices est arcu at justo.";
  static const loremIpsumExtension2 =
      " Duis nibh arcu, hendrerit non sagittis quis, rhoncus vitae justo. Sed ut placerat eros. Integer ac ullamcorper est. Nam at est posuere, accumsan mi id, dignissim metus. Etiam dignissim tincidunt tellus et accumsan. Etiam lorem tortor, mattis ac ullamcorper et, hendrerit ac est.";
}
