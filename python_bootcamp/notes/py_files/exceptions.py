import sys
from math import log

DIGIT_MAP = {
    'zero': '0',
    'one': '1',
    'two': '2',
    'three': '3',
    'four': '4',
    'five': '5',
    'six': '6',
    'seven': '7',
    'eight': '8',
    'nine': '9'
}

def convert(n):
    '''
    Convert a string to an integer.
    '''
    try:
        number = ''

        for token in n:
            number += DIGIT_MAP[token]
        return int(number)

    except (KeyError, TypeError) as e:
        print(f'Conversion Error: {e!r}', file = sys.stderr)

        raise


def string_log(n):
    '''
    Returns the log() of the converted string.
    '''
    num = convert(n)
    return log(num)