# TO DO LIST GUI APPLICATION
# PYTHON VERSION 3.11.5

import os
import module
import PySimpleGUI as gui


# initialize TodoList object from module
todo_app = module.TodoList()

# check if todos.txt exists, if not create it
if not os.path.exists('todos.txt'):
    with open('todos.txt', 'w') as file:
        pass

# set gui theme and define layout
gui.theme('Black')
label = gui.Text('Add Todo:')
input_box = gui.InputText(key = 'todo')
add_button = gui.Button('Add')
edit_button = gui.Button('Edit')
complete_button = gui.Button('Complete')
exit_button = gui.Button('Exit')
todos_list_box = gui.Listbox(values = todo_app.read_todos(), key = 'todos', enable_events = True, size = [45, 10])

# create main gui window
window = gui.Window(
    'Todo App',
    font = ('Helvetica', 20),
    layout = [
        [label],
        [input_box, add_button],
        [todos_list_box, edit_button],
        [complete_button],
        [exit_button]
    ]
)

"""
APPLICATION LOGIC:
- The program operates within a continuous loop until the user exits the application.
- It handles different events such as adding a to-do, editing a to-do, selecting a to-do from the list, and exiting.
- When the 'Add' button is clicked, a new to-do item is added to the list.
- When the 'Edit' button is clicked, the selected to-do item in the list is edited.
- When the 'Complete' button is clicked, the selected to-do item in the list is removed.
- When the 'Exit' button is clicked (or the user closes the window), the loop breaks, terminating the program.
"""

while True:
    event, values = window.read()   
    print(event)
    print(values)

    if event == "Add":
        todos = todo_app.read_todos()
        new_todo = values['todo'].title() + '\n'
        todos.append(new_todo)
        todo_app.write_todos(todos)

        window['todos'].update(values = todos)

    elif event == 'Edit':
        try:
            todo = values['todos'][0]
            new_todo = values['todo'].title() + '\n'
            todos = todo_app.read_todos()
            index = todos.index(todo)
            todos[index] = new_todo
            todo_app.write_todos(todos)

            window['todos'].update(values = todos)

        except IndexError:
            gui.popup(
                'Please Select an Item First.',
                title = 'Error',
                font = ('Helvetica', 20)
            )

    elif event == 'Complete':
        try:
            todo = values['todos'][0]
            todos = todo_app.read_todos()
            todos.remove(todo)
            todo_app.write_todos(todos)

            window['todo'].update(value = '')
            window['todos'].update(values = todos)

        except IndexError:
            gui.popup(
                'Please Select an Item First.',
                title = 'Error',
                font = ('Helvetica', 20)
            )

    elif event == 'Exit':
        break

    elif event == 'todos':
        window['todo'].update(value = values['todos'][0])
        
    elif event == gui.WIN_CLOSED:
        break

window.close()