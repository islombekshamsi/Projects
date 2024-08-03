try:
    import pyperclip
except ImportError:
    pass

БУКВЫ = "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"

def main():
    print('''Виженерский шифр - это полиалфавитный шифр подстановки, 
    который был достаточно мощным, чтобы оставаться нераскрытым веками.''')
    while True:
        print("Вы хотите (ш)ифровать или (р)асшифровать")
        response = input("> ").lower()
        if response.startswith("ш"): # checks whether it starts with certain character
            myMode = 'шифровать'
            break
        elif response.startswith("р"):
            myMode = 'расшифровать'
            break
        print("Пожалуйста введите ш или р ")

    while True:
        print("Ключ для использования: ")
        print("Можно букву или слово")
        response = input("> ").upper()
        if response.isalpha(): # checks whether it's in the alphabet (a-z)
            myKey = response
            break

    print("Введите сообщение {}".format(myMode))
    myMessage = input("> ")

    if myMode == "шифровать":
        translated = encryptMessage(myMessage, myKey)
    elif myMode == 'расшифровать':
        translated = decryptMessage(myMessage, myKey)

    print('Сообщение: ')
    print(translated)

    try:
        pyperclip.copy(translated)
        print("Текст скопирован.")
    except:
        pass


def encryptMessage(message, key):
    return translateMessage(message, key, 'шифровать')

def decryptMessage(message, key):
    return translateMessage(message, key, 'расшифровать')


def translateMessage(message, key, mode):
    translated = []

    keyIndex = 0
    key = key.upper()

    for symbol in message:
        num = БУКВЫ.find(symbol.upper())
        if num != -1:
            if mode == 'шифровать':
                num += БУКВЫ.find(key[keyIndex])
            elif mode == 'расшифровать':
                num -= БУКВЫ.find(key[keyIndex])

            num %= len(БУКВЫ)

            if symbol.isupper(): # if all characters are capital
                translated.append(БУКВЫ[num])
            elif symbol.islower():
                translated.append((БУКВЫ[num]).lower())

            keyIndex += 1
            if keyIndex == len(key):
                keyIndex = 0
        else:
            translated.append(symbol)
    return ''.join(translated)

if __name__ == '__main__':
    main()
