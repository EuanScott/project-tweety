import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';

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
        inputOptions: [
          'Option 1',
          'Option 2',
          'Option 3',
          'Option 4',
          'Option 5',
          'Option 6',
          'Option 7'
        ]),
    FormInputData(
      name: "Radio",
      type: FormInputType.radio,
      isRequired: true,
      errorMessage: "Checkbox is required",
      inputOptions: ['Yes', 'No', 'Maybe'],
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

  // TODO: Find a better way of handling this (this isn't dynamic)
  bool? checkboxValue = false;

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
                    // TODO: The UI should not accept non-numbers and should inform the user of as much
                    case FormInputType.number:
                      return TextFormField(
                        decoration: InputDecoration(labelText: formInput.name),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => formOutputData[index].value =
                            int.tryParse(value) ?? 0,
                      );
                    case FormInputType.dropdown:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formInput.name),
                          DropdownButtonFormField(
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
                          ),
                        ],
                      );
                    case FormInputType.radio:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formInput.name),
                          Column(
                            children: formInput.inputOptions!
                                .map((option) => RadioListTile<String>(
                                      title: Text(option),
                                      value: option,
                                      groupValue: formOutputData[index].value,
                                      onChanged: (value) {
                                        setState(() {
                                          formOutputData[index].value = value;
                                        });
                                      },
                                    ))
                                .toList(),
                          ),
                        ],
                      );
                    case FormInputType.checkbox:
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(formInput.name),
                          CheckboxListTile(
                            title: Text(formInput.name),
                            value: checkboxValue,
                            onChanged: (bool? value) {
                              setState(() {
                                formOutputData[index].value = checkboxValue = value;
                              });
                            },
                          ),
                        ],
                      );
                  }
                }),
                ElevatedButton(
                  onPressed: () {
                    String jsonData = jsonEncode(
                      formOutputData.map((data) => data.toJson()).toList(),
                    );
                    log(jsonData);
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

class RadioButtonWidget extends StatefulWidget {
  final String title;
  final Function(bool) onChanged;

  const RadioButtonWidget({
    super.key,
    required this.title,
    required this.onChanged,
  });

  @override
  RadioButtonWidgetState createState() => RadioButtonWidgetState();
}

class RadioButtonWidgetState extends State<RadioButtonWidget> {
  bool _radioValue = false;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<bool>(
      title: Text(widget.title),
      value: true,
      groupValue: _radioValue,
      onChanged: (bool? value) {
        setState(() {
          _radioValue = value ?? false;
          widget.onChanged(_radioValue);
        });
      },
    );
  }
}
