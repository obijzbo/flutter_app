import 'dart:isolate';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:media_pipe_flutter/utils/isolate_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:media_pipe_flutter/services/face_mesh/face_mesh_painter.dart';
import 'package:media_pipe_flutter/services/face_mesh/face_mesh_service.dart';
import 'package:media_pipe_flutter/services/hands/hands_painter.dart';
import 'package:media_pipe_flutter/services/hands/hands_service.dart';
import 'package:media_pipe_flutter/services/pose/pose_painter.dart';
import 'package:media_pipe_flutter/services/pose/pose_service.dart';
import 'package:media_pipe_flutter/services/face_detection/face_detection_service.dart';

class CameraPage extends StatefulWidget {
  late String? title;
  late String? modelName;

  CameraPage({String? title, String? modelName}){
    this.title = title;
    this.modelName = modelName;
  }

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> with WidgetsBindingObserver {
  CameraController? _cameraController;
  late List<CameraDescription> _cameras;
  late CameraDescription _cameraDescription;

  late bool _isRun;
  bool _predicting = false;
  bool _draw = false;
  late double _ratio;
  late Size _screenSize;
  late Rect _bbox;
  late List<Offset> _faceLandmarks;
  late List<Offset> _handLandmarks;
  late List<Offset> _poseLandmarks;

  late FaceDetection _faceDetection;
  late FaceMesh _faceMesh;
  late Hands _hands;
  late Pose _pose;

  late IsolateUtils _isolateUtils;

  @override
  void initState() {
    WidgetsBinding.instance!.addObserver(this);
    initStateAsync();
    super.initState();
  }

  void initStateAsync() async {
    WidgetsBinding.instance!.addObserver(this);

    _isolateUtils = IsolateUtils();
    await _isolateUtils.start();

    await initCamera();

    switch (widget.modelName) {
      case 'face_detection':
        _faceDetection = FaceDetection();
        break;
      case 'face_mesh':
        _faceMesh = FaceMesh();
        break;
      case 'hands':
        _hands = Hands();
        break;
      case 'pose_landmark':
        _pose = Pose();
        break;
    }

    _predicting = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController!.dispose();
    } else if (state == AppLifecycleState.resumed) {
      onNewCameraSelected(_cameraController!.description);
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    _cameraController?.dispose();
    _cameraController = null;
    super.dispose();
  }

  // camera
  Future<void> initCamera() async {
    _cameras = await availableCameras();
    _cameraDescription = _cameras[1];
    _isRun = false;
    onNewCameraSelected(_cameraDescription);
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      // await _cameraController.dispose();
    }

    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    _cameraController!.addListener(() {
      if (mounted) setState(() {});
      if (_cameraController!.value.hasError) {
        showInSnackBar(
            'Camera error ${_cameraController!.value.errorDescription}');
      }
    });

    try {
      await _cameraController!.initialize().then((value) {
        if (!mounted) return;
      });
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _imageStreamToggle() {
    _isRun = !_isRun;
    if (_isRun) {
      _cameraController!.startImageStream(onLatestImageAvailable);
    } else {
      _cameraController!.stopImageStream();
    }
  }

  void _cameraDirectionToggle() {
    _isRun = false;
    if (_cameraController!.description.lensDirection ==
        _cameras.first.lensDirection) {
      onNewCameraSelected(_cameras.last);
    } else {
      onNewCameraSelected(_cameras.first);
    }
  }

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('message'),
      ),
    );
  }

  void _showCameraException(CameraException e) {
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }

  // Widget
  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        _imageStreamToggle();
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _buildAppBar(),
        body: _buildCameraPreview(),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }

  Row _buildFloatingActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        IconButton(
          onPressed: () {
            _cameraDirectionToggle();
            setState(() {
              _draw = false;
            });
          },
          color: Colors.white,
          iconSize: ScreenUtil().setWidth(30.0),
          icon: const Icon(
            Icons.cameraswitch,
          ),
        ),
        IconButton(
          onPressed: () {
            _imageStreamToggle();
            setState(() {
              _draw = !_draw;
            });
          },
          color: Colors.white,
          iconSize: ScreenUtil().setWidth(30.0),
          icon: const Icon(
            Icons.filter_center_focus,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    _ratio = _screenSize.width / _cameraController!.value.previewSize!.height;

    return Stack(
      children: [
        CameraPreview(_cameraController!),
        _drawBoundingBox(),
        _drawLandmarks(),
        _drawHands(),
        _drawPose(),
      ],
    );
  }

  Widget _drawBoundingBox() {
    Color color = Colors.primaries[0];
    if (_bbox == null || !_draw) {
      return Container();
    } else {
      return Positioned(
          left: _ratio * _bbox.left,
          top: _ratio * _bbox.top,
          width: _ratio * _bbox.width,
          height: _ratio * _bbox.height,
          child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: color, width: 3),
              )));
    }
  }

  Widget _drawLandmarks() {
    if (_faceLandmarks == null || !_draw) {
      return Container();
    } else {
      return CustomPaint(
        painter: FaceMeshPainter(
          points: _faceLandmarks,
          ratio: _ratio,
        ),
      );
    }
  }

  Widget _drawHands() {
    if (_handLandmarks == null || !_draw) {
      return Container();
    } else {
      return CustomPaint(
        painter: HandsPainter(
          points: _handLandmarks,
          ratio: _ratio,
        ),
      );
    }
  }

  Widget _drawPose() {
    if (_poseLandmarks == null || !_draw) {
      return Container();
    } else {
      return CustomPaint(
        painter: PosePainter(
          points: _poseLandmarks,
          ratio: _ratio,
        ),
      );
    }
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        widget.title ?? "fuck you",
        style: TextStyle(
            color: Colors.white,
            fontSize: ScreenUtil().setSp(28),
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> onLatestImageAvailable(CameraImage cameraImage) async {
    switch (widget.modelName) {
      case 'face_detection':
        await _inference(
          model: _faceDetection,
          cameraImage: cameraImage,
        );
        break;
      case 'face_mesh':
        await _inference(
          model: _faceMesh,
          cameraImage: cameraImage,
        );
        break;
      case 'hands':
        await _inference(
          model: _hands,
          cameraImage: cameraImage,
        );
        break;
      case 'pose_landmark':
        await _inference(
          model: _pose,
          cameraImage: cameraImage,
        );
        break;
    }
  }

  Future<void> _inference({
    dynamic model,
    CameraImage? cameraImage,
  }) async {
    if (model.interpreter != null) {
      if (_predicting || !_draw) {
        return;
      }

      setState(() {
        _predicting = true;
      });

      if (_draw) {
        var isolateData = IsolateData(
          cameraImage!,
          model.interpreter.address,
          widget.modelName ?? "fuck you too",
        );
        var inferenceResults = await _sendPort(isolateData);

        switch (widget.modelName) {
          case 'face_detection':
            _bbox = inferenceResults == null ? null : inferenceResults['bbox'];

            break;
          case 'face_mesh':
            _faceLandmarks =
            inferenceResults == null ? null : inferenceResults['point'];
            break;
          case 'hands':
            _handLandmarks =
            inferenceResults == null ? null : inferenceResults['point'];
            break;
          case 'pose_landmark':
            _poseLandmarks =
            inferenceResults == null ? null : inferenceResults['point'];
            break;
        }
      }

      setState(() {
        _predicting = false;
      });
    }
  }

  Future<Map<String, dynamic>> _sendPort(IsolateData isolateData) async {
    var responsePort = ReceivePort();
    _isolateUtils.sendPort
        .send(isolateData..responsePort = responsePort.sendPort);
    var results = await responsePort.first;
    return results;
  }
}