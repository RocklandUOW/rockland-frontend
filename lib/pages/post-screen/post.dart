import 'package:flutter/material.dart';
import 'package:rockland/styles/colors.dart';
import 'package:rockland/pages/post-screen/post_info.dart';
import 'package:rockland/pages/post-screen/post_comments.dart';
import 'package:rockland/pages/post-screen/post_identifications.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final PageController pageController = PageController(initialPage: 0);
  final Curve curveAnimation = Curves.easeInOut;
  final Duration scrollDuration = const Duration(milliseconds: 250);

  int activePage = 0;

  final List<Widget> pages = [
    const PostInfoPage(),
    const PostCommentPage(),
    const PostIdentificationsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar (not really a navbar)
      backgroundColor: CustomColor.mainBrown,
      appBar: AppBar(
          // page title
          title: const Text('Observation',
              style: TextStyle(
                color: Colors.white,
              )),
          backgroundColor: CustomColor.secondaryBrown,
          leading: IconButton(
            onPressed: () {},
            icon: const Icon (
              Icons.arrow_back,
              color: Colors.white,
            )
          ),
          actions: <Widget> [
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: Colors.white,
              onPressed: () {}
            )
          ]
      ),

      body: SafeArea(
        // main body
        child: Center(
          child: Column(
            children: [
              // profile bar
              Container(
                color: CustomColor.tertiaryBrown,
                child: Row(
                  children: [
                    // profile picture
                    Container(
                    padding: const EdgeInsets.all(10),
                    child: const CircleAvatar(
                      radius: 22,
                      child: CircleAvatar(
                        radius: 20,
                        )
                      )
                    ),
                    // profile text
                    const Text(
                      'Profile Name',
                      style: TextStyle(
                        color: Colors.white,
                      )
                    ),
                    const Spacer(),
                    // exta post information
                    const Column(
                      children: [
                         Text(
                            'post date (month date)',
                            style: TextStyle(
                              color: Colors.white
                            )
                          ),
                         Text(
                            'time (00:00 AM/PM)',
                            style: TextStyle(
                              color: Colors.white
                            )
                          ),
                      ]
                    ) 
                  ] // profile bar children
                ),
              ),

              // post image
              Placeholder(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  // height:1000,
                  child: const Center(
                    child: Text(
                      "post image",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),

              // post page content controller?
              Container(
                color: CustomColor.tertiaryBrown,
                child: 
                  Row(
                    children: [
                      // info button
                      Expanded(
                        child: Container(
                          color: CustomColor.tertiaryBrown,
                          child: IconButton(
                          icon: const Icon(Icons.info),
                          color: Colors.white,
                          onPressed: () {
                              pageController.animateToPage(
                                0,
                                duration: scrollDuration,
                                curve: curveAnimation
                              );
                            }
                          )
                        )
                      ),
                      // comments button
                      Expanded(
                        child: Container(
                          color: CustomColor.tertiaryBrown,
                          child: IconButton(
                          icon: const Icon(Icons.comment),
                          color: Colors.white,
                          onPressed: () {
                              pageController.animateToPage(
                                1,
                                duration: scrollDuration,
                                curve: curveAnimation
                              );
                            }
                          )
                        )
                      ),
                      // identifications button
                      Expanded(
                        child: Container(
                          color: CustomColor.tertiaryBrown,
                          child: IconButton(
                          icon: const Icon(Icons.search),
                          color: Colors.white,
                          onPressed: () {
                              pageController.animateToPage(
                                3,
                                duration: scrollDuration,
                                curve: curveAnimation
                              );
                            }
                          )
                        )
                      ),
                    ] // post page controllers children
                  ),
              ),

              // dynamic pages under the page controller (i dont know what to name this)
              Expanded(
                child: 
                  Stack(
                    children: [
                      PageView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: pageController,
                        scrollDirection: Axis.vertical,
                        onPageChanged: (int index) {
                          setState(() {
                            activePage = index;
                          });
                        },
                        itemCount: pages.length,
                        itemBuilder: (BuildContext context, int index) {
                          return pages[index % pages.length];
                        },
                      ),
                    ]
                ),
              ),

              // naon deui
            ]
          )
        ),
      )
    );
  }
}
