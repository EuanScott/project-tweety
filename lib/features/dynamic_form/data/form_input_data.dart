export 'form_input_data.dart';

class FormInputData({
  required var String name,
  required var FormInputType type,
  required var bool isRequired,
  required var String errorMessage,
  var List<String>? inputOptions,
});

enum FormInputType {
  text,
  number,
  dropdown,
  // https://blog.prototypr.io/7-rules-of-using-radio-buttons-vs-drop-down-menus-fddf50d312d1
  radio,
  checkbox,
}
