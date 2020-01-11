// Date: 19/12/3
// yc12312
// flutter[Youtube to MP3]

import 'dart:io';

import 'package:directory_picker/directory_picker.dart';
import 'package:flutter/material.dart';
import 'package:youtube_api/youtube_api.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';

import 'diodown.dart';
import 'globals.dart' as globals;

void main() => runApp(MyApp());

class DownInfo{
  final String vid_id;
  final String dir;

  DownInfo(this.vid_id,this.dir);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key,}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  //Directory Function
  Directory selectedDirectory;
  Future<void> _pickDirectory(BuildContext context) async {
    Directory directory = selectedDirectory;
    if (directory == null) {
      directory = Directory('/storage/emulated/0/Download');
    }

    Directory newDirectory = await DirectoryPicker.pick(
        allowFolderCreation: true,
        context: context,
        rootDirectory: directory,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10))));

    setState(() {
      selectedDirectory = newDirectory;
      globals.dir = selectedDirectory.path;
    });
  }

  //YoutubeAPI Function
  //Put Your youtube API HERE!!!!!
  static String key;

  YoutubeAPI ytApi = new YoutubeAPI(key,type: 'video');
  List<YT_API> ytResult = [];

  call_API(String input) async {
    String query;
    if(input == null){
      query = 'youtube';
    }
    else{
      query = input;
    }

    ytResult = await ytApi.search(query);
    setState(() {
    });
  }

  @override
  void initState() {
    super.initState();

    call_API(null);
  }

  //alert dialog
  void _showDialog() {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text('WARNING'),
          content: new Text("Choose where to save first!"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
                _pickDirectory(context);
              },
            ),
          ],
        );
      },
    );
  }

  //widgets
  Widget ListItem(index){

    return new Slidable(
      actionPane: SlidableDrawerActionPane(),
      actionExtentRatio: 0.25,
      child: Card(
        child: new Container(
          margin: EdgeInsets.symmetric(vertical: 7.0),
          padding: EdgeInsets.all(12.0),
          child:new Row(
            children: <Widget>[
              new Image.network(ytResult[index].thumbnail['default']['url'],),
              new Padding(padding: EdgeInsets.only(right: 20.0)),
              new Expanded(child: new Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Text(
                      ytResult[index].title,
                      softWrap: true,
                      style: TextStyle(fontSize:18.0),
                    ),
                    new Padding(padding: EdgeInsets.only(bottom: 1.5)),
                    new Text(
                      ytResult[index].channelTitle,
                      softWrap: true,
                    ),
                    new Padding(padding: EdgeInsets.only(bottom: 3.0)),
                  ]
              ))
            ],
          ),
        ),
      ),
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Listen',
          color: Colors.grey,
          icon: Icons.headset,
          onTap: () async {
            String url = ytResult[index].url;
            print(url);
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
        ),
        IconSlideAction(
          caption: 'Download',
          color: Colors.blue,
          icon: Icons.file_download,
          onTap: (){

            globals.id = ytResult[index].id;
            globals.name = ytResult[index].title;

            if(selectedDirectory == null){
              _showDialog();
            }
            else{
              Navigator.push(context,
                  MaterialPageRoute(
                      builder: (context) => diodownparent()
                  ));
            }
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final serachController = TextEditingController();

    String title = 'Save To : ';

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedDirectory != null ? title + selectedDirectory.path.substring(20):title +'none',
            textAlign: TextAlign.center,textScaleFactor: 0.9,),
      ),
      body: Column(
        children: <Widget>[
          Container(
            height: 50,
            child: Row(
              children: <Widget>[
                Text('Search'),
                SizedBox(width: 5),
                Flexible(
                  child: TextField(
                    controller: serachController,
                    onSubmitted: (val){
                      call_API(val);
                    },
                    textInputAction: TextInputAction.search,
                  ),
                ),
                IconButton(icon: Icon(Icons.search),
                    onPressed: (){
                  call_API(serachController.text);
                }),
              ],
            ),
          ),
          Expanded(
            child: new Container(
                  child: ListView.builder(
                      itemCount: ytResult.length,
                      itemBuilder: (_, int index) => ListItem(index)
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDirectory(context),
        tooltip: 'Pick Directory',
        child: Icon(Icons.create_new_folder),
      ),
    );
  }
}