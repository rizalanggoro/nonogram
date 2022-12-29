import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'dart:math';

import 'package:nonogram/utils/game_engine.dart';
import 'package:toast/toast.dart';

class PageGame extends StatefulWidget {
  final int tileCount;
  final int maxFilledCount;

  const PageGame({
    Key? key,
    required this.tileCount,
    required this.maxFilledCount,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PageGame> {
  late List<List<int>> _listUserTileData;

  late Map<TileDataKey, List<List<int>>> _mapTileData;
  bool _isTileDataGenerated = false;

  // final int _tileCount = 8;
  // final int _maxFilledCount = 3;

  final ValueNotifier<double> _valueNotifierClueSize = ValueNotifier(0);
  final ValueNotifier<int> _valueNotifierFillType = ValueNotifier(0);
  final ValueNotifier<int> _valueNotifierTileUpdate = ValueNotifier(0);
  final ValueNotifier<int> _valueNotifierLives = ValueNotifier(5);

  final GlobalKey _globalKeyLeftClueContainer = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (_globalKeyLeftClueContainer.currentContext != null) {
        var leftClueContainerSize =
            _globalKeyLeftClueContainer.currentContext!.size;
        var leftClueContainerWidth = leftClueContainerSize!.width;
        _valueNotifierClueSize.value =
            ((_screenWidth - leftClueContainerWidth - 8) / widget.tileCount);

        var maxTileSize = 48.0;
        if (_valueNotifierClueSize.value > maxTileSize) {
          _valueNotifierClueSize.value = maxTileSize;
        }
      } else {
        setState(() {});
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: _isTileDataGenerated
          ? _renderGame()
          : FutureBuilder(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  _isTileDataGenerated = true;
                  _mapTileData = snapshot.data!;
                  _listUserTileData = GameEngine.generateEmpty(
                    tileCount: widget.tileCount,
                    tileData: _mapTileData[TileDataKey.tileData]!,
                  );
                  return _renderGame();
                } else {
                  return Text('Loading...');
                }
              },
              future: GameEngine.generateTileDataMap(
                tileCount: widget.tileCount,
                maxFilledCount: widget.maxFilledCount,
              ),
            ),
    );
  }

  double get _screenWidth => MediaQuery.of(context).size.width;

  int _getColIndex(int index) =>
      index - (_getRowIndex(index) * widget.tileCount);

  int _getRowIndex(int index) => (index) ~/ widget.tileCount;

  TextStyle get _clueTextStyle => TextStyle(
        fontSize: Theme.of(context).textTheme.caption!.fontSize,
        color: Colors.indigo.shade400,
      );

  void _fillTile(var rowIndex, var colIndex) {
    var isFilled = _valueNotifierFillType.value == 0;
    var listTileData = _mapTileData[TileDataKey.tileData]!;
    var correctData = listTileData[rowIndex][colIndex];

    if (correctData == (isFilled ? 1 : 0)) {
      _listUserTileData[rowIndex][colIndex] = isFilled ? 1 : 0;
    } else {
      _listUserTileData[rowIndex][colIndex] = correctData;
      if (_valueNotifierLives.value > 1) {
        _valueNotifierLives.value--;
      } else {
        _valueNotifierLives.value = 0;
        print('game over');
        Toast.show('Game Over!');
        Navigator.pop(context);
      }
    }

    _fillCross(rowIndex, colIndex);
    _checkWin();
    _valueNotifierTileUpdate.value++;
  }

  void _checkWin() {
    var result = const DeepCollectionEquality()
        .equals(_mapTileData[TileDataKey.tileData]!, _listUserTileData);
    if (result) {
      print('game done!');
      Toast.show('Done!');
      Navigator.pop(context);
    }
  }

  void _fillCross(var rowIndex, var colIndex) {
    // fill row
    {
      if (_listUserTileData[rowIndex].contains(-1)) {
        var correctListFilledCountRow =
            _mapTileData[TileDataKey.filledCountRow]![rowIndex];

        var userListFilledCountRow = [];
        var userListEmptyIndexRow = [];
        var rowCount = 0;
        for (var a = 0; a < widget.tileCount; a++) {
          var data = _listUserTileData[rowIndex][a];

          if (data == -1) {
            userListEmptyIndexRow.add(a);
          }

          if (data == 1) {
            rowCount++;
            if (a == (widget.tileCount - 1) && rowCount > 0) {
              userListFilledCountRow.add(rowCount);
            }
          } else {
            if (rowCount > 0) {
              userListFilledCountRow.add(rowCount);
              rowCount = 0;
            }
          }
        }

        var result = const DeepCollectionEquality()
            .equals(correctListFilledCountRow, userListFilledCountRow);
        if (result) {
          for (var a in userListEmptyIndexRow) {
            _listUserTileData[rowIndex][a] = 0;
          }
        }
      }

      // fill col
      {
        var listUserTileData = [];
        for (var a = 0; a < widget.tileCount; a++) {
          listUserTileData.add(_listUserTileData[a][colIndex]);
        }

        var correctListFilledCountCol =
            _mapTileData[TileDataKey.filledCountCol]![colIndex];

        var userListFilledCountCol = [];
        var userListEmptyIndexCol = [];
        var colCount = 0;
        for (var a = 0; a < widget.tileCount; a++) {
          var data = listUserTileData[a];

          if (data == -1) {
            userListEmptyIndexCol.add(a);
          }

          if (data == 1) {
            colCount++;
            if (a == (widget.tileCount - 1) && colCount > 0) {
              userListFilledCountCol.add(colCount);
            }
          } else {
            if (colCount > 0) {
              userListFilledCountCol.add(colCount);
              colCount = 0;
            }
          }
        }

        var result = const DeepCollectionEquality()
            .equals(correctListFilledCountCol, userListFilledCountCol);
        if (result) {
          for (var a in userListEmptyIndexCol) {
            _listUserTileData[a][colIndex] = 0;
          }
        }
      }
    }
  }

  get _renderStats {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Colors.black.withOpacity(.08)),
          )),
      height: 72,
      child: Stack(
        children: [
          // back button
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.only(left: 8),
              child: Material(
                clipBehavior: Clip.hardEdge,
                color: Colors.transparent,
                borderRadius: const BorderRadius.all(Radius.circular(56 / 2)),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SizedBox(
                    height: 56,
                    width: 56,
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ),
            ),
          ),

          Align(
            alignment: Alignment.center,
            child: Text(
              'Easy',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          // money
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                color: Colors.grey.shade100,
              ),
              margin: const EdgeInsets.only(right: 16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.military_tech_rounded,
                    color: Colors.amber,
                    size: Theme.of(context).textTheme.subtitle1!.fontSize,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '100',
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyText1!.fontSize,
                      color: Colors.grey.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  get _renderLives {
    return ValueListenableBuilder(
        valueListenable: _valueNotifierLives,
        builder: (context, value, child) {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var a = 0; a < 5; a++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: Theme.of(context).textTheme.headline5!.fontSize,
                      color: a < _valueNotifierLives.value
                          ? Colors.red
                          : Colors.red.shade100,
                    ),
                  ),
              ],
            ),
          );
        });
  }

  get _renderFillType {
    return ValueListenableBuilder(
      valueListenable: _valueNotifierFillType,
      builder: (context, value, child) {
        var icons = [Icons.square_rounded, Icons.close_rounded];
        return Container(
          margin: const EdgeInsets.only(bottom: 32),
          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(4),
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 8,
                )
              ],
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var a = 0; a < 2; a++)
                  Container(
                    margin: EdgeInsets.only(left: a != 0 ? 4 : 0),
                    child: Material(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(6)),
                        clipBehavior: Clip.hardEdge,
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _valueNotifierFillType.value = a;
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: _valueNotifierFillType.value == a
                                  ? Colors.indigo
                                  : Colors.transparent,
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
                            ),
                            height: 48,
                            width: 48,
                            child: Icon(
                              icons[a],
                              color: _valueNotifierFillType.value == a
                                  ? Colors.white
                                  : Colors.indigo,
                            ),
                          ),
                        )),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  get _renderLeftClue {
    var listFilledCountRow = _mapTileData[TileDataKey.filledCountRow]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      key: _globalKeyLeftClueContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var a = 0; a < listFilledCountRow.length; a++)
            ValueListenableBuilder(
                valueListenable: _valueNotifierClueSize,
                builder: (context, double value, child) {
                  return Container(
                    alignment: Alignment.centerRight,
                    height: value,
                    child: Text(
                      listFilledCountRow[a]
                          .toString()
                          .replaceAll(',', '')
                          .replaceAll('[', '')
                          .replaceAll(']', ''),
                      style: _clueTextStyle,
                    ),
                  );
                }),
        ],
      ),
    );
  }

  get _renderTopClue {
    var listFilledCountCol = _mapTileData[TileDataKey.filledCountCol]!;
    return Container(
      margin: const EdgeInsets.only(bottom: 8, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var a = 0; a < listFilledCountCol.length; a++)
            ValueListenableBuilder(
                valueListenable: _valueNotifierClueSize,
                builder: (context, double value, child) {
                  return Container(
                    alignment: Alignment.bottomCenter,
                    width: value,
                    child: Text(
                      listFilledCountCol[a]
                          .toString()
                          .replaceAll(',', '\n')
                          .replaceAll(' ', '')
                          .replaceAll('[', '')
                          .replaceAll(']', ''),
                      style: _clueTextStyle,
                      textAlign: TextAlign.center,
                    ),
                  );
                }),
        ],
      ),
    );
  }

  get _renderTiles {
    return ValueListenableBuilder(
        valueListenable: _valueNotifierClueSize,
        builder: (context, double value, child) {
          return Container(
            width: (value * widget.tileCount),
            height: (value * widget.tileCount),
            margin: const EdgeInsets.only(right: 8),
            child: GridView.builder(
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                crossAxisCount: widget.tileCount,
              ),
              itemBuilder: (context, index) {
                var colIndex = _getColIndex(index);
                var rowIndex = _getRowIndex(index);

                var debug = false;
                var list = debug
                    ? _mapTileData[TileDataKey.tileData]!
                    : _listUserTileData;
                var isFilled = list[rowIndex][colIndex] == 1;
                var isEmpty = list[rowIndex][colIndex] == -1;

                var isFirstCol = colIndex == 0;
                var isFirstRow = rowIndex == 0;

                return Container(
                    clipBehavior: Clip.hardEdge,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(4)),
                      // border: Border(
                      //   top: BorderSide(
                      //     color: isFirstRow ? Colors.transparent : Colors.white,
                      //     width: isFirstRow ? 0 : 1.32,
                      //   ),
                      //   left: BorderSide(
                      //     color: isFirstCol ? Colors.transparent : Colors.white,
                      //     width: isFirstCol ? 0 : 1.32,
                      //   ),
                      // ),
                      color: isFilled ? Colors.indigo : Colors.indigo.shade50,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _fillTile(rowIndex, colIndex),
                        child: Container(
                          width: value,
                          height: value,
                          child: isEmpty
                              ? null
                              : isFilled
                                  ? null
                                  : Icon(
                                      Icons.close_rounded,
                                      color: Colors.indigo,
                                      size: value,
                                    ),
                        ),
                      ),
                    ));
              },
              itemCount: (widget.tileCount * widget.tileCount),
            ),
          );
        });
  }

  _renderGame() {
    return Column(
      children: [
        SafeArea(child: Container()),
        _renderStats,
        _renderLives,
        const Spacer(),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // left clue
            _renderLeftClue,

            Expanded(
              child: Column(
                children: [
                  _renderTopClue,
                  ValueListenableBuilder(
                    valueListenable: _valueNotifierTileUpdate,
                    builder: (context, value, child) => _renderTiles,
                  ),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        _renderFillType,
      ],
    );
  }
}
