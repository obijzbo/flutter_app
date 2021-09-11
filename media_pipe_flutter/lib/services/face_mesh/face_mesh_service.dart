import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as image_lib;
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class FaceMesh {
  static const String MODEL_FILE_NAME = 'models/face_landmark.tflite';
  static const int INPUT_SIZE = 192;

  late InterpreterOptions _interpreterOptions;
  late Interpreter _interpreter;
  late ImageProcessor _imageProcessor;

  late List<List<int>> _outputShapes;
  late List<TfLiteType> _outputTypes;

  Interpreter get interpreter => _interpreter;

  FaceMesh({Interpreter? interpreter}) {
    //_loadModel(interpreter: interpreter);
    if(interpreter != null)
    {
      _loadModel(interpreter: interpreter);
    }
    else{
      print("Error: Interpreter can't be null");
    }
  }

  void _loadModel({required Interpreter interpreter}) async {
    try {
      _interpreterOptions = InterpreterOptions();

      _interpreter = interpreter ??
          await Interpreter.fromAsset(MODEL_FILE_NAME,
              options: _interpreterOptions);

      var outputTensors = _interpreter.getOutputTensors();
      _outputShapes = [];
      _outputTypes = [];
      outputTensors.forEach((tensor) {
        _outputShapes.add(tensor.shape);
        _outputTypes.add(tensor.type);
      });
    } catch (e) {
      print('Error while creating interpreter: $e');
    }
  }

  TensorImage _getProcessedImage(TensorImage inputImage) {
    _imageProcessor ??= ImageProcessorBuilder()
        .add(ResizeOp(INPUT_SIZE, INPUT_SIZE, ResizeMethod.BILINEAR))
        .add(NormalizeOp(0, 255))
        .build();

    inputImage = _imageProcessor.process(inputImage);
    return inputImage;
  }

  Map<String, dynamic>? predict(image_lib.Image image) {
    if (_interpreter == null) {
      print('Interpreter not initialized');
      return null;
    }

    if (Platform.isAndroid) {
      image = image_lib.copyRotate(image, -90);
      image = image_lib.flipHorizontal(image);
    }
    var tensorImage = TensorImage(TfLiteType.float32);
    tensorImage.loadImage(image);
    var inputImage = _getProcessedImage(tensorImage);

    TensorBuffer outputLandmarks = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[1]);

    var inputs = <Object>[inputImage.buffer];

    var outputs = <int, Object>{
      0: outputLandmarks.buffer,
      1: outputScores.buffer,
    };

    _interpreter.runForMultipleInputs(inputs, outputs);

    if (outputScores.getDoubleValue(0) < 0) {
      return null;
    }

    var landmarkPoints = outputLandmarks.getDoubleList().reshape([468, 3]);
    var landmarkResults = <Offset>[];
    for (var point in landmarkPoints) {
      landmarkResults.add(Offset(
        point[0] / INPUT_SIZE * image.width,
        point[1] / INPUT_SIZE * image.height,
      ));
    }

    return {'point': landmarkResults};
  }
}