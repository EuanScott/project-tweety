import 'package:equatable/equatable.dart';

class Card extends Equatable {
  const Card({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;

  @override
  List<Object> get props => [id, title, description];
}
