export 'form_output_data.dart';

class FormOutputData {
  String key;
  dynamic value;

  FormOutputData({
    required this.key,
    required this.value,
  });

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'value': value,
    };
  }
}
