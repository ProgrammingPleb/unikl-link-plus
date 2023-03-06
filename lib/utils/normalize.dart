String normalizeText(String text) {
  String tempName = "";
  text = text.replaceAll("_", " ");
  text.split(" ").forEach((element) {
    if (["ASP.NET", "IT", "PHP"].any((word) => element.contains(word))) {
      tempName += "$element ";
    } else {
      String namePart = element.toLowerCase();
      if (!(_nonCapitalized + ["di"]).any((word) => namePart == word)) {
        tempName += "${namePart[0].toUpperCase()}${namePart.substring(1)} ";
      } else {
        tempName += "$namePart ";
      }
    }
  });
  return tempName.trim();
}

List<String> _nonCapitalized = [
  'a',
  'an',
  'and',
  'as',
  'at',
  'but',
  'by',
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
