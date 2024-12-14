extension AppIterableExtension<T> on Iterable<T> {
  Iterable<T> removeAt(int index) sync* {
    var i = 0;
    
    for (final item in this) {
      if (i++ == index) continue;
      yield item;
    }
  }

  Iterable<T> replaceAt(int index, T Function(T) update) sync* {
    var i = 0;
    
    for (final item in this) {
      yield i++ == index ? update(item) : item;
    }
  }

  List<T> orderBy<V>(V Function(T) select, [int Function(V, V)? compare]) {
    final list = toList();

    list.sort((l, r) {
      final lv = select(l);
      final rv = select(r);

      if (compare == null) {
        return (lv as Comparable<V>).compareTo(rv);
      }

      return compare(lv, rv);
    });

    return list;
  }
}
