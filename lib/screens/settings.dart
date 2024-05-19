import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rockland/components/alert_dialog.dart';
import 'package:rockland/components/settings/card.dart';
import 'package:rockland/screens/account/login.dart';
import 'package:rockland/screens/home.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';
import 'package:rockland/utility/common.dart';
import 'package:rockland/utility/user_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late DismissableAlertDialog confirmation;

  @override
  void initState() {
    super.initState();
    confirmation = DismissableAlertDialog(
        context: context,
        child: const Text("Are you sure you want to sign out?"));
    confirmation.setCancelButton(TextButton(
        onPressed: () => confirmation.dismiss(), child: const Text("No")));
    confirmation
        .setOkButton(TextButton(onPressed: signOut, child: const Text("Yes")));
  }

  void signOut() async {
    context.read<UserProvider>().setUserId("");
    confirmation.dismiss();
    Activity.startActivityAndRemoveHistory(
      context,
      const HomeScreen(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: CustomColor.mainBrown,
        appBar: AppBar(
          // page title
          title: const Text('Settings',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: CustomColor.mainBrown,
          leading: IconButton(
              onPressed: () {
                Activity.finishActivity(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
        ),
        body: Container(
          decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.white10))),
          child: ListView(
            children: [
              value.user.id == ""
                  ? SettingsListCard(
                      onPress: () => Activity.startActivity(
                        context,
                        const LoginAccount(),
                      ),
                      title: "Sign in",
                    )
                  : SettingsListCard(
                      onPress: () => confirmation.show(),
                      title: "Sign out",
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
