import 'package:flutter/material.dart';

class VolumeControlWidget extends StatefulWidget {
  double volume;
  final void Function(double) onVolumeChanged;

  VolumeControlWidget(
      {super.key, required this.volume, required this.onVolumeChanged});

  @override
  State<VolumeControlWidget> createState() => _VolumeControlWidgetState();
}

class _VolumeControlWidgetState extends State<VolumeControlWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slider(
          activeColor: Colors.grey.shade900,
          value: widget.volume,
          onChanged: (newVolume) {
            setState(() {
              widget.volume = newVolume;
              widget.onVolumeChanged(widget.volume);
            });
          },
          min: 0.0,
          max: 1.0,
          divisions: 10,
        ),
        Text('Volume: ${(widget.volume * 100).toStringAsFixed(0)}%',
            style: TextStyle(color: Colors.white)),
      ],
    );
  }
}
