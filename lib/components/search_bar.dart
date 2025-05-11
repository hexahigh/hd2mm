import 'dart:async';

import 'package:flutter/material.dart';

class SearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController controller;
  final Duration debounceTime;

  SearchBar({
    required this.onSearch,
    TextEditingController? controller,
    this.debounceTime = const Duration(milliseconds: 500),
    super.key,
  }) : controller = controller ?? TextEditingController();

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 3,
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              hintText: "Search",
            ),
          ),
        ),
        IconButton(
          onPressed: _clear,
          icon: const Icon(Icons.backspace),
        ),
      ],
    );
  }

  void _clear() {
    if (widget.controller.text.isEmpty) return;
    widget.controller.clear();
    widget.onSearch(widget.controller.text);
  }

  void _onTextChanged() {
    if (_timer?.isActive ?? false) _timer!.cancel();
    _timer = Timer(widget.debounceTime, () {
      final query = widget.controller.text;
      widget.onSearch(query);
    });
  }
}