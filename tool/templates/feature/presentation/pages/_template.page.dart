import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/_template.bloc.dart';

part 'widgets/_template_view.widget.dart';

class TemplatePage extends StatelessWidget {
  const TemplatePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<TemplateBloc>()..add(const TemplateStarted()),
      child: const PageScaffold(title: '_template', body: _TemplateView()),
    );
  }
}
