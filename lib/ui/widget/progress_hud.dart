import 'package:flutter/material.dart';
// import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:aishshreya/utils/constants.dart';

///
/// Wrap around any widget that makes an async call to show a modal progress
/// indicator while the async call is in progress.
///
/// The progress indicator can be turned on or off using [inAsyncCall]
///
/// The progress indicator defaults to a [CircularProgressIndicator] but can be
/// any kind of widget
///
/// The progress indicator can be positioned using [offset] otherwise it is
/// centered
///
/// The modal barrier can be dismissed using [dismissible]
///
/// The color of the modal barrier can be set using [color]
///
/// The opacity of the modal barrier can be set using [opacity]
///
/// HUD=Heads Up Display
///
class ProgressHUD extends StatelessWidget {
  final double opacity;
  final Color color;
  final Widget progressIndicator = LoadingAnimationWidget.dotsTriangle(color: K.themeColorPrimary, size: 15);
  final Offset? offset;
  final bool dismissible;
  final Widget child;
  final ValueNotifier<bool> notifier;
  final bool initialLoading;

  final KeyCallback? getKey;

  ProgressHUD({
    Key? key,
    this.getKey,
    this.opacity = 0.3,
    this.color = Colors.grey,
    required this.notifier,
    this.offset,
    this.initialLoading = false,
    this.dismissible = false,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //if (!inAsyncCall) return child;

    Widget layOutProgressIndicator;
    if (offset == null) {
      layOutProgressIndicator = Center(child: progressIndicator);
    } else {
      layOutProgressIndicator = Positioned(
        child: progressIndicator,
        left: offset!.dx,
        top: offset!.dy,
      );
    }

    return Stack(
      children: [
        child,
        ProgressWidget(
            notifier: notifier,
            dismissible: dismissible,
            color: color,
            opacity: opacity,
            initialLoading: initialLoading,
            layOutProgressIndicator: layOutProgressIndicator),
      ],
    );
  }
}

class ProgressWidget extends StatefulWidget {
  const ProgressWidget({
    Key? key,
    required this.notifier,
    required this.dismissible,
    required this.color,
    required this.opacity,
    required this.initialLoading,
    required this.layOutProgressIndicator,
  }) : super(key: key);

  final bool dismissible;
  final Color color;
  final double opacity;
  final bool initialLoading;
  final Widget layOutProgressIndicator;
  final ValueNotifier<bool> notifier;

  @override
  ProgressState createState() => ProgressState();
}

class ProgressState extends State<ProgressWidget> {

  ProgressState();

  @override
  Widget build(BuildContext context) {
    //print('progress called');
    return ValueListenableBuilder(
        valueListenable: widget.notifier,
        builder: (context, bool loading, child) {
          return !loading
              ? Container()
              : Stack(
                  children: [
                    Opacity(
                      child: ModalBarrier(dismissible: widget.dismissible, color: widget.color),
                      opacity: widget.opacity,
                    ),
                    widget.layOutProgressIndicator,
                  ],
                );
        });
  }
}

typedef KeyCallback = void Function(GlobalKey<ProgressState>? val);
