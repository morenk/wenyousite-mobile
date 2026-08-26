import 'package:wenyousite_mobile/core/widgets/wenyou_markdown.dart';
import 'package:wenyousite_mobile/features/threads/domain/thread_detail_models.dart';

Map<String, String> threadDiceLabels(List<ThreadDiceRollModel> rolls) {
  return {
    for (final roll in rolls)
      roll.nodeId.toLowerCase(): '${roll.notation} = ${roll.total}',
  };
}

Map<String, String> threadDiceSemantics(List<ThreadDiceRollModel> rolls) {
  return {
    for (final roll in rolls)
      roll.nodeId.toLowerCase(): formatWenyouDiceSemantics(
        notation: roll.notation,
        results: roll.results,
        total: roll.total,
      ),
  };
}

Map<String, WenyouDiceRollDetail> threadDiceDetails(
  List<ThreadDiceRollModel> rolls,
) {
  return {
    for (final roll in rolls)
      roll.nodeId.toLowerCase(): WenyouDiceRollDetail(
        results: roll.results,
        total: roll.total,
      ),
  };
}
