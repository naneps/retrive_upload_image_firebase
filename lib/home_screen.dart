import 'package:file_picker/file_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:retrive_upload_image_firebase/services/storage_services.dart';

// import 'package:intl'
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String downloadUrl = '';
  @override
  Widget build(BuildContext context) {
    final Storage storage = Storage();
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            // DateTimeField(),
            ElevatedButton(
                onPressed: () async {
                  final results = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: ['png', 'jpg'],
                  );

                  if (results == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("No file selected"),
                    ));
                    return;
                  }
                  final path = results.files.first.path;
                  final fileName = results.files.first.name;
                  // final reName = results.files.first.name.split("%");
                  await storage.uploadFile(path!, fileName).then((value) {
                    // print(!);
                    return value;
                  });
                  // print(reName);
                  print(fileName);
                },
                child: Text("Upload File")),
            FutureBuilder(
              future: storage.listFiles(),
              builder: (context,
                  AsyncSnapshot<firebase_storage.ListResult> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                    height: 200,
                    width: double.infinity,
                    child: RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          storage.listFiles();
                        });
                      },
                      child: ListView.builder(
                        padding: EdgeInsets.all(20),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.items.length,
                        itemBuilder: (context, index) {
                          return ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  downloadUrl =
                                      snapshot.data!.items[index].name;
                                });
                              },
                              child: Text(snapshot.data!.items[index].name));
                        },
                      ),
                    ),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container();
              },
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder(
              future: storage.downloadURL(downloadUrl),
              builder: (context, AsyncSnapshot<String> snapshot) {
                print(snapshot.data);
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData) {
                  return Container(
                      height: 400,
                      width: double.infinity,
                      child: Image.network(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ));
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return Container();
              },
            ),
          ],
        ),
      ),
    );
  }
}
