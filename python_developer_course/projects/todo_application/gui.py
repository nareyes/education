# TO DO LIST GUI APPLICATION
# PYTHON VERSION 3.11.5

import module
import PySimpleGUI as gui

todo_app = module.TodoList()

label = gui.Text('Add Todo:')
input_box = gui.InputText()
add_button = gui.Button('Add')

window = gui.Window('Todo App', layout = [[label], [input_box, add_button]])
window.read()
window.close()


# APPLICATION LOGIC
# - The program runs in a continuous loop, prompting the user for an action (add, show, edit, complete, clear, or exit).
# - Depending on the action, it calls the corresponding method of the TodoList class.
# - If the action is 'edit' or 'complete', it handles IndexError exceptions if the user provides an invalid todo number.
# - If the action is 'exit', the loop breaks, terminating the program.
# - If the user inputs an invalid action, it prints "Invalid Entry".
# - After the loop terminates, it prints "Program Terminated".

