class FormData {
  String name;
  FormInputType type;
  bool isRequired;
  String errorMessage;

  // TODO: Add in a function for handling the form input to return to the calling widget for actioning

  FormData({
    required this.name,
    required this.type,
    required this.isRequired,
    required this.errorMessage,
  });
}

enum FormInputType {
  text,
  number,
  dropdown,
  checkbox,
  multiCheckbox,
}

class FormOutputData {
  String key;
  dynamic value;

  FormOutputData({
    required this.key,
    required this.value,
  });
}
