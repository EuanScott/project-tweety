import 'package:equatable/equatable.dart';

class Card extends Equatable {
  const Card({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  List<Object> get props => [title, description];
}
