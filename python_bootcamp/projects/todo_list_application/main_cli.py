# todo list cli application
user_input = "Enter a Todo: "
todos = []

while True:
    user_action = input("Type Add, Show, or Exit: ")
    user_action = user_action.strip().lower()

    match user_action:

        case 'add':
            todo = input(user_input).title()
            todos.append(todo)

        case 'show':
            for item in todos:
                print(item)

        case 'exit':
            break

        case _:
            print("Unknown Command")
            

print('Bye!')