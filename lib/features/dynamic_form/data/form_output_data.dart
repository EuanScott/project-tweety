export 'form_output_data.dart';

class FormOutputData({required var String key, required var dynamic value}) {
  Map<String, dynamic> toJson() {
    return {'key': key, 'value': value};
  }
}
