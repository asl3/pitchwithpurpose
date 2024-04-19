import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'selectrecording.dart';
import 'pdfviewer.dart';
import 'package:animated_background/animated_background.dart';

class FileUploadTab extends StatefulWidget {
  const FileUploadTab({Key? key}) : super(key: key);

  @override
  State<FileUploadTab> createState() => _FileUploadTabState();
}

class _FileUploadTabState extends State<FileUploadTab> with TickerProviderStateMixin {
  String? _fileName;
  String? _filePath;

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() {
        _fileName = result.files.single.name;
        _filePath = result.files.single.path;
      });
      await _savePdfPath(_filePath!);  // Save the PDF path to SharedPreferences
      _navigateToSelectRecording();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file selected')),
      );
    }
  }

  Future<void> _savePdfPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedPdfs = prefs.getStringList('pdfPaths') ?? [];
    if (!savedPdfs.contains(path)) {
      savedPdfs.add(path);
      await prefs.setStringList('pdfPaths', savedPdfs);
    }
  }

  Future<void> _navigateToSelectRecording() async {
    final recordings = await _loadRecordings();
    String? selectedRecording = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SelectRecordingScreen(recordings: recordings),
      ),
    );
    if (selectedRecording != null && _filePath != null) {
      await _navigateToPdfViewer(_filePath!);
    }
  }

  Future<void> _navigateToPdfViewer(String filePath) async {
    showDialog(
      context: context,
      barrierDismissible: false, // User must wait for processing to complete
      builder: (BuildContext context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Enhancing your notes...",
                    style: TextStyle(fontSize: 25)),
              ],
            ),
          ),
        );
      },
    );

    // Wait for a few seconds before closing the dialog and navigating
    await Future.delayed(Duration(seconds: 5));
    Navigator.pop(context);  // Dismiss the dialog

    // Now navigate to the PDF viewer screen
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => PdfViewerScreen(pdfPath: filePath),
    ));
  }

  Future<List<String>> _loadRecordings() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('recordings') ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: const ParticleOptions(
            baseColor: Colors.blue,
            spawnMinSpeed: 10,
            spawnMaxSpeed: 30,
            spawnMinRadius: 5,
            spawnMaxRadius: 10,
            particleCount: 50,
          ),
        ),
        vsync: this,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.note, size: 80, color: Theme.of(context).colorScheme.primary),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _pickFile,
                icon: Icon(Icons.file_upload),
                label: Text('Upload Notes', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  textStyle: TextStyle(fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (_fileName != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text('Selected file: $_fileName'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}