import 'package:scidart/numdart.dart';
import 'package:media_pipe_flutter/services/face_detection/anchors.dart';
import 'package:media_pipe_flutter/services/face_detection/convert_detection.dart';
import 'package:media_pipe_flutter/services/face_detection/detection.dart';
import 'package:media_pipe_flutter/services/face_detection/options.dart';

List<Detection> process(
    {required OptionsFace options,
      required List<double> rawScores,
      required List<double> rawBoxes,
      required List<Anchor> anchors}) {
  // var boxData = decodeBox(rawBoxes, anchors, options);
  var detectionScores = <double>[];
  var detectionClasses = <int>[];

  for (var i = 0; i < options.numBoxes; i++) {
    var classId = -1;
    var maxScore = double.minPositive;
    for (var scoreIdx = 0; scoreIdx < options.numClasses; scoreIdx++) {
      var score = rawScores[i * options.numClasses + scoreIdx];
      if (options.sigmoidScore) {
        if (options.scoreClippingThresh > 0) {
          score = (score < -options.scoreClippingThresh)
              ? -options.scoreClippingThresh
              : score;
          score = (score > options.scoreClippingThresh)
              ? options.scoreClippingThresh
              : score;
        }
        score = 1.0 / (1.0 + exp(-score));
      }
      if (maxScore < score) {
        maxScore = score;
        classId = scoreIdx;
      }
    }
    detectionClasses.add(classId);
    detectionScores.add(maxScore);
  }

  var detections = convertToDetections(
    rawBoxes,
    anchors,
    detectionScores,
    detectionClasses,
    options,
  );

  return detections;
}