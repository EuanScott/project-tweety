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
  radio,
  checkbox,
}
