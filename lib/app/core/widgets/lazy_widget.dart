import 'package:flutter/material.dart';

/// Lazy loading-wrapper för att förbättra prestanda
class LazyWidget extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  
  const LazyWidget({
    super.key,
    required this.builder,
    this.placeholder,
  });

  @override
  State<LazyWidget> createState() => _LazyWidgetState();
}

class _LazyWidgetState extends State<LazyWidget> {
  late Future<Widget> _futureWidget;

  @override
  void initState() {
    super.initState();
    _futureWidget = _loadWidget();
  }

  Future<Widget> _loadWidget() async {
    // Simulera lazy loading med en kort delay
    await Future.delayed(const Duration(milliseconds: 10));
    return widget.builder();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: _futureWidget,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return snapshot.data!;
        } else {
          return widget.placeholder ?? 
                 const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

/// Cache för widgets som laddas dynamiskt
class WidgetCache {
  static final Map<String, Widget> _cache = {};
  
  static Widget? get(String key) => _cache[key];
  
  static void put(String key, Widget widget) {
    _cache[key] = widget;
  }
  
  static void clear() {
    _cache.clear();
  }
  
  static void remove(String key) {
    _cache.remove(key);
  }
}
