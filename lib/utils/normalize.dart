String normalizeText(String text) {
  String tempName = "";
  text = text.replaceAll("_", " ");
  text.split(" ").forEach((element) {
    if (_keepAllCaps.any((word) => element == word)) {
      tempName += "$element ";
    } else {
      String namePart = element.toLowerCase();
      if (!(_nonCapitalized).any((word) => namePart == word)) {
        tempName += "${namePart[0].toUpperCase()}${namePart.substring(1)} ";
      } else {
        tempName += "$namePart ";
      }
    }
  });
  return tempName.trim();
}

String normalizeName(String name) {
  String tempName = "";
  name.split(" ").forEach((element) {
    String namePart = element.toLowerCase();
    if (!["bin", "binti", "b", "bt"].any((word) => namePart == word)) {
      tempName += "${namePart[0].toUpperCase()}${namePart.substring(1)} ";
    } else {
      tempName += "$namePart ";
    }
  });
  return tempName.trim();
}

List<String> _keepAllCaps = [
  'ASP.NET',
  'IT',
  'PHP',
];

List<String> _nonCapitalized = [
  'a',
  'an',
  'and',
  'as',
  'at',
  'bin',
  'binti',
  'but',
  'by',
  'di',
  'en',
  'for',
  'from',
  'how',
  'if',
  'in',
  'neither',
  'nor',
  'of',
  'on',
  'only',
  'onto',
  'out',
  'or',
  'per',
  'so',
  'than',
  'that',
  'the',
  'to',
  'until',
  'up',
  'upon',
  'v',
  'v.',
  'versus',
  'vs',
  'vs.',
  'via',
  'when',
  'with',
  'without',
  'yet'
];
