// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorModel _$ErrorModelFromJson(Map<String, dynamic> json) {
  return ErrorModel(
    errorId: json['errorId'] as String,
    errorType: json['errorType'] as int,
    errorTitle: json['errorTitle'] as String,
    errorUserMessage: json['errorUserMessage'] as String,
    debugMessage: json['debugMessage'] as String,
    errorProc: json['errorProc'] as String,
  );
}

Map<String, dynamic> _$ErrorModelToJson(ErrorModel instance) =>
    <String, dynamic>{
      'errorId': instance.errorId,
      'errorType': instance.errorType,
      'errorTitle': instance.errorTitle,
      'errorUserMessage': instance.errorUserMessage,
      'debugMessage': instance.debugMessage,
      'errorProc': instance.errorProc,
    };
