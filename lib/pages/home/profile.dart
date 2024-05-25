import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/popup_container.dart';
import 'package:rockland/components/profile_page_builder.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/utility/user_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  PopUpContainerController controller = PopUpContainerController();

  @override
  void initState() {
    super.initState();
    HomeScreen.previousFragment.add(const ProfilePage());
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) {
        return Scaffold(
          body: ProfilePageBuilder(
            user: value.user,
          ),
        );
      },
    );
  }
}
