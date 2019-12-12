import 'package:flutter/material.dart';

class StepButton extends StatefulWidget {
  StepButton({this.steps, this.step, this.onChanged});

  final List<Widget> steps;
  final int step;
  final Function(int) onChanged;

  @override
  _StepButtonState createState() => _StepButtonState();
}

class _StepButtonState extends State<StepButton> {
  int step;

  @override
  void initState() {
    super.initState();
    step = widget.step;
  }

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      color: Colors.blue[100*(1+(5*step/widget.steps.length).floor())],
      child: widget.steps[step],
      onPressed: () {
        setState(() {
          step = (step+1)%widget.steps.length;
          widget.onChanged(step);
        });
      },
    );
  }
}
