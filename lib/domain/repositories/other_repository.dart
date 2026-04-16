import 'package:project_tweety/domain/entities/other_card_item.dart';

abstract class OtherRepository {
  Future<List<OtherCardItem>> getOtherCardItems();
}
