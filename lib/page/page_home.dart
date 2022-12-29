import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nonogram/page/page_game.dart';
import 'package:nonogram/utils/game_data.dart';

class PageHome extends StatefulWidget {
  const PageHome({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _State();
}

class _State extends State<PageHome> with TickerProviderStateMixin {
  late AnimationController _animationControllerBody;
  late Animation _animationBody;
  late Animation _animationBodyShadow;
  late Animation _animationLevel;
  bool _isPlayClicked = false;

  @override
  Widget build(BuildContext context) {
    _animationControllerBody = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animationBody = Tween<double>(begin: 1, end: .84).animate(
      _animationControllerBody,
    );
    _animationBodyShadow = Tween<double>(begin: 0, end: .32).animate(
      _animationControllerBody,
    );
    _animationLevel = Tween<double>(begin: 0, end: 1).animate(
      _animationControllerBody,
    );

    // _animationControllerBody.forward();

    return Scaffold(
      backgroundColor: Colors.white,
      body: _render,
    );
  }

  get _render {
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _animationBody,
          builder: (context, child) {
            return Transform.scale(
              scaleX: _animationBody.value,
              scaleY: _animationBody.value,
              child: _body,
            );
          },
        ),
        AnimatedBuilder(
            animation: _animationBodyShadow,
            builder: (context, child) {
              var value = _animationBodyShadow.value;
              if (value == 0) {
                return Container();
              }
              return Opacity(
                opacity: _animationBodyShadow.value,
                child: _renderBodyShadow,
              );
            }),
        AnimatedBuilder(
            animation: _animationLevel,
            builder: (context, child) {
              var value = _animationLevel.value;
              if (value == 0) {
                return Container();
              }
              return Opacity(
                opacity: _animationLevel.value,
                child: _renderLevel,
              );
            }),
      ],
    );
  }

  get _renderBodyShadow {
    return InkWell(
        focusColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          _isPlayClicked = false;
          _animationControllerBody.reverse();
        },
        child: Container(
          color: Colors.black,
        ));
  }

  get _renderLevel {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                left: 32,
                right: 32,
                top: 32,
              ),
              child: Text(
                'Choose Level',
                style: TextStyle(
                  color: Colors.grey.shade900,
                  fontWeight: FontWeight.bold,
                  fontSize: Theme.of(context).textTheme.headline6!.fontSize,
                ),
              ),
            ),
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(0),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: EdgeInsets.only(top: index == 0 ? 16 : 0),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: index == 0
                            ? Colors.transparent
                            : Colors.grey.shade200,
                        width: index == 0 ? 0 : 1.32,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        var tileCount = GameData.level[index]['tileCount'];
                        var maxFilledCount =
                            GameData.level[index]['maxFilledCount'];

                        _isPlayClicked = false;
                        _animationControllerBody.reverse();

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PageGame(
                                  tileCount: tileCount,
                                  maxFilledCount: maxFilledCount),
                            ));
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        child: Row(
                          children: [
                            Text(
                              GameData.level[index]['title'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: Theme.of(context)
                                    .textTheme
                                    .bodyText1!
                                    .fontSize,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.indigo,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: GameData.level.length,
            ),

            // button cancel
            Container(
              margin: const EdgeInsets.only(
                left: 32,
                right: 32,
                bottom: 32,
                top: 32,
              ),
              width: double.infinity,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _isPlayClicked = false;
                    _animationControllerBody.reverse();
                  },
                  child: Container(
                    alignment: Alignment.center,
                    height: 48,
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  get _body {
    var buttonPlaySize = 72.0;

    return Column(
      children: [
        // app bar
        Container(
          height: (48 + 32),
          padding: const EdgeInsets.only(right: 16, left: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'org.anggoro',
                style: GoogleFonts.dancingScript(
                  color: Colors.grey.shade600,
                ),
              ),
              Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      SystemNavigator.pop();
                    },
                    child: const SizedBox(
                      height: 48,
                      width: 48,
                      child: Icon(
                        Icons.exit_to_app_outlined,
                        color: Colors.red,
                      ),
                    ),
                  ))
            ],
          ),
        ),

        const Spacer(),
        // title
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.center,
          child: Text(
            'Nonogram',
            textAlign: TextAlign.center,
            style: GoogleFonts.yesevaOne(
              color: Colors.grey.shade900,
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.headline3!.fontSize,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          alignment: Alignment.center,
          child: Text(
            'Puzzle',
            textAlign: TextAlign.center,
            style: GoogleFonts.yesevaOne(
              color: Colors.indigo,
              fontWeight: FontWeight.bold,
              fontSize: Theme.of(context).textTheme.headline3!.fontSize,
            ),
          ),
        ),

        // button play
        Container(
          margin: const EdgeInsets.only(top: 32),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(buttonPlaySize / 2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.08),
                blurRadius: 8,
              )
            ],
            color: Colors.white,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!_isPlayClicked) {
                  _animationControllerBody.forward();
                } else {
                  _animationControllerBody.reverse();
                }
                _isPlayClicked = !_isPlayClicked;
              },
              child: SizedBox(
                height: buttonPlaySize,
                width: buttonPlaySize,
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.indigo,
                  size: 32,
                ),
              ),
            ),
          ),
        ),

        // stats
        // Container(
        //   margin: const EdgeInsets.only(left: 16, right: 16, top: 32),
        //   padding: const EdgeInsets.all(16),
        //   width: double.infinity,
        //   decoration: BoxDecoration(
        //     borderRadius: const BorderRadius.all(Radius.circular(16)),
        //     color: Colors.white,
        //     boxShadow: [
        //       BoxShadow(
        //         color: Colors.black.withOpacity(.08),
        //         blurRadius: 8,
        //       )
        //     ],
        //   ),
        //   child: Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Text(
        //         'Stats',
        //         style: TextStyle(
        //           fontSize: Theme.of(context).textTheme.subtitle1!.fontSize,
        //         ),
        //       ),
        //     ],
        //   ),
        // ),

        const Spacer(),
      ],
    );
  }
}
