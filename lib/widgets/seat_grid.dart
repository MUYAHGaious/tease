import 'package:flutter/material.dart';
enum SeatState { available, selected, reserved }

class SeatGrid extends StatelessWidget {
  final int rows, cols;
  final Map<Offset, SeatState> initial;
  final void Function(Offset seat, SeatState state)? onChange;
  const SeatGrid({super.key, this.rows = 8, this.cols = 10, this.initial = const {}, this.onChange});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    const cell = 32.0;
    SeatState getState(int r, int c) => initial[Offset(r.toDouble(), c.toDouble())] ?? SeatState.available;

    return Wrap(
      spacing: 10, runSpacing: 10,
      children: List.generate(rows * cols, (i) {
        final r = i ~/ cols, c = i % cols;
        final state = getState(r, c);
        Color fill;
        switch (state) { case SeatState.reserved: fill = Colors.black; break;
          case SeatState.selected: fill = cs.primary; break;
          default: fill = Colors.grey.shade300; }
        return GestureDetector(
          onTap: state == SeatState.reserved ? null : () {
            final next = state == SeatState.selected ? SeatState.available : SeatState.selected;
            onChange?.call(Offset(r.toDouble(), c.toDouble()), next);
          },
          child: Container(width: cell, height: cell, decoration: BoxDecoration(color: fill, shape: BoxShape.circle)),
        );
      }),
    );
  }
}
