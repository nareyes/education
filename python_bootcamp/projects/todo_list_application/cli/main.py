# todo list cli application
# python version 3.11.1

# variables
user_input_action = "Type Add, Show, Edit, Complete or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
todos = []


# functions
def add_todo():
    todo = input(user_input_todo).strip().title()
    todos.append(todo)

def display_todos():
    for index, item in enumerate(todos):
        output = f"{index + 1}: {item}"
        print(output)

def replace_todo():
    position = int(input(user_input_position).strip())
            
    if position >= 1 and position <= len(todos):
        new_todo = input(user_input_new).strip().title()
        todos[position - 1] = new_todo
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_position).strip())

            if position >= 1 and position <= len(todos):
                new_todo = input(user_input_new).strip().title()
                todos[position - 1] = new_todo

def complete_todo():
    position = int(input(user_input_complete).strip())
            
    if position >= 1 and position <= len(todos):
        todos.pop(position - 1)
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_complete).strip())

            if position >= 1 and position <= len(todos):
                todos.pop(position - 1)


# application logic
while True:
    user_action = input(user_input_action).strip().lower()

    match user_action:

        case 'add':
            add_todo()

        case 'show':
            display_todos()

        case 'edit':
            display_todos()
            replace_todo()

        case 'complete':
            display_todos()
            complete_todo()

        case 'exit':
            break

        case _:
            print("Unknown Command!")
            

print('Bye!')