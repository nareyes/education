# variables
user_input_action = "Type Add, Show, Edit, Complete or Exit: "
user_input_todo = "Enter a Todo: "
user_input_position = "Enter a Valid Todo Number to Edit: "
user_input_new = "Enter New Item: "
user_input_complete = "Enter a Valid Todo Number to Complete: "
todos = []


class TodoList:
    def __init__(self):
        self.todos = []
    
    def add_todo(self):
        todo = input(user_input_todo).strip().title()
        todos.append(todo)

    def display_todos(self):
        for index, item in enumerate(todos):
            output = f"{index + 1}: {item}"
            print(output)

    def replace_todo(self):
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

    def complete_todo(self):
        position = int(input(user_input_complete).strip())
                
        if position >= 1 and position <= len(todos):
            todos.pop(position - 1)
        else:
            while position < 1 or position > len(todos):
                position = int(input(user_input_complete).strip())

                if position >= 1 and position <= len(todos):
                    todos.pop(position - 1)