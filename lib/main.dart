import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ColorFilter Matrix Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ColorFilterDemo(),
    );
  }
}

class ColorFilterDemo extends StatefulWidget {
  @override
  ColorFilterDemoState createState() => ColorFilterDemoState();
}

class ColorFilterDemoState extends State<ColorFilterDemo> {
  ImagePainter imagePainter;
  List<bool> matrix;

  @override
  void initState() {
    super.initState();
    imagePainter = ImagePainter(this);
    matrix = List.generate(5 * 4, (_) => false);
    matrix[0 + 0 * 5] = true;
    matrix[1 + 1 * 5] = true;
    matrix[2 + 2 * 5] = true;
    matrix[3 + 3 * 5] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ColorFilter Matrix'),
      ),
      body: FutureBuilder(
        future: _loadImage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            imagePainter.image = snapshot.data;
          }
          return Container(
            color: Colors.black12,
            child: Center(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: _switchBoard(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: _canvas(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<ui.Image> _loadImage() async {
    final ByteData data = await rootBundle.load('assets/rgb-bands.png');
    final Completer<ui.Image> completer = new Completer();
    ui.decodeImageFromList(Uint8List.view(data.buffer), (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  Widget _canvas() {
    return LayoutBuilder(
      builder: (context, size) {
        return CustomPaint(
          painter: imagePainter,
          size: Size.square(size.maxWidth),
        );
      },
    );
  }

  Widget _switchBoard() {
    return Table(
      children: List.generate(
        4,
        (row) => TableRow(
          children: List.generate(
            5,
            (column) => Switch(
              value: matrix[column + row * 5],
              onChanged: (value) {
                setState(() {
                  matrix[column + row * 5] = value;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ImagePainter extends CustomPainter {
  ImagePainter(this.state);

  ColorFilterDemoState state;
  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = Colors.white;
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), paint);
    if (image != null) {
      paint.colorFilter = ColorFilter.matrix(List.generate(5 * 4, (index) {
        if ((index + 1) % 5 == 0) {
          return state.matrix[index] ? 255.0 : 0.0;
        }
        return state.matrix[index] ? 1.0 : 0.0;
      }));
      // Default matrix
      // 1.0, 0.0, 0.0, 0.0, 0,
      // 0.0, 1.0, 0.0, 0.0, 0,
      // 0.0, 0.0, 1.0, 0.0, 0,
      // 0.0, 0.0, 0.0, 1.0, 0,
      canvas.scale(size.width / image.width, size.height / image.height);
      canvas.drawImage(image, Offset.zero, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
