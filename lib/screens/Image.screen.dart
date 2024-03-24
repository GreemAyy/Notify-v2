import 'package:notify/screens/Task.screen.dart';
import 'package:flutter/material.dart';

import '../custom_classes/task.dart';
import '../generated/l10n.dart';

class ImageScreen extends StatefulWidget {
  ImageScreen({
    super.key,
    required this.heroTag,
    required this.image
  });
  String heroTag;
  Widget image;

  @override
  State<StatefulWidget> createState() => _StateImageScreen();
}

class _StateImageScreen extends State<ImageScreen> with TickerProviderStateMixin{
  final _controller = TransformationController();
  late final AnimationController _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 150));
  Offset tapOffset = const Offset(0, 0);
  bool isZoomed = false;
  double yStart = 0;
  double yCurrent = 0;

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void onDoubleTap(){
    getMatrixZoom() => Matrix4.identity()
      ..translate(tapOffset.dx, tapOffset.dy)
      ..scale(3.0)
      ..translate(-tapOffset.dx,-tapOffset.dy);
    final matrixUnZoom = Matrix4.identity();
    final animReset = Matrix4Tween(
        begin: isZoomed ? getMatrixZoom() : _controller.value,
        end: isZoomed ? matrixUnZoom : getMatrixZoom()
    ).animate(_animController);

    setState(() => isZoomed = !isZoomed);

    _animController.addListener(() {
      _controller.value = animReset.value;
    });

    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        forceMaterialTransparency: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            padding: const EdgeInsets.all(15),
            icon: const Icon(
                Icons.arrow_back,
                color: Colors.white
            )
        )
      ),
      body: Hero(
          tag: widget.heroTag,
          child: Center(
            child: SizedBox(
              height: screenSize.height,
              width: screenSize.width,
              child: GestureDetector(
                onDoubleTapDown: (details){
                  tapOffset = details.globalPosition;
                },
                onDoubleTap: onDoubleTap,
                child: InteractiveViewer(
                  transformationController: _controller,
                  onInteractionEnd: (details){
                    var scale = _controller.value[0];
                    setState(() {
                      isZoomed = scale > 1.1;
                      var distance = (yCurrent-yStart).abs();
                      yStart = 0;
                      yCurrent = 0;
                      if(!isZoomed&&distance > 20){
                        Navigator.pop(context);
                      }
                    });
                  },
                  onInteractionStart: (details){
                    setState(() => yStart = details.localFocalPoint.dy);
                  },
                  onInteractionUpdate: (details){
                    setState(() => yCurrent = details.localFocalPoint.dy);
                  },
                  maxScale: 5,
                  minScale: .5,
                  panEnabled: true,
                  child: GestureDetector(
                    child: Stack(
                      children: [
                        AnimatedPositioned(
                            duration: const Duration(milliseconds: 100),
                            top: !isZoomed?(yCurrent-yStart):0,
                            child: widget.image
                        )
                      ]
                    )
                  )
                )
              )
            )
          )
        ),
      );
  }
}

class ImageWithTaskScreen extends StatelessWidget{
  ImageWithTaskScreen({
    super.key,
    required this.heroTag,
    required this.image,
    required this.task
  });
  String heroTag;
  Widget image;
  Task task;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final _S = S.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox(
          width: screenSize.width,
          height: screenSize.height,
          child: Stack(
              children: [
                ImageScreen(heroTag: heroTag, image: image),
                Positioned(
                    bottom: 0,
                    child: GestureDetector(
                        onTap: (){
                          showModalBottomSheet(
                              context: context,
                              enableDrag: false,
                              showDragHandle: true,
                              isScrollControlled: true,
                              builder: (context){
                                return SizedBox(
                                  height: screenSize.height*.85,
                                  child: TaskScreen(task: task, isChild: true)
                                );
                              }
                          );
                        },
                        child: Container(
                            height: 50,
                            width: screenSize.width,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(20),
                                topLeft: Radius.circular(20)
                              )
                            ),
                            child: Text(
                                '${_S.task} №${task.id}',
                                style: theme.textTheme.bodyLarge
                            )
                        )
                    )
                )
              ]
          )
      )
    );
  }
}