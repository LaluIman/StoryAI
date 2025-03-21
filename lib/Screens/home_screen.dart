import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:scaffold_gradient_background/scaffold_gradient_background.dart';
import 'package:shimmer/shimmer.dart';
import 'package:story_generator/Screens/history_screen.dart';
import 'package:story_generator/Service/gemini_service.dart';
import 'package:story_generator/Service/storage_service.dart';
import 'package:story_generator/models/story_model.dart';
import 'package:story_generator/theme.dart';
import 'package:svg_flutter/svg_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _ideaController = TextEditingController();
  final TextEditingController _characterController = TextEditingController();
  String? _theme;
  bool isLoading = false;
  String? errorMessage = '';

  String storyTitle = '';
  String storyContent = '';
  String storySummary = '';
  List<String> morals = [];

  void _saveCurrentStory() async {
    if (storyTitle.isEmpty || storyContent.isEmpty) return;

    final story = Story(
      title: storyTitle,
      content: storyContent,
      summary: storySummary,
      morals: morals,
      theme: _theme ?? "🧭 Adventure",
      date: DateTime.now().toString(),
    );

    await StorageService.saveStory(story);

    setState(() {
      _ideaController.clear();
      _characterController.clear();
      storyTitle = '';
      storyContent = '';
      storySummary = '';
      morals = [];
      errorMessage = '';

      Flushbar(
        messageText: SizedBox(
          width: double.infinity,
          child: Text(
            "Story is successfully saved🥳",
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
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: Colors.indigo.shade500,
      ).show(context);
    });
  }

  void _clearResult() {
    setState(() {
      Navigator.of(context).pop();

      _ideaController.clear();
      _characterController.clear();
      storyTitle = '';
      storyContent = '';
      storySummary = '';
      morals = [];
      errorMessage = '';

      Flushbar(
        messageText: SizedBox(
          width: double.infinity,
          child: Text(
            "Clear story!",
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
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(16),
        backgroundColor: Colors.red.shade500,
      ).show(context);
    });
  }

  Future<void> generateStory() async {
    if (_ideaController.text.isEmpty) {
      setState(() {
        errorMessage = "Please provide a story idea";
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final storyIdea = {
        "idea": _ideaController.text,
        "characters": _characterController.text,
        "theme": _theme ?? "🧭 Adventure",
      };

      final result = await GeminiService.generateStory(storyIdea);

      if (result.containsKey('error')) {
        setState(() {
          isLoading = false;
          errorMessage = result['error'];
          storyTitle = '';
          storyContent = '';
          storySummary = '';
          morals = [];
        });
        return;
      }

      setState(() {
        storyTitle = result['title'] ?? 'Untitled Story';
        storyContent = result['content'] ?? 'No story content available';
        storySummary = result['summary'] ?? '';

        if (result.containsKey('morals')) {
          var moralsData = result['morals'];
          if (moralsData is List) {
            morals = List<String>.from(moralsData);
          } else {
            morals = [];
            errorMessage = "Incorrect format for morals in response";
          }
        } else {
          morals = [];
        }

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Failed to generate story \n $e";
        storyTitle = '';
        storyContent = '';
        storySummary = '';
        morals = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldGradientBackground(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.black12, KPrimaryColor],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 70),
                Header(),
                SizedBox(height: 30),
                Container(
                  margin: EdgeInsets.all(13),
                  padding: EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: KPrimaryColor,
                        spreadRadius: 10,
                        blurRadius: 140,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TextField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        controller: _ideaController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          fillColor: KTextFieldColors,
                          filled: true,
                          hintText: "Enter your story idea...",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            Icons.lightbulb,
                            color: Colors.amber,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        controller: _characterController,
                        decoration: InputDecoration(
                          fillColor: KTextFieldColors,
                          filled: true,
                          hintText: "Enter main characters name",
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                          prefixIcon: Icon(
                            FontAwesomeIcons.tag,
                            color: const Color.fromARGB(255, 255, 204, 128),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.grey.shade800,
                        padding: EdgeInsets.all(3),
                        borderRadius: BorderRadius.circular(20),
                        decoration: InputDecoration(
                          label: Text(
                            "Story Theme",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          fillColor: KTextFieldColors,
                          filled: true,
                          prefixIcon: Icon(
                            FontAwesomeIcons.palette,
                            color: const Color.fromARGB(255, 169, 113, 93),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        value: _theme,
                        items:
                            [
                                  "🧭 Adventure",
                                  "🧚🏻 Fantasy",
                                  "📖 Educational",
                                  "✨ Magical",
                                  "🧑‍🤝‍🧑 Friendship",
                                  "🕵🏻‍♂️ Mystery",
                                  "💘 Romance",
                                  "👻 Horror",
                                  "📜 Historical",
                                  "👽 Science Fiction",
                                  "🙋🏻‍♂️ A day in a life",
                                ]
                                .map(
                                  (theme) => DropdownMenuItem(
                                    value: theme,
                                    child: Text(
                                      theme,
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                )
                                .toList(),
                        onChanged:
                            (String? value) => setState(() {
                              _theme = value;
                            }),
                      ),
                      SizedBox(height: 30),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isLoading
                                    ? Colors.indigo.shade400
                                    : KPrimaryColor,
                            padding: EdgeInsets.all(15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            generateStory();
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              isLoading
                                  ? SizedBox(
                                    width: 10,
                                    height: 10,
                                    child: LoadingAnimationWidget.hexagonDots(
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  )
                                  : Icon(
                                    FontAwesomeIcons.wandSparkles,
                                    color: Colors.white,
                                  ),
                              SizedBox(width: 10),
                              Text(
                                isLoading
                                    ? "Creating story..."
                                    : "Create Story",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10),
              ],
            ),
            if (errorMessage!.isNotEmpty && !isLoading)
              ErrorCard(errorMessage: errorMessage),
            if (isLoading) ShimmerCard(),
            if (!isLoading && errorMessage!.isEmpty && storyContent.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.indigo.shade100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    FontAwesomeIcons.book,
                                    color: Colors.indigo,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    storyTitle,
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Text(
                              storyContent,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 5),
                            Divider(color: Colors.black45),
                            Text(
                              "The end...",
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    if (storySummary.isNotEmpty)
                      Card(
                        color: Colors.amber.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.fileLines,
                                      color: Colors.amberAccent.shade400,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Story Summary",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                storySummary,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    if (morals.isNotEmpty)
                      Card(
                        color: Colors.green.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.heartCircleCheck,
                                      color: Colors.green,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    "Lessons to Learn",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              ...morals.map(
                                (moral) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          moral,
                                          style: TextStyle(
                                            fontSize: 16,
                                            height: 1.5,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        "Love the story? Save it✨",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          Icons.data_saver_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          "Save Story",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo.shade400,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: _saveCurrentStory,
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: Icon(
                          FontAwesomeIcons.xmark,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: Text(
                          "Clear Result",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade400,
                          padding: EdgeInsets.all(15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
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
                                  "Are you sure you want to clear the story without saving?",
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
                                    onPressed: () {
                                      _clearResult();
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
                                        "Clear",
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
                        },
                      ),
                    ),
                    SizedBox(height: 30),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class Header extends StatelessWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/header.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: 0,
            child: IconButton(
              icon: Icon(FontAwesomeIcons.clockRotateLeft),
              onPressed: () {},
            ),
          ),

          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  "assets/icons/logo.svg",
                  width: 50,
                  height: 50,
                ),
                SizedBox(width: 10),
                Text(
                  "StoryAI",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          IconButton(
            icon: Icon(FontAwesomeIcons.clockRotateLeft, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Stack(
        children: [
          Shimmer.fromColors(
            baseColor: Colors.indigo.shade600,
            highlightColor: Colors.indigo.shade700,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 120,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 120,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 120,
                  width: double.infinity,
                ),
                SizedBox(height: 10),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  height: 50,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            bottom: 0,
            child: Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: Column(
                  children: [
                    SvgPicture.asset(
                      "assets/icons/wand.svg",
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Generating....",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Card(
        color: Colors.red,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  errorMessage!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
