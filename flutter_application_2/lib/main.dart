import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class CounterStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<dynamic> loadAsset(BuildContext context) async {
    final lst =
        await DefaultAssetBundle.of(context).loadString('db/dictionary.json');
    final jsonObj = json.decode(lst);
    return jsonObj;
  }
}

//model chua list
class Word {
  String key;
  String value;
  String subvalue;

  Word(this.key, this.value, this.subvalue);
}

void main() {
  runApp(
    MaterialApp(
      home: FlutterDemo(storage: CounterStorage()),
    ),
  );
}

class FlutterDemo extends StatefulWidget {
  const FlutterDemo({Key? key, required this.storage}) : super(key: key);

  final CounterStorage storage;

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  dynamic data;
  List<Word> lstWord = [];
  List<Word> lstWordSearch=[];

  @override
  void initState() {
    super.initState();

    widget.storage.loadAsset(context).then((dynamic jsonObj) {
      String sub="";
      setState(() {
        jsonObj.keys.forEach((key) {
          if(jsonObj[key].trim().length>20){
            sub=jsonObj[key].toString().substring(0,19)+"...";
            lstWord.add(Word(key, jsonObj[key], sub));
          }
          else{
            lstWord.add(Word(key, jsonObj[key], jsonObj[key]));
          }
        });
        lstWordSearch = lstWord;
      });
    });
  }
  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: AppBar(
          title: Text("Dictionary"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(45),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(left:10, bottom: 5, right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white,
                    ),
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "Input word",
                        contentPadding: EdgeInsets.only(left: 20),
                      ),
                      onChanged: (String value){                      
                        setState(() {
                          String input = _controller.text;
                        if(input==""){
                          lstWordSearch=lstWord;
                        }
                        else{
                          lstWordSearch=[];
                          for(Word word in lstWord){
                            if(word.key.contains(input)||word.value.contains(input)){
                              lstWordSearch.add(word);
                            }
                          }
                        }
                        });
                      },
                    ),
                  )
                ),
                IconButton(
                  onPressed: (){
                    lstWordSearch=[];
                    for(Word word1 in lstWord){
                      if(word1.key==_controller.text){
                        lstWordSearch.add(Word(word1.key, word1.value, word1.subvalue));
                      }
                    }
                    setState(() {});
                  }, 
                  icon: Icon(Icons.search, color: Colors.white),
                ),
              ],
            ),
          ),
          ),
      body: Column(
        children: [
          Container(
            child: Expanded(
              child: ListView.builder(
                itemCount: lstWordSearch.length,
                itemBuilder: (BuildContext context, int index) {
                  print(index);
                    return Card(
                      child: ListTile(
                        title: Text(lstWordSearch[index].key),
                        subtitle: Text(lstWordSearch[index].subvalue),
                        onTap: (){
                          Navigator.push(
                            context, MaterialPageRoute(
                              builder: (context)=>DetailDictionary(title: lstWordSearch[index].key, subtitle: lstWordSearch[index].value,)
                            )
                          );
                        },
                      ),
                    );
                  }
                ),
            )
          )
        ],
      )
    );
  }
}
class DetailDictionary extends StatelessWidget{
  DetailDictionary ({Key? key, required this.title, required this.subtitle}): super(key: key);
  String title;
  String subtitle;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          IconButton(
            onPressed:(){
              Navigator.pop(context);
            },  
            icon: Icon(Icons.arrow_back),
          ),
        ],
        title: Flexible(
          fit: FlexFit.tight,
          child: Text("DetailDictionary"),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(7),
            child: Flexible(child: Text(title, style: TextStyle(fontWeight: FontWeight.bold))),
          ),
          Container(
            padding: EdgeInsets.all(7),
            child: Flexible(child: Text(subtitle)),
          ),
        ],
      ),
    );
  }
}