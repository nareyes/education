# todo list cli application
# python version 3.11.1

# variables
user_input_action = "Type Add, Show, Edit, or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
todos = []


# functions
def replace_todo():
    new_todo = input("Enter New Item: ").strip().title()
    todos[position - 1] = new_todo


# application logic
while True:
    user_action = input(user_input_action).strip().lower()

    match user_action:

        case 'add':
            todo = input(user_input_todo).strip().title()
            todos.append(todo)

        case 'show':
            for item in todos:
                print(item)

        case 'edit':
            counter = 1

            for item in todos:
                display_todos = (counter, item)
                counter += 1

                print(display_todos)

            position = int(input(user_input_position).strip())
            
            if position >= 1 and position <= len(todos):
                replace_todo()
            else:
                while position < 1 or position > len(todos):
                    position = int(input(user_input_position).strip())
                    if position >= 1 and position <= len(todos):
                        replace_todo()

        case 'exit':
            break

        case _:
            print("Unknown Command!")
            

print('Bye!')