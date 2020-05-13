
import 'package:ive_flutter_core_mobile/database/base_service.dart';

import 'package:json_annotation/json_annotation.dart';

part 'error_model.g.dart';

@JsonSerializable(fieldRename: FieldRename.none)
class ErrorModel implements BaseModel {
  ErrorModel({
    this.errorId,
    this.errorType,
    this.errorTitle,
    this.errorUserMessage,
    this.debugMessage,
    this.errorProc
    
  });

  factory ErrorModel.fromJson(Map<String, dynamic> json) => _$ErrorModelFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$ErrorModelToJson(this);

  final String errorId;
  final int errorType;
  final String errorTitle;
  final String errorUserMessage;
  final String debugMessage;
  final String errorProc;
}



