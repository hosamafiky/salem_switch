import 'package:flutter/material.dart';

class SalemSwitch extends StatefulWidget {
  const SalemSwitch({
    super.key,
    required this.onChanged,
    required this.value,
    this.activeColor = const Color(0xFF4CAF50),
    this.inactiveColor = const Color(0xFF9E9E9E),
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.width = 50.0,
    this.height = 30.0,
    this.enabled = true,
    this.disabledOpacity = 0.5,
    this.thumb,
    this.thumbMargin,
  });

  /// Determines if widget is enabled
  final bool enabled;

  /// Determines current state.
  final ValueChanged<bool> onChanged;

  /// Determines the current state of switch.
  final bool value;

  /// Determines background color for the active state.
  final Color activeColor;

  /// Determines background color for the inactive state.
  final Color inactiveColor;

  /// Determines border radius.
  final BorderRadius borderRadius;

  /// Determines width.
  final double width;

  /// Determines height.
  final double height;

  /// Determines opacity of disabled control.
  final double disabledOpacity;

  /// Thumb widget.
  final Widget? thumb;

  /// Thumb margin
  final EdgeInsetsGeometry? thumbMargin;

  @override
  AdvancedSwitchState createState() => AdvancedSwitchState();
}

class AdvancedSwitchState extends State<SalemSwitch> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 250);
  late ValueNotifier<bool> _controller;
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Color?> _colorAnimation;
  late double _thumbSize;

  @override
  void initState() {
    super.initState();

    _controller = ValueNotifier<bool>(widget.value);
    _controller.addListener(_handleControllerValueChanged);

    _animationController = AnimationController(
      vsync: this,
      duration: _duration,
      value: _controller.value ? 1.0 : 0.0,
    );

    _initAnimation();
  }

  @override
  void didUpdateWidget(covariant SalemSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller.value = widget.value;
    _initAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _handlePressed,
        child: Container(
          width: widget.width + _thumbSize + 8,
          height: widget.height + 8,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: Colors.grey[300]!, width: 1),
            gradient: const LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.white,
                Colors.grey,
              ],
            ),
          ),
          child: IntrinsicHeight(
            child: Opacity(
              opacity: widget.enabled ? 1 : widget.disabledOpacity,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (_, child) {
                  return ClipRRect(
                    borderRadius: widget.borderRadius,
                    clipBehavior: Clip.none,
                    child: Stack(
                      alignment: AlignmentDirectional.centerStart,
                      children: [
                        Container(
                          width: widget.width,
                          height: widget.height * .25,
                          decoration: BoxDecoration(
                            borderRadius: widget.borderRadius,
                            color: _colorAnimation.value,
                          ),
                        ),
                        child!,
                      ],
                    ),
                  );
                },
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: _slideAnimation.value,
                      child: child,
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.all(2),
                    width: _thumbSize - 4,
                    height: _thumbSize - 4,
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Colors.grey,
                          ],
                        ),
                      ),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.white,
                                Colors.grey,
                              ],
                            )),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _initAnimation() {
    _thumbSize = widget.height;

    final animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(-_thumbSize / 2, 0),
      end: Offset(-_thumbSize / 2 + widget.width, 0),
    ).animate(animation);

    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(animation);
  }

  void _handleControllerValueChanged() {
    if (_controller.value) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  void _handlePressed() {
    if (widget.enabled) {
      _controller.value = !_controller.value;
      widget.onChanged(_controller.value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerValueChanged);

    _controller.dispose();

    _animationController.dispose();

    super.dispose();
  }
}
