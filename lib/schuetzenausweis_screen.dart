import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_menu.dart';

class SchuetzenausweisScreen extends StatefulWidget {
  final int personId;

  const SchuetzenausweisScreen({Key? key, required this.personId}) : super(key: key);

  @override
  _SchuetzenausweisScreenState createState() => _SchuetzenausweisScreenState();
}

class _SchuetzenausweisScreenState extends State<SchuetzenausweisScreen> {
  late Future<Image> _imageFuture;

  @override
  void initState() {
    super.initState();
    _imageFuture = _loadImage();
  }

  Future<Image> _loadImage() async {
    final String url = 'http://127.0.0.1:3001/Schuetzenausweis/JPG/${widget.personId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        return Image.memory(response.bodyBytes);
      } else {
        throw Exception('Failed to load image: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Digitaler Schützenausweis'),
      ),
      endDrawer: Drawer( // Corrected: Use Drawer instead of EndDrawer
        child: AppMenu(
          context: context,
          userData: {'PERSONID': widget.personId},
        ),
      ),
      body: Center(
        child: FutureBuilder<Image>(
          future: _imageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              return snapshot.data!;
            }
          },
        ),
      ),
    );
  }
}