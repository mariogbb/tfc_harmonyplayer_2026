enum Ranking { allTime, lastMonth, monthRange, lastYear }

class RankingData {
  final Ranking type;
  final int? extra;

  RankingData({required this.type, this.extra});
}
