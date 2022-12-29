import 'dart:math';

enum TileDataKey {
  tileData,
  filledCountRow,
  emptyIndexRow,
  filledCountCol,
  emptyIndexCol,
}

class GameEngine {
  static List<List<int>> generateEmpty({
    required int tileCount,
    required List<List<int>> tileData,
  }) {
    List<List<int>> result = [];
    var random = Random();
    List<List<int>> listFalseMap = [];
    for (var a = 0; a < tileCount; a++) {
      List<int> list = [];
      for (var b = 0; b < tileCount; b++) {
        var correctData = tileData[a][b];
        if (correctData == 0) {
          List<int> c = [];
          c.add(a);
          c.add(b);
          listFalseMap.add(c);
        }
        list.add(-1);
      }
      result.add(list);
    }

    if (tileCount > 5) {
      var maxAutoFillCount = listFalseMap.length ~/ 2;
      for (var a = 0; a < maxAutoFillCount; a++) {
        var randomIndex = random.nextInt(listFalseMap.length);
        var listMap = listFalseMap[randomIndex];
        // var autoFill = random.nextBool();
        // if (autoFill) {
        result[listMap[0]][listMap[1]] = 0;
        listFalseMap.removeAt(randomIndex);
        // }
      }
    }
    return result;
  }

  static Future<Map<TileDataKey, List<List<int>>>> _generateFilledAndEmpty({
    required int tileCount,
    required List<List<int>> listTileData,
    required bool isRow,
  }) async {
    Map<TileDataKey, List<List<int>>> result = {};

    List<List<int>> listFilledCount = [];
    List<List<int>> listEmptyIndex = [];

    for (var a = 0; a < tileCount; a++) {
      List<int> listFC = [];
      List<int> listEI = [];
      var count = 0;

      for (var b = 0; b < tileCount; b++) {
        var data = isRow ? listTileData[a][b] : listTileData[b][a];

        if (data == 1) {
          count++;
          if (b == (tileCount - 1) && count > 0) {
            listFC.add(count);
          }
        } else {
          listEI.add(b);
          if (count > 0) {
            listFC.add(count);
            count = 0;
          }
        }
      }

      listFilledCount.add(listFC);
      listEmptyIndex.add(listEI);
    }

    result[isRow ? TileDataKey.filledCountRow : TileDataKey.filledCountCol] =
        listFilledCount;
    result[isRow ? TileDataKey.emptyIndexRow : TileDataKey.emptyIndexCol] =
        listEmptyIndex;

    return result;
  }

  static Future<Map<TileDataKey, List<List<int>>>> generateTileDataMap({
    required int tileCount,
    required int maxFilledCount,
  }) async {
    Map<TileDataKey, List<List<int>>> result = {};

    var random = Random();

    // generate random list tile data
    List<List<int>> listTileData = [];
    for (var a = 0; a < tileCount; a++) {
      List<int> list = [];
      for (var b = 0; b < tileCount; b++) {
        var data = random.nextInt(2);
        list.add(data);
      }
      listTileData.add(list);
    }

    List<List<int>> listFilledCountRow = [];
    List<List<int>> listEmptyIndexRow = [];
    {
      var mapFilledEmptyRow = await _generateFilledAndEmpty(
        tileCount: tileCount,
        listTileData: listTileData,
        isRow: true,
      );
      listFilledCountRow = mapFilledEmptyRow[TileDataKey.filledCountRow]!;
      listEmptyIndexRow = mapFilledEmptyRow[TileDataKey.emptyIndexRow]!;

      for (var a = 0; a < tileCount; a++) {
        var size = listFilledCountRow[a].length;
        if (size > maxFilledCount) {
          while (listFilledCountRow[a].length > maxFilledCount) {
            var randIndex = random.nextInt(listEmptyIndexRow[a].length);
            var index = listEmptyIndexRow[a][randIndex];

            listTileData[a][index] = 1;
            mapFilledEmptyRow = await _generateFilledAndEmpty(
              tileCount: tileCount,
              listTileData: listTileData,
              isRow: true,
            );
            listFilledCountRow = mapFilledEmptyRow[TileDataKey.filledCountRow]!;
            listEmptyIndexRow = mapFilledEmptyRow[TileDataKey.emptyIndexRow]!;
          }
        }
      }
    }

    List<List<int>> listFilledCountCol = [];
    List<List<int>> listEmptyIndexCol = [];
    {
      var mapFilledEmptyCol = await _generateFilledAndEmpty(
        tileCount: tileCount,
        listTileData: listTileData,
        isRow: false,
      );
      listFilledCountCol = mapFilledEmptyCol[TileDataKey.filledCountCol]!;
      listEmptyIndexCol = mapFilledEmptyCol[TileDataKey.emptyIndexCol]!;

      for (var a = 0; a < tileCount; a++) {
        var size = listFilledCountCol[a].length;
        if (size > maxFilledCount) {
          while (listFilledCountCol[a].length > maxFilledCount) {
            var randIndex = random.nextInt(listEmptyIndexCol[a].length);
            var index = listEmptyIndexCol[a][randIndex];

            listTileData[index][a] = 1;
            mapFilledEmptyCol = await _generateFilledAndEmpty(
              tileCount: tileCount,
              listTileData: listTileData,
              isRow: false,
            );
            listFilledCountCol = mapFilledEmptyCol[TileDataKey.filledCountCol]!;
            listEmptyIndexCol = mapFilledEmptyCol[TileDataKey.emptyIndexCol]!;
          }
        }
      }
    }

    // regenerate filled and empty
    var mapFilledEmptyRow = await _generateFilledAndEmpty(
      tileCount: tileCount,
      listTileData: listTileData,
      isRow: true,
    );
    listFilledCountRow = mapFilledEmptyRow[TileDataKey.filledCountRow]!;
    listEmptyIndexRow = mapFilledEmptyRow[TileDataKey.emptyIndexRow]!;

    var mapFilledEmptyCol = await _generateFilledAndEmpty(
      tileCount: tileCount,
      listTileData: listTileData,
      isRow: false,
    );
    listFilledCountCol = mapFilledEmptyCol[TileDataKey.filledCountCol]!;
    listEmptyIndexCol = mapFilledEmptyCol[TileDataKey.emptyIndexCol]!;

    result[TileDataKey.tileData] = listTileData;
    result[TileDataKey.filledCountRow] = listFilledCountRow;
    result[TileDataKey.filledCountCol] = listFilledCountCol;

    return result;
  }
}
