import 'dart:isolate';

import 'package:camera/camera.dart';
import 'package:media_pipe_flutter/services/face_detection/face_detection_service.dart';
import 'package:media_pipe_flutter/services/hands/hands_service.dart';
import 'package:media_pipe_flutter/services/pose/pose_service.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

import 'package:media_pipe_flutter/services/face_mesh/face_mesh_service.dart';
import 'image_utils.dart';

/// Manages separate Isolate instance for inference
class IsolateUtils {
  static const String DEBUG_NAME = 'InferenceIsolate';

  final ReceivePort _receivePort = ReceivePort();

  late Isolate _isolate;
  late SendPort _sendPort;

  SendPort get sendPort => _sendPort;
  Isolate get isolate => _isolate;

  Future<void> start() async {
    _isolate = await Isolate.spawn<SendPort>(
      entryPoint,
      _receivePort.sendPort,
      debugName: DEBUG_NAME,
    );

    _sendPort = await _receivePort.first;
  }

  static void entryPoint(SendPort sendPort) async {
    final port = ReceivePort();
    sendPort.send(port.sendPort);

    await for (final IsolateData isolateData in port) {
      if (isolateData != null) {
        var results = _predict(
          modelName: isolateData.model,
          isolateData: isolateData,
        );

        isolateData.responsePort.send(results);
      }
    }
  }

  static Map<String, dynamic> _predict({
    required String modelName,
    required IsolateData isolateData,
  }) {
    var model;
    switch (modelName) {
      case 'face_detection':
        model = FaceDetection(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
        );
        break;
      case 'face_mesh':
        model = FaceMesh(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
        );
        break;
      case 'hands':
        model = Hands(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
        );
        break;
      case 'pose_landmark':
        model = Pose(
          interpreter: Interpreter.fromAddress(isolateData.interpreterAddress),
        );
        break;
    }
    var image = ImageUtils.convertCameraImage(isolateData.cameraImage);
    var results = model.predict(image);

    return results;
  }
}

class IsolateData {
  late CameraImage cameraImage;
  late int interpreterAddress;
  late String model;
  late SendPort responsePort;

  IsolateData(
      this.cameraImage,
      this.interpreterAddress,
      this.model,
      );
}