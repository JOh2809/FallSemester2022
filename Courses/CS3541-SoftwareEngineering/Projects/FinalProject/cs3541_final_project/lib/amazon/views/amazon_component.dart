import 'dart:core';
import 'package:flutter/gestures.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../presenter/amazon_presenter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

/*
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../views/dreams_view.dart';
import '../presenter/dreams_presenter.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_charts/flutter_charts.dart';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'VideoPlayer.dart';
import 'package:intl/intl.dart';
 */
List<ListTile> saved = [];
class AmazonSearchPage extends StatefulWidget {
  final AmazonSearchPresenter presenter;

  AmazonSearchPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _AmazonSearchPageState createState() => _AmazonSearchPageState();
}

class _AmazonSearchPageState extends State<AmazonSearchPage> {
  //final AmazonSearchPresenter presenter;
  AmazonSearchPageState() {}
  List<List<dynamic>> _amazonBooksData = [];

  @override
  void initState() {
    super.initState();
    _openCSV();
  }

  void _openCSV() async {
    final rawData = await rootBundle.loadString("assets/Amazon_Books_Data.csv");
    List<List<dynamic>> bookData = const CsvToListConverter().convert(rawData);
    setState(() {
      _amazonBooksData = bookData;
    });
  }

  String _title = "";
  String _author = "";
  String _price = "";
  String _rating = "";
  String _editionNumber = "";
  String _publishDate = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amazon Books Search Engine'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
        backgroundColor: Colors.brown.shade600,
      ),
      body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              SearchAnchor(
                builder: (BuildContext context, SearchController controller) {
                  return SearchBar(
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    onChanged: (_) {
                      controller.openView();
                    },
                    onSubmitted: (String isbn13) {
                      setState(() {
                        isbn13 = controller.text;
                      });
                      for (int index = 0; index < _amazonBooksData.length; index++) {
                        if (isbn13 == _amazonBooksData[index][4].toString()) {
                          _title = _amazonBooksData[index][0].toString();
                          _author = _amazonBooksData[index][2].toString();
                          _price = _amazonBooksData[index][11].toString();
                          _rating = _amazonBooksData[index][9].toString();
                          _editionNumber = _amazonBooksData[index][6].toString();
                          _publishDate = _amazonBooksData[index][5].toString();
                        }
                      }
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (BuildContext context,
                    SearchController controller) {
                  return List<ListTile>.generate(_amazonBooksData.length, (int index) {
                    String title = _amazonBooksData[index][0].toString();
                    String author = _amazonBooksData[index][2].toString();
                    String isbn =_amazonBooksData[index][4].toString();
                    String price =_amazonBooksData[index][11].toString();
                    String rating =_amazonBooksData[index][9].toString();
                    String editionNumber =_amazonBooksData[index][6].toString();
                    String publishDate =_amazonBooksData[index][5].toString();
                    final String isbn13 = '$title, $author, $isbn, $price, $rating, $editionNumber, $publishDate';
                    return ListTile(
                      title: Text(isbn13),
                      onTap: () {
                        setState(() {
                          controller.closeView(isbn13);
                        });
                      },
                    );
                  });
                },
              ),
              ListTile(
                title: Text(_title),
                subtitle: Text(_author),
              ),
              ListTile(
                title: Text(_price),
                subtitle: Text(_rating),
              ),
              ListTile(
                title: Text(_publishDate),
                subtitle: Text(_editionNumber),
              )
            ],
          )
      ),
    );
  }
}


class AmazonBookListPage extends StatefulWidget {
  final AmazonBookListPresenter presenter;

  AmazonBookListPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _AmazonBookListPageState createState() => _AmazonBookListPageState();
}

class _AmazonBookListPageState extends State<AmazonBookListPage> {
  List<List<dynamic>> _amazonBooksData = [];
  List<List> filteredNames = []; // names filtered by search text


  @override
  void initState() {
    super.initState();
    _openCSV();
  }

  void _openCSV() async {
    final rawData = await rootBundle.loadString("assets/Amazon_Books_Data.csv");
    List<List<dynamic>> bookData = const CsvToListConverter().convert(rawData);
    setState(() {
      _amazonBooksData = bookData;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Amazon Books Search Engine'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: ListView.builder(
          itemCount: _amazonBooksData.length,
          itemBuilder: (_, index) {
            return Card(
              margin: const EdgeInsets.all(6),
              color: Colors.white,
              child: ListTile(
                leading: Column(
                    children: <Widget> [
                      Text(_amazonBooksData[index][0].toString()),
                      InkWell(
                          child: Text('Save Book', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),),
                          onTap: () {
                            ListTile element = ListTile(
                              leading: Column(
                                children: <Widget> [
                                  Text(_amazonBooksData[index][0].toString()),
                                  Text('Swipe to Remove'),
                                ],
                              ),
                              trailing: Text(_amazonBooksData[index][2].toString()),
                              title: Text(_amazonBooksData[index][1]),
                              subtitle: Text(_amazonBooksData[index][4].toString()),
                            );
                            if(!saved.contains(element)){
                              saved.add(element);
                            }
                            Navigator.push(context,
                              MaterialPageRoute(
                                builder: (context) => SavedListScreen(),
                              ),
                            );
                          }
                      ),
                    ]
                ),
                trailing: Text(_amazonBooksData[index][2].toString()),
                title: Text(_amazonBooksData[index][1]),
                subtitle: Text(_amazonBooksData[index][4].toString()),
                //May add isbn10 (index 3) here or within future card hero.
                isThreeLine: true,
              ),
            );
          },
        )
    );
  }
}

class AmazonBookReviewsPage extends StatefulWidget {
  final AmazonBookReviewsPresenter presenter;

  AmazonBookReviewsPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _AmazonBookReviewsPageState createState() => _AmazonBookReviewsPageState();
}

class _AmazonBookReviewsPageState extends State<AmazonBookReviewsPage> {
  List<List<dynamic>> _amazonBooksData = [];
  String _title = "";
  String _author = "";

  @override
  void initState() {
    super.initState();
    _openCSV();
  }

  void _openCSV() async {
    final rawData = await rootBundle.loadString("assets/Amazon_Books_Data.csv");
    List<List<dynamic>> bookData = const CsvToListConverter().convert(rawData);
    setState(() {
      _amazonBooksData = bookData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amazon Book Reviews'),
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: Padding (
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
                return SearchBar(
                  controller: controller,
                  padding: const MaterialStatePropertyAll<EdgeInsets>(
                      EdgeInsets.symmetric(horizontal: 16.0)),
                  onTap: () {
                    controller.openView();
                  },
                  onChanged: (_) {
                    controller.openView();
                  },
                  onSubmitted: (String title) {
                    setState(() {
                      title = controller.text;
                    });
                    for (int index = 0; index < _amazonBooksData.length; index++) {
                      if (title == _amazonBooksData[index][0].toString()) {
                        _title = _amazonBooksData[index][0].toString();
                        _author = _amazonBooksData[index][2].toString();
                      }
                    }
                  },
                  leading: const Icon(Icons.search),
                );
              },
              suggestionsBuilder: (BuildContext context,
                  SearchController controller) {
                return List<ListTile>.generate(_amazonBooksData.length, (int index) {
                  String title = _amazonBooksData[index][0].toString();
                  final String isbn13 = '$title';
                  return ListTile(
                    title: Text(isbn13),
                    onTap: () {
                      setState(() {
                        controller.closeView(isbn13);
                      });
                    },
                  );
                });
              },
            ),
            SizedBox(
                height: 100,
                child: Card(
                  margin: const EdgeInsets.all(6),
                  color: Colors.white,
                  child: ListTile(
                    leading: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return AmazonGiveReviewScreen();
                          },
                        ));
                      },
                      child: const Icon(Icons.draw_outlined),
                    ),
                    trailing:  GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (BuildContext context) {
                            return AmazonGiveReviewScreen();
                          },
                        ));
                      },
                      child: const Icon(Icons.reviews),
                    ),
                    title: Text(_title),
                    subtitle: Text(_author),
                  ),
                )
            )
          ],
        ),
      ),
    );
  }
}

class  AmazonGiveReviewScreen extends StatefulWidget {
  @override _AmazonGiveReviewScreen createState() => _AmazonGiveReviewScreen();
}

class _AmazonGiveReviewScreen extends State<AmazonGiveReviewScreen> {
  @override
  Widget build(BuildContext context) {
    return new  AmazonGiveReviewPage(
      new  AmazonGiveReviewPresenter(), title: 'Amazon Review', key: Key("REVIEW"),);
  }
}

class AmazonGiveReviewPage extends StatefulWidget {
  final AmazonGiveReviewPresenter presenter;

  AmazonGiveReviewPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _AmazonGiveReviewPageState createState() => _AmazonGiveReviewPageState();
}

class _AmazonGiveReviewPageState extends State<AmazonGiveReviewPage> {
  final FocusNode _bookReviewFocus = FocusNode();
  final FocusNode _bookRatingScoreFocus = FocusNode();
  var _bookReviewController = TextEditingController();
  var _bookRatingScoreController = TextEditingController();
  String _bookReview = "0";
  String _bookRatingScore = "0.0";
  var _formKey = GlobalKey<FormState>();


  @override
  Widget build(BuildContext context) {

    TextFormField bookReviewField(BuildContext context) {
      return TextFormField(
        controller: _bookReviewController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
        focusNode: _bookReviewFocus,
        onFieldSubmitted: (value){
          _bookReviewFocus.unfocus();
        },
        validator: (value) {
          if (value!.length == 0 || (double.parse(value) < 1 || double.parse(value) > 10)) {
            return ('Rate the quality of your sleep between 1 - 10');
          }
        },
        onSaved: (value) {
          _bookReview = value!;
        },
        decoration: InputDecoration (
            hintText: 'Write a review for the book here!',
            labelText: 'Review:',
            labelStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.9)),
            icon: Icon(
              Icons.draw_outlined,
              size: 30.0,
            ),
            fillColor: Colors.grey
        ),
      );
    }

    TextFormField bookRatingScoreField(BuildContext context) { //Hours slept
      return TextFormField(
        controller: _bookRatingScoreController,
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.next,
        focusNode: _bookRatingScoreFocus,
        onFieldSubmitted: (term) {},
        validator: (value) {
          if (value!.length == 0 || (double.parse(value) < 0 || double.parse(value) > 24)) {
            return ('Hour between 0 - 24');
          }
        },
        onSaved: (value) {
          _bookRatingScore = value!;
        },
        decoration: InputDecoration(
          hintText: 'Score the book here!',
          labelText: 'Review Score?',
          labelStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black.withOpacity(0.9)),
          icon: Icon(
            Icons.reviews,
            size: 30.0,
          ),
          fillColor: Colors.grey,
        ),
      );
    }

    var _bookRatingView = Container(
      color: Colors.grey.withOpacity(0.5),
      margin: EdgeInsets.all(8.0),
      padding: EdgeInsets.all(8.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              bookReviewField(context),
              bookRatingScoreField(context),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
        appBar: AppBar(
          title: Text('Write Your Review Here!'),
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: Container(child: ListView(
          children: <Widget>[
            _bookRatingView
          ],
        ),)
    );
  }
}
