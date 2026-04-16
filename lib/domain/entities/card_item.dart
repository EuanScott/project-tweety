import 'package:equatable/equatable.dart';

class CardItem extends Equatable {
  const CardItem({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  List<Object> get props => [title, description];
}
