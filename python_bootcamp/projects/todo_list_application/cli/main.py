# todo list cli application
# python version 3.11.1

# variables
user_input_action = "Type Add, Show, Edit, Complete or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
# todos = []


# functions
def add_todos():
    todo = input(user_input_todo).strip().title() + '\n'

    file = open('todos.txt', 'r')
    todos = file.readlines()
    file.close()

    todos.append(todo) 

    file = open('todos.txt', 'w')
    file.writelines(todos)
    file.close()

def show_todos():
    file = open('todos.txt', 'r')
    todos = file.readlines()
    file.close()
    
    for index, item in enumerate(todos):
        output = f"{index + 1}: {item}"
        print(output)

def edit_todos():
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
            add_todos()

        case 'show':
            show_todos()

        case 'edit':
            show_todos()
            edit_todos()

        case 'complete':
            show_todos()
            complete_todo()

        case 'exit':
            break

        case _:
            print("Unknown Command!")
            

print('Bye!')