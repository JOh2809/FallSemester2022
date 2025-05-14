import 'package:cs3541_final_project/sound_page/sound_player.dart';
import 'package:cs3541_final_project/sound_page/sound_presenter.dart';
import 'package:flutter/material.dart';

class ReadMusicPage extends StatefulWidget {
  final ReadMusicPresenter presenter;

  ReadMusicPage(this.presenter, {required Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  _ReadMusicPageState createState() => _ReadMusicPageState(presenter);
}

class _ReadMusicPageState extends State<ReadMusicPage> {
  final ReadMusicPresenter presenter;
  _ReadMusicPageState(this.presenter);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Music'),),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10,),
            const Text("(ULTRA CALM) Study Music                                                              ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),),
            const SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=AFqv-dyuDtw"),
            const SizedBox(height: 10,),
            const Text("Relaxing Water Sounds for Studying                                                      ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),),
            const SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=ikQOMuMMY9M"),
            const SizedBox(height: 10,),
            const Text("Deep White Noise for Peaceful Studies                                                ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.black),),
            const SizedBox(height: 10,),
            YoutubeVideo("https://www.youtube.com/watch?v=sCc3UtzZDEo")
          ],),
      ),
    );
  }
}