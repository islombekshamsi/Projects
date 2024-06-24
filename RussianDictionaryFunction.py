import json
from difflib import get_close_matches

'''  get_close_matches(word, possibilities, n = 3, cutoff = 0.6) 
сutoff gives the ratio that should be higher in order to match'''

data = json.load(open("dictionary.json"))


def multi_purpose(word, purpose):
    purpose = purpose.lower()
    close_matches = get_close_matches(word, [item['name'] for item in data['wordlist']])
    for item in data['wordlist']:
        if item['name'] == word:
            if purpose in item:
                return item[purpose]
            else:
                if purpose.lower() == 'definition':
                    return "Пока нет значения / Working on the definition"
                elif purpose.lower() == 'synonyms':
                    return "Пока нет синонимов / Working on the synonyms"
                elif purpose.lower() == 'antonyms':
                    return "Пока нет антнонимов / Working on the antonyms"
    if close_matches:
        output = str(input("Did you mean %s instead. (Input Yes or No) " % close_matches[0]))
        if output.lower() == 'yes':
            for item in data['wordlist']:
                if item['name'] == close_matches[0]:
                    if purpose in item:
                        return item[purpose]
                    else:
                        if purpose.lower() == 'definition':
                            return "Пока нет значения / Working on the definition"
                        elif purpose.lower() == 'synonyms':
                            return "Пока нет синонимов / Working on the synonyms"
                        elif purpose.lower() == 'antonyms':
                            return "Пока нет антнонимов / Working on the antonyms"
        elif output.lower() == 'no':
            return "The Word doesn't exist please double check it/ Слово не существует"
        else:
            return "We didn't understand your input"
    return "Слово не нашлось/Word not found"


word = input("Введите слово/Enter russian word: ")
purpose = str(input("What would you like to know? (Definition, Synonyms, or Antonyms"))
flag = True
while flag:
    if purpose.lower() == 'definition' or purpose.lower() == 'synonyms' or purpose.lower() == 'antonyms':
        print(multi_purpose(word, purpose))
        indicator = str(input("Would you like to learn one more word? (Yes/No)"))
        if indicator.lower() == 'yes':
            word = input("Введите слово/Enter russian word: ")
            purpose = str(input("What would you like to know? (Definition, Synonyms, or Antonyms"))
            continue
        else:
            flag = False
    else:
        print("I don't understand what would you like to learn.")
        break