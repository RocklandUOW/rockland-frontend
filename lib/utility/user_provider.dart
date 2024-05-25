import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rockland/utility/model.dart';
import 'package:http/http.dart' as http;

class UserProvider extends ChangeNotifier {
  String userId = "";
  User defaultUser = User(
    firstName: "Guest",
    aboutMe:
        "Sign in by clicking the gear button above to start posting your collection",
  );
  User user = User(
    firstName: "Guest",
    aboutMe:
        "Sign in by clicking the gear button above to start posting your collection",
  );
  List<Post> posts = [];

  // posts
  bool isGridView = false;
  bool isLoading = false;
  bool hasMorePosts = true;
  bool hasError = false;
  bool requestNext = false;
  int currentPostPage = 1;
  late Error error;
  late Error internalErr;

  void setUserId(String id) async {
    userId = id;
    refresh();
  }

  Future<void> refresh() async {
    print("refresh on state invoked");
    posts.clear();
    isLoading = false;
    hasMorePosts = true;
    hasError = false;
    requestNext = false;
    currentPostPage = 1;
    await getUser();
    await getPosts();
    // notifyListeners();
  }

  Future<void> getPosts() async {
    if (isLoading || !hasMorePosts) return;
    isLoading = true;

    const limit = 30;
    final url =
        "https://rockland-app-service.onrender.com/get_posts_by_user_id/?page_num=$currentPostPage&page_size=$limit";
    try {
      http.Response response;
      try {
        response = await http.post(
          Uri.parse(url),
          headers: <String, String>{"Content-Type": "application/json"},
          body: jsonEncode(
            <String, String>{"id": user.id},
          ),
        );
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final List postsNextPage = jsonDecode(response.body);
        isLoading = false;
        currentPostPage += 1;
        posts.addAll(postsNextPage.map((post) {
          return Post.fromJson(post);
        }).toList());
        if (postsNextPage.length < limit) {
          hasMorePosts = false;
        }
        notifyListeners();
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      isLoading = false;
      hasError = false;
      hasMorePosts = false;
      if (e is Error) {
        print(e.errorCode);
        print(e.description);
      } else {
        print(e.toString());
      }
      notifyListeners();
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
    }
  }

  Future<void> getUser() async {
    if (userId == "") {
      user = defaultUser;
      return;
    }
    const url = "https://rockland-app-service.onrender.com/get_account_by_id/";
    isLoading = true;
    try {
      http.Response response;
      try {
        response = await http.post(Uri.parse(url),
            headers: <String, String>{"Content-Type": "application/json"},
            body: jsonEncode(<String, String>{"id": userId}));
      } catch (e) {
        throw internalErr = Error(errorCode: 999, description: e.toString());
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> userDetails = jsonDecode(response.body);
        user = User.fromJson(userDetails);
        // print(user.id);
        isLoading = false;
        notifyListeners();
      } else {
        throw internalErr = Error(
          errorCode: response.statusCode,
          description:
              "A server error has occured on the discover service. Status code is as stated.",
        );
      }
    } catch (e) {
      isLoading = false;
      hasError = false;
      if (e is Error) {
        print((e as Error).errorCode);
        print((e as Error).description);
      } else {
        print(e.toString());
      }
      // to display to the user.
      // error = ErrorBuilder.build(internalErr.errorCode);
      notifyListeners();
    }
  }
}
