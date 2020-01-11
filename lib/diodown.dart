import 'dart:async';

import 'package:youtube_extractor/youtube_extractor.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:youtubedownloader/main.dart';

import 'globals.dart' as globals;

class diodownparent extends StatefulWidget{
  @override
  diodown createState() => diodown();
}

class diodown extends State<diodownparent>{

  Dio dio = Dio();
  var extractor = YouTubeExtractor();
  CancelToken cancelToken = CancelToken();

  String str_percent = '0%';
  double double_percent = 0;
  bool isDownloading = false;

  void _timer() {
    if(double_percent == 100){
      isDownloading = false;
      Navigator.pop(context);

      return;
    }

    Future.delayed(Duration(seconds: 3)).then((_) {
      setState(() {
        // Anything else you want
      });
      _timer();
    });
  }

  void showDownloadProgress(received, total) {
    if (total != -1) {
      double_percent = (received / total * 100);
      str_percent = (received / total * 100).toStringAsFixed(0)+'%';
    }
  }

  void _showDialog(String content,bool error) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: error ? Text('Error'): null,
          content: new Text(content),
          actions: error? <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: (){
                cancel(cancelToken);
              },
            )
          ]:null,
        );
      },
    );
  }


  void _showquitDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          content: new Text("Stop Downloading?"),
          actions: <Widget>[
            FlatButton(
              child: Text('Yes'),
              onPressed: (){
                cancel(cancelToken);
                Navigator.pop(context);
              },
            ),
            FlatButton(
              child: Text('No'),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ],
        );
      },
    );
  }



  Future download(String id,String dir) async{

    _timer();

    _showDialog("Extracting Youtube ID...", false);

    var audioInfo;

    audioInfo = await extractor.getMediaStreamsAsync(id).whenComplete((){
      Navigator.pop(context);
    });

    try {

      var dwrul = audioInfo.audio.first.url;

      await dio.download(dwrul, dir + '/' + globals.name +'.mp3',
          onReceiveProgress: showDownloadProgress,
          cancelToken: cancelToken,
          deleteOnError: true
      );
    } catch (e) {
      _showDialog(e.toString(), true);
    }

  }

  void cancel(CancelToken token) async{
    double_percent = 0;
    str_percent = '0%';

    if(!token.isCancelled)
      await token.cancel();

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: (){
        _showquitDialog();
      },
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Center(child: Text('Youtube Into Mp3', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),)),
            Center(child: Text(globals.name,textAlign: TextAlign.center,)),
            new CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 13.0,
              animation: true,
              percent: double_percent/100,
              center: new Text(
                str_percent,
                style:
                new TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
              ),
              footer: new Text(
                "Now Downloading",
                style:
                new TextStyle(fontWeight: FontWeight.bold, fontSize: 17.0),
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: Colors.blue,
            ),
            isDownloading ?
            RaisedButton(
              onPressed: () {
                cancel(cancelToken);
                isDownloading = false;
                setState(() {
                });
              },
              child: Text(
                  'Cancel',
                  style: TextStyle(fontSize: 15)
              ),
            ):RaisedButton(
              onPressed: () async{
                isDownloading = true;

                await download(globals.id,globals.dir);
                setState(() {
                });
              },
              child: Text(
                  'Download',
                  style: TextStyle(fontSize: 15)
              ),
            ),
          ],
        )
      ),
    );
  }
}