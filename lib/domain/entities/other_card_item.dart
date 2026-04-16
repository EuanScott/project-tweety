import 'package:equatable/equatable.dart';

class OtherCardItem extends Equatable {
  const OtherCardItem({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  List<Object> get props => [title, description];
}
