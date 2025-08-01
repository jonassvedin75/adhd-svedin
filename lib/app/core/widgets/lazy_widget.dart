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
