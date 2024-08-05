import 'package:flutter/material.dart';
import 'dart:convert';

import '../data/data.dart';

class DynamicForm extends StatefulWidget {
  final List<FormInputData> inputData;
  final List<FormOutputData> outputData;

  const DynamicForm({
    super.key,
    required this.inputData,
    required this.outputData,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();

  // TODO: Pass in from the calling page this formInputData
  List<FormInputData> formInputData = [
    FormInputData(
      name: "Text Input",
      type: FormInputType.text,
      isRequired: true,
      errorMessage: "Text input is required",
    ),
    FormInputData(
      name: "Numeric Input",
      type: FormInputType.number,
      isRequired: true,
      errorMessage: "Numeric input is required",
    ),
    FormInputData(
        name: "Dropdown",
        type: FormInputType.dropdown,
        isRequired: true,
        errorMessage: "Dropdown selection is required",
        inputOptions: ['Option 1', 'Option 2', 'Option 3']),
    FormInputData(
      name: "Radio",
      type: FormInputType.radio,
      isRequired: true,
      errorMessage: "Checkbox is required",
    ),
    FormInputData(
      name: "Checkbox",
      type: FormInputType.checkbox,
      isRequired: true,
      errorMessage: "At least one option must be selected",
    ),
  ];

  List<FormOutputData> formOutputData = [
    FormOutputData(key: 'textValue', value: ''),
    FormOutputData(key: 'numericValue', value: 0),
    FormOutputData(key: 'dropdownValue', value: ''),
    FormOutputData(key: 'radioValue', value: ''),
    FormOutputData(key: 'checkboxValue', value: [])
  ];

  // TODO: Update this form to correctly make use of FormInputData and formOutputData.
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
                ...formInputData.asMap().entries.map((entry) {
                  int index = entry.key;
                  FormInputData formInput = entry.value;
                  switch (formInput.type) {
                    case FormInputType.text:
                      return TextFormField(
                        decoration: InputDecoration(labelText: formInput.name),
                        onChanged: (value) =>
                            formOutputData[index].value = value,
                      );
                    // TODO: Don't all input that isn't a number. The UI should not accept non-numbers and should inform the user of as much
                    case FormInputType.number:
                      return TextFormField(
                        decoration: InputDecoration(labelText: formInput.name),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => formOutputData[index].value =
                            int.tryParse(value) ?? 0,
                      );
                      // TODO: Get this to display properly
                    case FormInputType.dropdown:
                      if (formInput.inputOptions != null) {
                        return DropdownButtonFormField(
                          value: formInput.inputOptions![0],
                          onChanged: (newValue) {
                            setState(() {
                              formOutputData[index].value = newValue;
                            });
                          },
                          items: formInput.inputOptions!
                              .map((option) => DropdownMenuItem(
                                    value: option,
                                    child: Text(option),
                                  ))
                              .toList(),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    // TODO: Create the Radio button here
                    // TODO: Create the Checkbox button here
                    default:
                      return const SizedBox
                          .shrink(); // This line is just a placeholder for unknown types
                  }
                }),
                ElevatedButton(
                  onPressed: () {
                    String jsonData = jsonEncode(
                      formOutputData.map((data) => data.toJson()).toList(),
                    );
                    print(jsonData);
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
