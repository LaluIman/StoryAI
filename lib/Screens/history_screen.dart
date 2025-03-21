import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:story_generator/Screens/story_detail.dart';
import 'package:story_generator/Service/storage_service.dart';
import 'package:story_generator/models/story_model.dart';
import 'package:story_generator/theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Story> stories = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStories();
  }

  Future<void> _loadStories() async {
    setState(() => isLoading = true);

    final loadedStories = await StorageService.getStories();
    setState(() {
      stories = loadedStories;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black12, KPrimaryColor],
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leadingWidth: 150,
        leading: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: Colors.white,
            iconColor: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Icon(Icons.arrow_back_ios_new, size: 20),
              SizedBox(width: 5),
              Text("Back", style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : stories.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(FontAwesomeIcons.book, size: 60, color: Colors.white),
                    SizedBox(height: 20),
                    Text(
                      'No saved stories yet',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )
              : SingleChildScrollView(
                reverse: false,
                child: ListView.builder(
                  shrinkWrap: true,
                  reverse: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: stories.length,
                  padding: EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final story = stories[index];
                    return Container(
                      margin: EdgeInsets.all(8),
                      padding: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.indigo.shade700,
                      ),
                      child: ListTile(
                        minVerticalPadding: 5,
                        title: Text(
                          story.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 0,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          story.date,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        leading: Container(
                          padding: EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.indigo.shade200,
                          ),
                          child: _getThemeIcon(story.theme),
                        ),
                        onLongPress: () {
                          setState(() {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.indigo.shade700,
                                  titleTextStyle: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 20,
                                  ),
                                  title: Text(
                                    "Are you sure you want to delete this story?",
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        "cancel",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        await StorageService.deleteStory(index);
                                        _loadStories();
                                        Navigator.of(context).pop();
                                        Flushbar(
                                          messageText: SizedBox(
                                            width: double.infinity,
                                            child: Text(
                                              "Deleted a story",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          duration: Duration(seconds: 3),
                                          flushbarPosition: FlushbarPosition.TOP,
                                          flushbarStyle: FlushbarStyle.FLOATING,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 26,
                                            horizontal: 16,
                                          ),
                                          margin: const EdgeInsets.all(10),
                                          borderRadius: BorderRadius.circular(16),
                                          backgroundColor: Colors.red.shade500,
                                        ).show(context);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 25,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.red.shade500,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          "Delete",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          });
                        },
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => StoryDetailScreen(story: story),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
    );
  }

  Widget _getThemeIcon(String theme) {
    if (theme.contains('Adventure')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🧭",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Fantasy')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🧚🏻",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Educational')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🎓",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Magical')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🪄",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Friendship')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🧑‍🤝‍🧑",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Mystery')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🕵🏻‍♂️",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Romance')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "💘",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Horror')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "👻",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Historical')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "📜",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('Science Fiction')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "👽",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else if (theme.contains('A day in a life')) {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "🙋🏻‍♂️",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(1),
        child: Text(
          "📖",
          style: TextStyle(letterSpacing: 0, height: 0, fontSize: 30),
        ),
      );
    }
  }
}
