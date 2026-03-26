import 'dart:math';

/// Mock text generator by Valerii Novykov
/// https://medium.com/@valerii.novykov/how-to-create-a-flexible-mock-text-generator-utility-in-dart-for-ui-testing-ac924c6a63c7

enum MockTextType {
  /// Generate a specified number of words.
  words,

  /// Generate a specified number of sentences.
  sentences,

  /// Generate text up to a specified length.
  length,

  /// Generate a specified number of paragraphs.
  paragraphs
}

/// A utility class for generating mock text data of various types.
/// This class can generate words, sentences, paragraphs, or text of a specified length.
class MockTextGenerator {
  static final Random _random = Random();

  /// Generates mock text based on the specified [type] and [length].
  ///
  /// The [length] argument defines the number of words, sentences, paragraphs,
  /// or the length of the text, depending on the [type] argument.
  ///
  /// Returns the generated mock text as a [String].
  ///
  /// Example:
  /// ```dart
  /// String mockWords = MockTextGenerator.generate(type: MockTextType.words, length: 5);
  /// print(mockWords); // Lorem ipsum dolor sit amet
  /// ```
  static String generate({
    MockTextType type = MockTextType.words,
    int length = 50,
  }) {
    switch (type) {
      case MockTextType.words:
        return _generateWords(length);
      case MockTextType.sentences:
        return _generateSentences(length);
      case MockTextType.length:
        return _generateByLength(length);
      case MockTextType.paragraphs:
        return _generateParagraphs(length);
    }
  }

  static String _generateWords(int wordCount) {
    return List.generate(wordCount, (_) => _getRandomWord()).join(' ');
  }

  static String _generateByLength(int textLength) {
    String result = '';

    while (result.length < textLength) {
      final word = _getRandomWord();

      if (_canAppendWholeWord(result, word, textLength)) {
        result = _appendWord(result, word);
      } else {
        result = _appendPartialWord(result, word, textLength);
        break;
      }
    }

    return result;
  }

  static bool _canAppendWholeWord(String result, String word, int maxLength) {
    final newLength = result.length + word.length + (result.isEmpty ? 0 : 1);
    return newLength <= maxLength;
  }

  static String _appendWord(String result, String word) {
    return result + (result.isEmpty ? '' : ' ') + word;
  }

  static String _appendPartialWord(String result, String word, int maxLength) {
    final diff = maxLength - result.length;

    return result +
        (result.isEmpty ? '' : ' ') +
        word.substring(0, diff - (result.isEmpty ? 0 : 1));
  }

  static String _generateParagraphs(int paragraphCount) {
    final paragraphs =
        List.generate(paragraphCount, (_) => _generateParagraph());

    return paragraphs.join('\n\n');
  }

  static String _generateParagraph() {
    final sentenceCount = _random.nextInt(5) + 3; // 3 - 7 sentences

    return _generateSentences(sentenceCount);
  }

  static String _generateSentences(int sentenceCount) {
    final sentences = List.generate(sentenceCount, (_) => _generateSentence());

    return sentences.join(' ');
  }

  static String _generateSentence() {
    final wordCount = _random.nextInt(8) + 5; // 5 - 12 words

    final sentence =
        List.generate(wordCount, (_) => _getRandomWord()).join(' ');

    return '${sentence.capitalizeFirst()}.';
  }

  static String _getRandomWord() {
    return _words[_random.nextInt(_words.length)];
  }
}

const _words = [
  'Lorem',
  'ipsum',
  'dolor',
  'sit',
  'amet',
  'consectetur',
  'adipiscing',
  'elit',
  'sed',
  'do',
  'eiusmod',
  'tempor',
  'incididunt',
  'ut',
  'labore',
  'et',
  'dolore',
  'magna',
  'aliqua',
  'Ut',
  'enim',
  'ad',
  'minim',
  'veniam',
  'quis',
  'nostrud',
  'exercitation',
  'ullamco',
  'laboris',
  'nisi',
  'ut',
  'aliquip',
  'ex',
  'ea',
  'commodo',
  'consequat',
  'Duis',
  'aute',
  'irure',
  'dolor',
  'in',
  'reprehenderit',
  'in',
  'voluptate',
  'velit',
  'esse',
  'cillum',
  'dolore',
  'eu',
  'fugiat',
  'nulla',
  'pariatur',
  'Excepteur',
  'sint',
  'occaecat',
  'cupidatat',
  'non',
  'proident',
  'sunt',
  'in',
  'culpa',
  'qui',
  'officia',
  'deserunt',
  'mollit',
  'anim',
  'id',
  'est',
  'laborum'
];

extension _Capitalize on String {
  String capitalizeFirst() {
    if (isEmpty) {
      return this;
    }

    return "${this[0].toUpperCase()}${length > 1 ? substring(1).toLowerCase() : ''}";
  }
}