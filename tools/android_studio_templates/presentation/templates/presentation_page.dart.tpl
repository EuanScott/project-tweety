import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:__PACKAGE_NAME__/domain/entities/__ENTITY_NAME__.dart';
import 'package:__PACKAGE_NAME__/presentation/pages/__FEATURE_NAME__/bloc/__FEATURE_NAME___bloc.dart';

class __FEATURE_PASCAL__ extends StatelessWidget {
  const __FEATURE_PASCAL__({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<__FEATURE_PASCAL__Bloc>()..add(const __FEATURE_PASCAL__Started()),
      child: const ___FEATURE_PASCAL__View(),
    );
  }
}

class ___FEATURE_PASCAL__View extends StatelessWidget {
  const ___FEATURE_PASCAL__View();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<__FEATURE_PASCAL__Bloc, __FEATURE_PASCAL__State>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure) {
          return ___FEATURE_PASCAL__Error(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return ___FEATURE_PASCAL__List(items: state.items);
      },
    );
  }
}

class ___FEATURE_PASCAL__List extends StatelessWidget {
  const ___FEATURE_PASCAL__List({required this.items});

  final List<__ENTITY_PASCAL__> items;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: textTheme.titleMedium),
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class ___FEATURE_PASCAL__Error extends StatelessWidget {
  const ___FEATURE_PASCAL__Error({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () {
                context.read<__FEATURE_PASCAL__Bloc>().add(const __FEATURE_PASCAL__Started());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
