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
def add_todos():
    todo = input(user_input_todo).strip().title() + '\n'

    with open('todos.txt', 'r') as file:
        todos = file.readlines()

    todos.append(todo) 

    with open('todos.txt', 'w') as file:
        file.writelines(todos)

def show_todos():
    with open('todos.txt', 'r') as file:
        todos = file.readlines()
    
    for index, item in enumerate(todos):
        item = item.strip('\n')
        output = f"{index + 1}: {item}"
        print(output)

def edit_todos():
    position = int(input(user_input_position))
    index = position - 1
    todo_replace = todos[index].strip('\n')

    with open('todos.txt', 'r') as file:
        todos = file.readlines()
    
    new_todo = input(user_input_new).strip().title()
    todos[index] = new_todo + '\n'

    with open('todos.txt', 'w') as file:
        file.writelines(todos)
    
    message = f"Todo {todo_replace} Replaced with {new_todo}."
    print(message)

    # if position >= 1 and position <= len(todos):
    #     new_todo = input(user_input_new).strip().title()
    #     todos[position - 1] = new_todo
    # else:
    #     while position < 1 or position > len(todos):
    #         position = int(input(user_input_position))

    #         if position >= 1 and position <= len(todos):
    #             new_todo = input(user_input_new).strip().title()
    #             todos[position - 1] = new_todo


def complete_todo():
    position = int(input(user_input_complete).strip())
    index = position - 1
    todo_remove = todos[index].strip('\n')

    with open('todos.txt', 'r') as file:
        todos = file.readlines()
    
    todos.pop(index)

    with open('todos.txt', 'w') as file:
        file.writelines(todos)
    
    message = f"Todo {todo_remove} Removed."
    print(message)

    # if position >= 1 and position <= len(todos):
    #     todos.pop(position - 1)
    # else:
    #     while position < 1 or position > len(todos):
    #         position = int(input(user_input_complete).strip())

    #         if position >= 1 and position <= len(todos):
    #             todos.pop(position - 1)


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