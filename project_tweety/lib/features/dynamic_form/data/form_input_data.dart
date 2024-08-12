export 'form_input_data.dart';

class FormInputData {
  String name;
  FormInputType type;
  bool isRequired;
  String errorMessage;
  List<dynamic>? inputOptions;

  FormInputData({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.errorMessage,
    this.inputOptions,
  });
}

enum FormInputType {
  text,
  number,
  dropdown,
  // https://blog.prototypr.io/7-rules-of-using-radio-buttons-vs-drop-down-menus-fddf50d312d1
  radio,
  checkbox,
}
