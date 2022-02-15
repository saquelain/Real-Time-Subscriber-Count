import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(

        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late List<dynamic> mapData;
  late String subsCount;
  TextEditingController channelName = TextEditingController();
  String userName = "drdisrespect";

  String? get _errorText {
    // at any time, we can get the text from _controller.value.text
    final text = channelName.value.text;
    // Note: you can do your own custom validation here
    // Move this logic this outside the widget for more testable code
    if (text.isEmpty) {
      return 'Can\'t be empty';
    }
    // return null if the text is valid
    return null;
  }

  Future<List<dynamic>> getdata() async {
    //get items of all videos by query search
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/search?'
          'key=AIzaSyAtcvGs3OsJn5DsvWAz1zHWZe6M4QwnQ8A&part=snippet&q=code'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if(response.statusCode==200){
      mapData = jsonDecode(response.body)['items'];
      for(var items in mapData){
        print(items['snippet']['title']);
      }
    }
    return mapData;
  }

  void getSubscriberByid() async {
    //get subscriber by id
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/channels?part=statistics&id=UCD7kbZQyYIR6RgJQYW9w0Tg'
          '&fields=items/statistics/subscriberCount&key=AIzaSyAtcvGs3OsJn5DsvWAz1zHWZe6M4QwnQ8A'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if(response.statusCode==200){
      var responseData = jsonDecode(response.body)['items'][0]['statistics']['subscriberCount'];
      print(responseData);
    }
  }

  Future<String> getSubscriberByName() async {
    final response = await http.get(
      Uri.parse('https://www.googleapis.com/youtube/v3/channels?part=statistics&forUsername=$userName'
          '&fields=items/statistics/subscriberCount&key=AIzaSyAtcvGs3OsJn5DsvWAz1zHWZe6M4QwnQ8A'),
      // Send authorization headers to the backend.
      headers: {
        HttpHeaders.contentTypeHeader: 'application/json',
      },
    );
    if(response.statusCode==200){
      subsCount = jsonDecode(response.body)['items'][0]['statistics']['subscriberCount'];
    }
    return subsCount;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // getdata();
    getSubscriberByName();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Real Time '
                    'Subscriber Count',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 40,
                    color: Colors.blueAccent,
                  shadows: <Shadow>[
                    Shadow(
                      offset: Offset(2.0, 1.0),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                    Shadow(
                      offset: Offset(5.0, 4.0),
                      blurRadius: 8.0,
                      color: Color.fromARGB(125, 0, 0, 255),
                    ),
                  ],
                ),
              ),
            TextField (
              controller: channelName,
            decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Channel Subscribers Count',
                hintText: 'Enter Channel Name: ',
              errorText: _errorText,
              ),
            ),
          OutlinedButton(
              onPressed: (){
                channelName.value.text.isNotEmpty ?
                setState(() { userName = channelName.value.text.toString(); }) : null;
              },
              child: Text('Enter')
          ),
          Container(
                child: FutureBuilder<String>(
                  future: getSubscriberByName(), // async work
                  builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                    switch (snapshot.connectionState) {
                      case ConnectionState.waiting: return Text('Loading....');
                      default:
                        if (snapshot.hasError)
                          return Text('Error: No User Found!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),);
                        else
                          return Text('Subscriber count of ${userName} : ${snapshot.data}',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, ),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
