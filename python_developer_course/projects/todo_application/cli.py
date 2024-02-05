# TO DO LIST CLI APPLICATION
# PYTHON VERSION 3.11.5

import module

# VARIABLES & PROMPTS
user_input_action = "Type Add, Show, Edit, Complete, Clear or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter a New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
todos = []


# FUNCTIONS
def read_todos():
    """
    Reads the todo items from the "todos.txt" file.
    Returns a list containing the todo items.
    """
    with open("data/todos.txt", "r") as file_local:
        todos_local = file_local.readlines()

    return todos_local


def add_todos():
    """
    Adds a new todo item to the list.
    Prompts the user to enter a new todo item.
    Writes the updated list back to the "todos.txt" file.
    Prints a message confirming the addition.
    """
    todo = input(user_input_todo).strip().title() + "\n"
    todos = read_todos()
    todos.append(todo)

    with open("data/todos.txt", "w") as file:
        file.writelines(todos)

    message = f"Added: {todo}"
    print(message)


def show_todos():
    """
    Displays the current list of todo items.
    If there are no todos, prints "No Pending Todos".
    Otherwise, prints each todo item along with its index.
    """
    todos = read_todos()
    if todos == []:
        print('No Pending Todos')
    else:
        for index, item in enumerate(todos):
            item = item.strip("\n")
            output = f"{index + 1}: {item}"
            print(output)


def edit_todos():
    """
    Allows the user to edit an existing todo item.
    Prompts the user to enter the position of the todo item they want to edit.
    Allows the user to enter a new todo item to replace the old one.
    Writes the updated todos back to the "todos.txt" file.
    Prints a message confirming the edit.
    """
    todos = read_todos()
    position = int(input(user_input_position).strip())
    old_todo = todos[position - 1]

    if position >= 1 and position <= len(todos):
        new_todo = input(user_input_new).strip().title()
        todos[position - 1] = new_todo + "\n"
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_position).strip())

            if position >= 1 and position <= len(todos):
                new_todo = input(user_input_new).strip().title()
                todos[position - 1] = new_todo + "\n"

    with open("data/todos.txt", "w") as file:
        file.writelines(todos)

    message = f"Replaced: {old_todo} With: {new_todo}"
    print(message)


def complete_todos():
    """
    Marks a todo item as completed.
    Prompts the user to enter the position of the todo item they want to mark as completed.
    Removes the completed todo item from the list.
    Writes the updated todos back to the "todos.txt" file.
    Prints a message confirming the completion.
    """
    todos = read_todos()
    position = int(input(user_input_complete).strip())
    completed_todo = todos[position - 1]

    if position >= 1 and position <= len(todos):
        todos.pop(position - 1)
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_complete).strip())

            if position >= 1 and position <= len(todos):
                todos.pop(position - 1)

    with open("data/todos.txt", "w") as file:
        file.writelines(todos)

    message = f"Completed Todo: {completed_todo}"
    print(message)


def clear_todos():
    """
    Clears all todos from the list.
    Opens the "todos.txt" file in write mode and immediately closes it.

    """
    open("data/todos.txt", "w").close()

    message = "All Todos Cleared\n"
    print(message)


# APPLICATION LOGIC
# - The program runs in a continuous loop, prompting the user for an action (add, show, edit, complete, clear, or exit).
# - Depending on the action, it calls the corresponding function.
# - If the action is 'edit' or 'complete', it handles IndexError exceptions if the user provides an invalid todo number.
# - If the action is 'exit', the loop breaks, terminating the program.
# - If the user inputs an invalid action, it prints "Invalid Entry".
# - After the loop terminates, it prints "Program Terminated".
while True:
    user_action = input(user_input_action).strip().lower()

    match user_action:
        case "add":
            add_todos()
        case "show":
            show_todos()
        case "edit":
            try:
                show_todos()
                edit_todos()
            except IndexError:
                print("Invalid Entry")
                continue
        case "complete":
            try:
                show_todos()
                complete_todos()
            except IndexError:
                print("Invalid Entry")
                continue
        case "clear":
            clear_todos()
        case "exit":
            break
        case _:
            print("Invalid Entry")


print("Program Terminated")