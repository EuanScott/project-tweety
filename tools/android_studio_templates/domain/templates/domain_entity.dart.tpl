import 'package:equatable/equatable.dart';

class __ENTITY_PASCAL__ extends Equatable {
  const __ENTITY_PASCAL__({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  List<Object> get props => [title, description];
}
