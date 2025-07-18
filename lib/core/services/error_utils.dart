// Utility to parse and classify errors for user-friendly display
import 'package:graphql_flutter/graphql_flutter.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

String parseError(BuildContext context, dynamic error) {
  if (error is OperationException) {
    // GraphQL-specific errors
    if (error.linkException != null) {
      final linkEx = error.linkException!;
      if (linkEx is NetworkException) {
        return FlutterI18n.translate(context, 'no_internet') ?? 'No internet connection.';
      } else if (linkEx is ServerException) {
        // Check if the underlying cause is a SocketException (no internet)
        if (linkEx.originalException is SocketException) {
          return FlutterI18n.translate(context, 'no_internet') ?? 'No internet connection.';
        }
        return FlutterI18n.translate(context, 'server_error') ?? 'Server error. Please try again later.';
      }
    }
    if (error.graphqlErrors.isNotEmpty) {
      return error.graphqlErrors.map((e) => e.message).join('\n');
    }
    return FlutterI18n.translate(context, 'unknown_error') ?? 'Unknown GraphQL error.';
  } else if (error is SocketException) {
    return FlutterI18n.translate(context, 'no_internet') ?? 'No internet connection.';
  } else if (error is TimeoutException) {
    return FlutterI18n.translate(context, 'timeout_error') ?? 'Request timed out. Please try again.';
  } else if (error is FormatException) {
    return FlutterI18n.translate(context, 'data_format_error') ?? 'Data format error.';
  } else if (error is Exception) {
    // Instead of returning error.toString(), return a generic message
    return FlutterI18n.translate(context, 'something_went_wrong') ??
        FlutterI18n.translate(context, 'unknown_error') ??
        'Something went wrong. Please try again.';
  }
  return FlutterI18n.translate(context, 'unknown_error') ?? 'An unknown error occurred.';
} 