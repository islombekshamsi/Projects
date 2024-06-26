keyboard = { # Corresponding russian letters to qwerty keyboard
    'ф': 'a',
    'и': 'b',
    'с': 'c',
    'в': 'd',
    'у': 'e',
    'а': 'f',
    'п': 'g',
    'р': 'h',
    'ш': 'i',
    'о': 'j',
    'л': 'k',
    'д': 'l',
    'ь': 'm',
    'т': 'n',
    'щ': 'o',
    'з': 'p',
    'й': 'q',
    'к': 'r',
    'ы': 's',
    'е': 't',
    'г': 'u',
    'м': 'v',
    'ц': 'w',
    'ч': 'x',
    'н': 'y',
    'я': 'z',
    'э': "'",
    'ю': '.',
    'ъ': ']',
    'б': ',',
    'х': '['
}
text = "Input your text that was supposed to be in english ,but"
text += " \naccidentally forgot to turn on english keyboard. "
sentence = (input(text)).lower()
words = sentence.split()
converted_words = []
for word in words:
    converted_word = ''
    for char in word:
        if char in keyboard:
            converted_word += keyboard[char]
        else:
            converted_word += char
    converted_words.append(converted_word)

converted_sentence = ' '.join(converted_words)
print(converted_sentence)
