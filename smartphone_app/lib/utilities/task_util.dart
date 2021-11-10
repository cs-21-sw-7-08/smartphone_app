import 'dart:async';

import 'package:flutter/material.dart';
import 'package:future_progress_dialog/future_progress_dialog.dart';
import 'package:smartphone_app/widgets/custom_dialog.dart';

// ignore: implementation_imports
import 'package:async/src/cancelable_operation.dart' show CancelableOperation;
import 'package:smartphone_app/widgets/custom_progress_dialog.dart';

class TaskUtil {
  static Future<T?> _syncNullable<T>(Future<T?> Function() function) {
    return Future.value(function());
  }

  /// Run task
  /// [buildContext] is the context used for the dialog
  /// [doInBackground] is the task run in the background
  /// [afterBackground] is the function run after the background work
  /// [taskCancelled] is the function run if the user cancels the task
  static Future<T?> runTask<T>(
      {required BuildContext buildContext,
      required String progressMessage,
      required Future<T?> Function(bool Function() runTask) doInBackground,
      required Function() taskCancelled}) async {
    var runTask = true;
    CancelableOperation<T?>? cancelableOperation;

    // Run on UI
    Future task = Future.delayed(const Duration(milliseconds: 500), () async {
      // Operation
      cancelableOperation =
          CancelableOperation.fromFuture(_syncNullable(() async {
        if (!runTask) return null;
        // Do background work
        T? response = await doInBackground(() {
          return runTask;
        });
        return response;
      }), onCancel: () => null);
      // Wait for value
      var returnValue = await cancelableOperation!.valueOrCancellation();
      // Check if task has been cancelled
      if (cancelableOperation!.isCanceled) {
        Future.delayed(Duration.zero, () {
          taskCancelled();
        });
        return null;
      }
      return returnValue;
    });

    return await Future.delayed(Duration.zero, () async {
      // Show dialog
      return await showDialog(
          context: buildContext,
          builder: (context) => CustomProgressDialog(
                task,
                progressMessage: progressMessage,
                onCancelPressed: (dialog) {
                  if (cancelableOperation != null) {
                    cancelableOperation!.cancel();
                  }
                  runTask = false;
                  Navigator.of(context).pop();
                  taskCancelled();
                },
              ),
          barrierDismissible: false);
    });
  }
}
