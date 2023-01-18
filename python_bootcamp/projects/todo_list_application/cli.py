# todo list cli application
# python version 3.11.1

# variables
user_input_action = "Type Add, Show, Edit, Complete, Clear or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
todos = []


# functions
def add_todos():
    todo = input(user_input_todo).strip().title() + '\n'

    with open('todos.txt', 'r') as file:
        todos = file.readlines()

    todos.append(todo) 

    with open('todos.txt', 'w') as file:
        file.writelines(todos)
    
    message = f"Added: {todo}"
    print(message)


def show_todos():
    with open('todos.txt', 'r') as file:
        todos = file.readlines()
    
    for index, item in enumerate(todos):
        item = item.strip('\n')
        output = f"{index + 1}: {item}"
        print(output)


def edit_todos():
    with open('todos.txt', 'r') as file:
        todos = file.readlines()

    position = int(input(user_input_position))
    old_todo = todos[position - 1]
            
    if position >= 1 and position <= len(todos):
        new_todo = input(user_input_new).strip().title()
        todos[position - 1] = new_todo + '\n'
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_position).strip())

            if position >= 1 and position <= len(todos):
                new_todo = input(user_input_new).strip().title()
                todos[position - 1] = new_todo + '\n'

    with open('todos.txt', 'w') as file:
        file.writelines(todos)

    message = f"Replaced: {old_todo} With: {new_todo}"
    print(message)


def complete_todos():
    with open('todos.txt', 'r') as file:
        todos = file.readlines()

    position = int(input(user_input_complete).strip())
    completed_todo = todos[position - 1]
            
    if position >= 1 and position <= len(todos):
        todos.pop(position - 1)
    else:
        while position < 1 or position > len(todos):
            position = int(input(user_input_complete).strip())

            if position >= 1 and position <= len(todos):
                todos.pop(position - 1)

    with open('todos.txt', 'w') as file:
        file.writelines(todos)

    message = f"Completed Todo: {completed_todo}"
    print(message)


def clear_todos():
    open('todos.txt', 'w').close()
    
    message = "All Todos Cleared\n"
    print(message)


# application logic
while True:
    user_action = input(user_input_action).strip().lower()

    match user_action:

        case 'add':
            add_todos()

        case 'show':
            show_todos()

        case 'edit':
            show_todos()
            edit_todos()

        case 'complete':
            show_todos()
            complete_todos()
        
        case 'clear':
            clear_todos()

        case 'exit':
            break

        case _:
            print("Unknown Command!")
            

print('Bye!')