import 'package:flutter/material.dart';

class SelectRecordingScreen extends StatelessWidget {
  final List<String> recordings;

  const SelectRecordingScreen({Key? key, required this.recordings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Recording'),
      ),
      body: ListView.builder(
        itemCount: recordings.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(recordings[index].split('/').last),
            onTap: () {
              // Here you can handle the selection logic, e.g., attaching the recording to the file
              Navigator.pop(context, recordings[index]);
            },
          );
        },
      ),
    );
  }
}