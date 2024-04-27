import 'package:flutter/material.dart';
import 'package:rockland/pages/post-screen/post.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/utility/activity.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: CustomColor.mainBrown,
        body: Expanded(
            child: ListView(
          children: [
            const Padding(
              padding: EdgeInsets.all(25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    "Daily rock facts 💡",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Card(
                    elevation: 5,
                    color: CustomColor.fifthBrown,
                    surfaceTintColor: CustomColor.fifthBrown,
                    child: Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      child: Text(
                        "Opal is a hydrated amorphous form of silica. Due to its amorphous property, it is classified as a mineraloid, unlike crystalline forms of silica, which are considered minerals. \nRead more...",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text(
                    "Recent posts",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text("Discover rocks recently found by other people",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  color: CustomColor.brownMostRecent,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () =>
                                Activity.startActivity(context, const PostPage()),
                            child: const SizedBox(
                              width: 130,
                              height: 250,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      child: SizedBox(
                                        height: 130,
                                        child: Placeholder(),
                                      ),
                                    ),
                                    Text(
                                      "Ruby",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "I found this Ruby while hiking on Mount Everest. Cool looking stone ain't gonna lie.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Posted by John",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () =>
                                Activity.startActivity(context, const PostPage()),
                            child: const SizedBox(
                              width: 130,
                              height: 250,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      child: SizedBox(
                                        height: 130,
                                        child: Placeholder(),
                                      ),
                                    ),
                                    Text(
                                      "Ruby",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "I found this Ruby while hiking on Mount Everest. Cool looking stone ain't gonna lie.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Posted by John",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          InkWell(
                            onTap: () =>
                                Activity.startActivity(context, const PostPage()),
                            child: const SizedBox(
                              width: 130,
                              height: 250,
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Card(
                                      child: SizedBox(
                                        height: 130,
                                        child: Placeholder(),
                                      ),
                                    ),
                                    Text(
                                      "Ruby",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "I found this Ruby while hiking on Mount Everest. Cool looking stone ain't gonna lie.",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Posted by John",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            )
          ],
        )));
  }
}
