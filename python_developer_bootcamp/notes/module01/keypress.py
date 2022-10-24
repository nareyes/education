'''
keypress - A module for detecting a single keypress.
'''

import tty


try:
    import msvcrt

    def getkey():
        '''Wait for a keypress and return a single character string.'''
        return msvcrt.getch()

except ImportError:
    import sys
    import tty
    import termios

    def getkey():
        '''Wait for a keypress and return a single character string.'''
        fd = sys.sstdin.fileno()
        original_attributes = termios.tcgetattr(fd)

        try:
            tty.setraw(sys.stdin.fileno())
            ch = sys.stdin.read(1)
        
        finally:
            termios.tcsetattr(fd, termios.TCSADRAIN, original_attributes)
        
        return ch

# If either of the Unix-specific tty or termios are not found, we allow the ImportError to propogate from here.