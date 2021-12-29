extension StringExtension on String {
  String capitalLetter() {
    if (isEmpty) {
      return this;
    }
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}

extension Objects on List {
  List<dynamic> getListPage(int page) {
    var begin = page * 15;
    var end = begin + 15;
    return sublist(begin, length >= end ? end : length);
  }

  int getLastPage() {
    return (length - (length % 15)) ~/ 15;
  }
}

extension Times on DateTime {
  int secondsSinceEpoch() {
    return millisecondsSinceEpoch ~/ 1000;
  }
}
