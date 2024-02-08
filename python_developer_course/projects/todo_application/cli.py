# TO DO LIST CLI APPLICATION
# PYTHON VERSION 3.11.5

import module
todo_app = module.TodoList()

# APPLICATION LOGIC
# - The program runs in a continuous loop, prompting the user for an action (add, show, edit, complete, clear, or exit).
# - Depending on the action, it calls the corresponding method of the TodoList class.
# - If the action is 'edit' or 'complete', it handles IndexError exceptions if the user provides an invalid todo number.
# - If the action is 'exit', the loop breaks, terminating the program.
# - If the user inputs an invalid action, it prints "Invalid Entry".
# - After the loop terminates, it prints "Program Terminated".
while True:
    user_action = input(todo_app.user_input_action).strip().lower()

    if user_action == "add":
        todo_app.add_todos()
    elif user_action == "show":
        todo_app.show_todos()
    elif user_action == "edit":
        try:
            todo_app.show_todos()
            todo_app.edit_todos()
        except IndexError:
            print("Invalid Entry\n")
            continue
    elif user_action == "complete":
        try:
            todo_app.show_todos()
            todo_app.complete_todos()
        except IndexError:
            print("Invalid Entry\n")
            continue
    elif user_action == "clear":
        todo_app.clear_todos()
    elif user_action == "exit":
        break
    else:
        print("Invalid Entry\n")

print("Program Terminated\n")