class Error {
  int errorCode;
  String description;

  Error({required this.errorCode, required this.description});
}

class Rock {
  String id;
  String name;
  Map<String, dynamic> rock;

  Rock({required this.id, required this.name, required this.rock});

  factory Rock.fromJson(Map<String, dynamic> json) {
    return Rock(id: json["_id"], name: json["name"], rock: json["rock"]);
  }
}

class RockImages {
  String credit;
  String link;

  RockImages({required this.credit, required this.link});

  factory RockImages.fromJson(Map<String, dynamic> json) {
    return RockImages(credit: json["credit"], link: json["link"]);
  }
}

class Post {
  String id;
  String rocktype;
  List<dynamic> pictureUrl;
  String description;
  double latitude;
  double longitude;
  List<dynamic> hashtags;
  List<dynamic> liked;
  int likedAmount;
  String userId;

  Post({
    required this.id,
    required this.rocktype,
    required this.pictureUrl,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.hashtags,
    required this.liked,
    required this.likedAmount,
    required this.userId,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["_id"],
      rocktype: json["rocktype"],
      pictureUrl: json["picture_url"],
      description: json["description"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      hashtags: json["hashtags"],
      liked: json["liked"],
      likedAmount: json["liked_amount"],
      userId: json["user_id"],
    );
  }
}

class User {
  String id;
  String email;
  String firstName;
  String lastName;
  String profilePictureUrl;
  String profileCoverUrl;
  String aboutMe;
  String password;

  User({
    this.id = "",
    this.email = "",
    this.firstName = "",
    this.lastName = "",
    this.profilePictureUrl = "",
    this.profileCoverUrl = "",
    this.aboutMe = "",
    this.password = "",
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["_id"],
      email: json["email"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      profilePictureUrl: json["profile_picture_url"],
      profileCoverUrl: json["profile_cover_url"],
      aboutMe: json["about_me"],
      password: json["password"],
    );
  }
}

class Comment {
  String id;
  String postId;
  String userId;
  String comment;
  String timestamp;

  Comment({
    this.id = "",
    this.postId = "",
    this.userId = "",
    this.comment = "",
    this.timestamp = "",
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json["_id"],
      postId: json["post_id"],
      userId: json["user_id"],
      comment: json["comment"],
      timestamp: json["timestamp"],
    );
  }
}

class Identification {
  String id;
  String postId;
  String userId;
  String verification;
  List<dynamic> agree;
  String timestamp;
  int agreeAmount;
  List<dynamic> disagree;
  int disagreeAmount;

  Identification({
    required this.id,
    required this.postId,
    required this.userId,
    required this.verification,
    required this.agree,
    required this.timestamp,
    required this.agreeAmount,
    required this.disagree,
    required this.disagreeAmount,
  });

  factory Identification.fromJson(Map<String, dynamic> json) {
    return Identification(
      id: json["_id"],
      postId: json["post_id"],
      userId: json["user_id"],
      verification: json["verification"],
      agree: json["agree"],
      timestamp: json["timestamp"],
      agreeAmount: json["agree_amount"],
      disagree: json["disagree"],
      disagreeAmount: json["disagree_amount"],
    );
  }
}

class TokenValidationDetail {
  String userId;
  String email;
  int exp;
  int iat;

  TokenValidationDetail(
      {required this.userId,
      required this.email,
      required this.exp,
      required this.iat});

  factory TokenValidationDetail.fromJson(Map<String, dynamic> json) {
    return TokenValidationDetail(
      userId: json["user_id"],
      email: json["email"],
      exp: json["exp"],
      iat: json["iat"],
    );
  }
}

class TokenValidation {
  TokenValidationDetail detail;

  TokenValidation({required this.detail});

  factory TokenValidation.fromJson(Map<String, dynamic> json) {
    return TokenValidation(
      detail: TokenValidationDetail.fromJson(
        json["detail"],
      ),
    );
  }
}
