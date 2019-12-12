import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'button.dart';

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
  List<int> matrix;

  @override
  void initState() {
    super.initState();
    imagePainter = ImagePainter(this);
    matrix = List.generate(5 * 4, (_) => 0);
    matrix[0 + 0 * 5] = 1;
    matrix[1 + 1 * 5] = 2;
    matrix[2 + 2 * 5] = 3;
    matrix[3 + 3 * 5] = 4;
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
                    padding: EdgeInsets.all(10),
                    child: _canvas(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: _matrixBoard(),
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

  Widget _matrixBoard() {
    return Table(
      children: List.generate(
        4,
        (row) => TableRow(
          children: List.generate(
            5,
            (column) => Padding(
              padding: const EdgeInsets.only(left: 4, right: 4),
              child: StepButton(
                steps: column==4 ? [
                  Text('0'),
                  Text('64'),
                  Text('128'),
                  Text('190'),
                  Text('255'),
                ] : [
                  Text('0.0'),
                  Text('0.25'),
                  Text('0.5'),
                  Text('0.75'),
                  Text('1.0'),
                ],
                step: matrix[column + row * 5],
                onChanged: (value) {
                  setState(() {
                    matrix[column + row * 5] = value;
                  });
                },
              ),
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
          return [
            0.0, 64.0, 128.0, 190.0, 255.0
          ][state.matrix[index]];
        }
        return state.matrix[index]/4;
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
