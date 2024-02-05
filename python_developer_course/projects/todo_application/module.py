# variables
user_input_action = "Type Add, Show, Edit, Complete, Clear or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter a New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
todos = []

class TodoList:
    def __init__(self):
        self.todos = []
    
    def read_todos(self):
        with open("data/todos.txt", "r") as file_local:
            todos_local = file_local.readlines()

        return todos_local

    def add_todos(self):
        todo = input(user_input_todo).strip().title() + "\n"
        todos = read_todos()
        todos.append(todo)

        with open("data/todos.txt", "w") as file:
            file.writelines(todos)

        message = f"Added: {todo}"
        print(message)

    def show_todos(self):
        todos = read_todos()
        if todos == []:
            print('No Pending Todos')
        else:
            for index, item in enumerate(todos):
                item = item.strip("\n")
                output = f"{index + 1}: {item}"
                print(output)

    def edit_todos(self):
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

    def complete_todos(self):
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

    def clear_todos(self):
        open("data/todos.txt", "w").close()

        message = "All Todos Cleared\n"
        print(message)