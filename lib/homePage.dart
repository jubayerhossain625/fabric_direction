import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  String result = '';

  Future getImage() async {
    result = '';
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> sendImage(context) async {
    final url = 'http://192.168.0.100:5004/image/upload';
    var request = http.MultipartRequest('POST', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath('file', _image!.path));

    try {
      var response = await request.send();
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(await response.stream.bytesToString());
        setState(() {
          result = '';
          result = jsonResponse['predicted_class'];
        });
      } else {
        print('Failed to upload image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error during image upload: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Fabric Direction'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _image == null
                ? Container(
                    margin: const EdgeInsets.all(30),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.blue,
                        border: Border.all(width: 2, color: Colors.yellow),
                        image: DecorationImage(
                            image: NetworkImage(net), fit: BoxFit.fill)),
                    height: MediaQuery.sizeOf(context).height * 0.4,
                  )
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.blue,
                            border: Border.all(width: 2, color: Colors.yellow),
                            image: DecorationImage(
                                image: FileImage(_image!), fit: BoxFit.fill)),
                        height: MediaQuery.sizeOf(context).height * 0.5,
                      ),
                      Positioned(
                          bottom: 0.1,
                          child: Center(
                            child: Text(
                              result,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                          )),
                    ],
                  ),
            const Spacer(),
            ElevatedButton(
              onPressed: getImage,
              child: const Text("Select Image"),
            ),
            const SizedBox(
              height: 20,
            ),
            // Add a button to send the image to Flask API

            ElevatedButton(
              onPressed: () {
                sendImage(context);
              },
              child: const Text("Detect Object"),
            ),
            const Spacer(),
            const SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }

  String net = 'https://cdn7.dissolve.com/p/D430_47_391/D430_47_391_1200.jpg';
}
