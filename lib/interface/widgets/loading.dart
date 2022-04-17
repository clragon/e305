import 'package:e305/interface/widgets/animation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loading_indicator/loading_indicator.dart';

class BoxSized extends StatelessWidget {
  final double size;
  final EdgeInsets? padding;
  final Widget child;
  const BoxSized({required this.child, required this.size, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      padding: padding ?? const EdgeInsets.all(4),
      child: child,
    );
  }
}

class SizedCircularProgressIndicator extends StatelessWidget {
  final double size;
  final double? value;

  const SizedCircularProgressIndicator({required this.size, this.value});

  @override
  Widget build(BuildContext context) {
    return BoxSized(
        child: CircularProgressIndicator(
          value: value,
        ),
        size: size);
  }
}

class PulseLoadingIndicator extends StatelessWidget {
  final double size;
  const PulseLoadingIndicator({required this.size});

  @override
  Widget build(BuildContext context) {
    return BoxSized(
        child: LoadingIndicator(
          indicatorType: Indicator.ballScaleRipple,
          colors: [Theme.of(context).iconTheme.color!],
        ),
        size: size);
  }
}

class OrbitLoadingIndicator extends StatelessWidget {
  final double size;
  const OrbitLoadingIndicator({required this.size});

  @override
  Widget build(BuildContext context) {
    return BoxSized(
      size: size,
      child: LoadingIndicator(
        indicatorType: Indicator.orbit,
        colors: [Theme.of(context).iconTheme.color!],
      ),
    );
  }
}

class LoadingScreen<T> extends StatefulWidget {
  final Future<T> Function() provide;
  final Widget Function(BuildContext context, T value) builder;

  const LoadingScreen({required this.provide, required this.builder});

  @override
  _LoadingScreenState createState() => _LoadingScreenState<T>();
}

class _LoadingScreenState<T> extends State<LoadingScreen<T>> {
  T? value;
  Exception? error;

  Future<void> getValue() async {
    try {
      value = await widget.provide();
      setState(() {});
    } on Exception catch (error) {
      setState(() {
        this.error = error;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getValue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: value == null
          ? AppBar(
              leading: const CloseButton(),
            )
          : null,
      body: CrossFade(
        showChild: error != null,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: const [
            Icon(
              FontAwesomeIcons.exclamationTriangle,
              size: 20,
            ),
            Padding(
              padding: EdgeInsets.all(8),
              child: Text('failed to load'),
            ),
          ],
        ),
        secondChild: SafeCrossFade(
          showChild: value != null,
          builder: (context) => widget.builder(context, value!),
          secondChild: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Flexible(
                child: Center(
                  child: OrbitLoadingIndicator(size: 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
