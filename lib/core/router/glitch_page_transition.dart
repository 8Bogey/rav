import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_glitch/animated_glitch.dart';
import 'package:audioplayers/audioplayers.dart';

class GlitchPageTransitionsBuilder extends PageTransitionsBuilder {
  const GlitchPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (kIsWeb) {
      return FadeTransition(
        opacity: CurveTween(curve: Curves.easeIn).animate(animation),
        child: child,
      );
    }

    return _GlitchTransitionWrapper(
      animation: animation,
      child: child,
    );
  }
}

class _GlitchTransitionWrapper extends StatefulWidget {
  final Animation<double> animation;
  final Widget child;

  const _GlitchTransitionWrapper({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  State<_GlitchTransitionWrapper> createState() =>
      _GlitchTransitionWrapperState();
}

class _GlitchTransitionWrapperState extends State<_GlitchTransitionWrapper> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  late final AnimatedGlitchController _glitchController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer.setVolume(1.0);
    _audioPlayer.setReleaseMode(ReleaseMode.stop);

    _glitchController = AnimatedGlitchController(
      frequency: const Duration(milliseconds: 60),
      chance: 100,
      level: 1.8,
      autoStart: false,
    );

    widget.animation.addStatusListener(_handleAnimationStatus);

    if (widget.animation.value > 0.0 && widget.animation.value < 1.0) {
      _startGlitch();
    }
  }

  void _handleAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.forward ||
        status == AnimationStatus.reverse) {
      _startGlitch();
    } else if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      _stopGlitch();
    }
  }

  Future<void> _startGlitch() async {
    if (!_isPlaying && mounted) {
      setState(() {
        _isPlaying = true;
      });
      _glitchController.start();
      try {
        await _audioPlayer.play(AssetSource('sounds/glitch.wav'));
      } catch (e) {
        debugPrint('Audio play error: $e');
      }
    }
  }

  Future<void> _stopGlitch() async {
    if (_isPlaying && mounted) {
      setState(() {
        _isPlaying = false;
      });
      _glitchController.stop();
      try {
        await _audioPlayer.stop();
      } catch (e) {
        debugPrint('Audio stop error: $e');
      }
    }
  }

  @override
  void dispose() {
    widget.animation.removeStatusListener(_handleAnimationStatus);
    _audioPlayer.dispose();
    _glitchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fadeAnimation = CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOut,
    );

    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: widget.animation,
      curve: Curves.easeOutQuart,
    ));

    Widget transitionChild = FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: widget.child,
      ),
    );

    // Apply glitch effect directly using the controller
    return AnimatedGlitch(
      controller: _glitchController,
      showColorChannels: true,
      showDistortions: true,
      child: transitionChild,
    );
  }
}
