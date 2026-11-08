import 'package:flutter/material.dart';

/// Builds tabs on first visit and keeps their state and scroll position afterward.
class TabContent extends StatefulWidget {
  const TabContent({super.key, required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<TabContent> createState() => _TabContentState();
}

class _TabContentState extends State<TabContent> {
  final Set<int> _visited = {};

  @override
  Widget build(BuildContext context) {
    _visited.add(widget.index);
    return IndexedStack(
      index: widget.index,
      children: [
        for (var i = 0; i < widget.children.length; i++)
          if (_visited.contains(i))
            widget.children[i]
          else
            const SizedBox.shrink(),
      ],
    );
  }
}
