import 'package:flutter/material.dart';

import '../data/form_data.dart';

class Library extends StatefulWidget {
  final List<FormData> formData;
  final List<FormOutputData> formResponse;

  const Library({
    super.key,
    required this.formData,
    required this.formResponse,
  });

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  final _formKey = GlobalKey<FormState>();
  List<FormData> formData = [
    FormData(
      name: "Text Input",
      type: FormInputType.text,
      isRequired: true,
      errorMessage: "Text input is required",
    ),
    FormData(
      name: "Numeric Input",
      type: FormInputType.number,
      isRequired: true,
      errorMessage: "Numeric input is required",
    ),
    FormData(
      name: "Dropdown",
      type: FormInputType.dropdown,
      isRequired: true,
      errorMessage: "Dropdown selection is required",
    ),
    FormData(
      name: "Checkbox",
      type: FormInputType.checkbox,
      isRequired: true,
      errorMessage: "Checkbox is required",
    ),
    FormData(
      name: "Multi Checkbox",
      type: FormInputType.multiCheckbox,
      isRequired: true,
      errorMessage: "At least one option must be selected",
    ),
  ];

  List<FormOutputData> formOutputData = [
    FormOutputData(key: 'textInput', value: ''),
    FormOutputData(key: 'numericInput', value: 0),
    FormOutputData(key: 'dropdownValue', value: 'Option 1'),
    FormOutputData(key: 'checkboxValue', value: []),
    FormOutputData(
        key: 'multiCheckboxValues',
        value: ['Option 1', 'Option 2', 'Option 3']),
  ];


  // TODO: Update this form to correctly make use of formData and formOutputData.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(children: [
                ...formData.asMap().entries.map((entry) {
                  int index = entry.key;
                  FormData formInput = entry.value;
                  switch (formInput.type) {
                    case FormInputType.text:
                      return TextFormField(
                        decoration: InputDecoration(labelText: formInput.name),
                        onChanged: (value) =>
                            formOutputData[index].value = value,
                      );
                    case FormInputType.number:
                      return TextFormField(
                        decoration: InputDecoration(labelText: formInput.name),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => formOutputData[index].value =
                            int.tryParse(value) ?? 0,
                      );
                    case FormInputType.dropdown:
                      return DropdownButtonFormField(
                        value: formOutputData[index].value,
                        onChanged: (newValue) {
                          setState(() {
                            formOutputData[index].value = newValue;
                          });
                        },
                        items: formOutputData[index]
                            .value
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      );
                    case FormInputType.checkbox:
                      return CheckboxListTile(
                        title: Text(formInput.name),
                        value: formOutputData[index].value,
                        onChanged: (bool? newValue) {
                          setState(() {
                            formOutputData[index].value = newValue!;
                          });
                        },
                      );
                    case FormInputType.multiCheckbox:
                      return Column(
                        children: formOutputData[index]
                            .value
                            .map((option) => CheckboxListTile(
                                  title: Text(option),
                                  value: formOutputData[index]
                                      .value
                                      .contains(option),
                                  onChanged: (bool? newValue) {
                                    setState(() {
                                      if (newValue == true) {
                                        formOutputData[index].value.add(option);
                                      } else {
                                        formOutputData[index]
                                            .value
                                            .remove(option);
                                      }
                                    });
                                  },
                                ))
                            .toList(),
                      );
                    default:
                      return const SizedBox
                          .shrink(); // This line is just a placeholder for unknown types
                  }
                }).toList(),
                ElevatedButton(
                  onPressed: () {
                    print(formOutputData);
                  },
                  child: const Text('Submit'),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
