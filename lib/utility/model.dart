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
