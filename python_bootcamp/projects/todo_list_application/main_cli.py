# todo list cli application
todos = []

while True:
    user_action = input("Type Add, Show, or Exit: ").lower()

    match user_action:

        case 'add':
            todo = input("Enter a Todo: ").title()
            todos.append(todo)

        case 'show':
            for item in todos:
                print(item)
                
        case 'exit':
            break

print('Bye!')