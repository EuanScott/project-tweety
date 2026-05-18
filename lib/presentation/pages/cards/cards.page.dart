import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:navigation/navigation.dart';
import 'package:project_tweety/domain/entities/card/card.entity.dart'
    as card_model
    show Card;
import 'package:project_tweety/l10n/app_localizations.dart';
import 'package:project_tweety/presentation/navigation/navigation_extensions.dart';
import 'package:project_tweety/presentation/navigation/tabs/app_tab.dart';
import 'package:project_tweety/presentation/widgets/app_bar.dart';
import 'package:project_tweety/presentation/widgets/page_scaffold.dart';

import 'bloc/cards.bloc.dart';
import 'card_details/card_details.page.dart';

class Cards extends StatefulWidget {
  const Cards({this.selectedCardId, super.key});

  final String? selectedCardId;

  @override
  State<Cards> createState() => _CardsState();
}

class _CardsState extends State<Cards> {
  static const double _secondaryBreakpoint = 600;
  static const double _compactListWidth = 260;
  static const double _defaultListWidth = 320;

  final ScrollController _scrollController = ScrollController();
  late String? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _selectedCardId = widget.selectedCardId;
  }

  @override
  void didUpdateWidget(Cards oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.selectedCardId != widget.selectedCardId) {
      _selectedCardId = widget.selectedCardId;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<CardsBloc>()..add(const CardsStarted()),
      child: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;

          return TabReselectHandler(
            tab: AppTab.cards,
            onReselect: _scrollToTop,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showSecondary =
                    constraints.maxWidth >= _secondaryBreakpoint;
                final selectedCardId = _selectedCardId;

                if (!showSecondary && widget.selectedCardId != null) {
                  return CardDetailsPage(cardId: widget.selectedCardId!);
                }

                return PageScaffold(
                  title: l10n.cardsTab,
                  trailingAction: CustomAppBarAction(
                    icon: Icons.refresh,
                    tooltip: 'Refresh cards',
                    onPressed: () {
                      context.read<CardsBloc>().add(const CardsStarted());
                    },
                  ),
                  primaryBodyWidth: _listWidthFor(constraints),
                  secondaryBreakpoint: _secondaryBreakpoint,
                  secondaryBody: selectedCardId == null
                      ? const CardDetailsEmptyState()
                      : CardDetailsContent(cardId: selectedCardId),
                  body: _CardsView(
                    scrollController: _scrollController,
                    selectedCardId: selectedCardId,
                    onCardSelected: (cardId) => _selectCard(
                      context,
                      cardId,
                      showSecondary: showSecondary,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  double _listWidthFor(BoxConstraints constraints) {
    if (constraints.maxWidth < 620) {
      return _compactListWidth;
    }

    return _defaultListWidth;
  }

  void _selectCard(
    BuildContext context,
    String cardId, {
    required bool showSecondary,
  }) {
    if (showSecondary) {
      setState(() {
        _selectedCardId = cardId;
      });
      return;
    }

    context.openCardDetails(cardId);
  }

  void _scrollToTop() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }
}

class _CardsView extends StatelessWidget {
  const _CardsView({
    required this.scrollController,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  final ScrollController scrollController;
  final String? selectedCardId;
  final ValueChanged<String> onCardSelected;

  @override
  Widget build(BuildContext context) {
    // TODO: buildWhen and listenWhen for small dedicated UI tasks (snackbar or only conditional rebuilds required)
    return BlocBuilder<CardsBloc, CardsState>(
      builder: (context, state) {
        if (state.isInitial || state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.isFailure) {
          return _CardsError(
            message: state.errorMessage ?? 'Something went wrong.',
          );
        }

        return _CardsList(
          items: state.items,
          scrollController: scrollController,
          selectedCardId: selectedCardId,
          onCardSelected: onCardSelected,
        );
      },
    );
  }
}

class _CardsList extends StatelessWidget {
  static const EdgeInsets _listPadding = EdgeInsets.symmetric(vertical: 8);

  const _CardsList({
    required this.items,
    required this.scrollController,
    required this.selectedCardId,
    required this.onCardSelected,
  });

  final List<card_model.Card> items;
  final ScrollController scrollController;
  final String? selectedCardId;
  final ValueChanged<String> onCardSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      controller: scrollController,
      padding: _listPadding,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item.id == selectedCardId;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          color: theme.cardTheme.color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected
                  ? theme.colorScheme.primary
                  : Colors.transparent,
              width: 2,
            ),
          ),
          elevation: 3,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onCardSelected(item.id),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(item.description, style: theme.textTheme.bodyMedium),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CardsError extends StatelessWidget {
  const _CardsError({required this.message});

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
            ElevatedButton(
              onPressed: () {
                context.read<CardsBloc>().add(const CardsStarted());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
