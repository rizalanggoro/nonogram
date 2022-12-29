import 'package:flutter/material.dart';
import 'package:nonogram/utils/game_engine.dart';
import 'package:widget_size/widget_size.dart';

class PageGame2 extends StatefulWidget {
  final int tileCount;
  final int maxFilledCount;

  const PageGame2({
    Key? key,
    required this.tileCount,
    required this.maxFilledCount,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PageGame2> with TickerProviderStateMixin {
  late Map<TileDataKey, List<List<int>>> _mapTileData;
  final ValueNotifier<int> _valueNotifierRender = ValueNotifier(0);

  double _leftClueContainerWidth = 0;
  double _tileSize = 0;
  bool _isTileOverflow = false;
  bool _isRenderLeftClueDone = false;

  late AnimationController _animationController;
  late Animation _animationTiles;

  @override
  Widget build(BuildContext context) {
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animationTiles = Tween<double>(begin: 0, end: 1).animate(
      _animationController,
    );

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _animationController.forward();
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: _body,
    );
  }

  get _screenWidth => MediaQuery.of(context).size.width;

  get _body {
    return FutureBuilder(
      future: GameEngine.generateTileDataMap(
        tileCount: widget.tileCount,
        maxFilledCount: widget.maxFilledCount,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _mapTileData = snapshot.data!;
          return _renderGame;
        }
        return Container();
      },
    );
  }

  get _renderGame {
    return Column(
      children: [
        // top clue
        _renderTopClue,

        // left clue & tiles
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _renderLeftClue,
            _isTileOverflow
                ? _renderTiles
                : Expanded(
                    child: _renderTiles,
                  ),
          ],
        ),
      ],
    );
  }

  get _renderTiles {
    return ValueListenableBuilder(
        valueListenable: _valueNotifierRender,
        builder: (context, value, child) {
          if (_isRenderLeftClueDone) {
            return Container(
              width: _isTileOverflow ? (_tileSize * widget.tileCount) : null,
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: widget.tileCount,
                ),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: _animationTiles,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _animationTiles.value,
                        child: Container(
                          alignment: Alignment.center,
                          color: Colors.green,
                          child: Text('a'),
                        ),
                      );
                    },
                  );
                },
                itemCount: (widget.tileCount * widget.tileCount),
              ),
            );
          } else {
            return Container();
          }
        });
  }

  get _renderTopClue {
    var list = _mapTileData[TileDataKey.filledCountRow]!;
    return ValueListenableBuilder(
      valueListenable: _valueNotifierRender,
      builder: (context, value, child) {
        return Container(
          margin: EdgeInsets.only(left: _leftClueContainerWidth),
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var a = 0; a < list.length; a++)
                Container(
                  alignment: Alignment.bottomCenter,
                  width: _tileSize,
                  child: Text(
                    list[a]
                        .toString()
                        .replaceAll('[', '')
                        .replaceAll(']', '')
                        .replaceAll(',', '\n')
                        .replaceAll(' ', ''),
                  ),
                )
            ],
          ),
        );
      },
    );
  }

  get _renderLeftClue {
    var list = _mapTileData[TileDataKey.filledCountRow]!;
    var renderRowIndex = 0;

    return WidgetSize(
      onChange: (size) {
        _leftClueContainerWidth = size.width;
        _tileSize = (_screenWidth - _leftClueContainerWidth) / widget.tileCount;

        var maxTileSize = 48.0;
        if (_tileSize > maxTileSize) {
          _tileSize = maxTileSize;
          _isTileOverflow = true;
        }

        if (renderRowIndex == (list.length - 1)) {
          _isRenderLeftClueDone = true;
          print('test -> $_leftClueContainerWidth');
        }
        _valueNotifierRender.value++;
        print(_leftClueContainerWidth);
      },
      child: ValueListenableBuilder(
          valueListenable: _valueNotifierRender,
          builder: (context, value, child) {
            return Container(
              color: Colors.red,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var a = 0; a < list.length; a++)
                    Builder(builder: (context) {
                      renderRowIndex = a;
                      return Container(
                        alignment: Alignment.centerRight,
                        height: _tileSize,
                        child: Text(
                          list[a]
                              .toString()
                              .replaceAll('[', '')
                              .replaceAll(']', '')
                              .replaceAll(',', ''),
                        ),
                      );
                    })
                ],
              ),
            );
          }),
    );
  }
}
