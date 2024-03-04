# TO DO LIST CLI APPLICATION
# PYTHON VERSION 3.11.5

class TodoList:
    def __init__(self):
        """
        Initializes a TodoList object.
        Sets up default user input prompts, file path for storing todos, and initializes an empty list to store todos.
        """
        self.user_input_action = "Type Add, Show, Edit, Complete, Clear or Exit: "
        self.user_input_todo = "Enter a Todo: "
        self.user_input_position = "Enter a Valid Todo Number to Edit: "
        self.user_input_new = "Enter a New Item: "
        self.user_input_complete = "Enter a Valid Todo Number to Complete: "
        self.filepath = "todos.txt"
        self.todos = []

    def read_todos(self):
        """
        Reads the todo items from the "todos.txt" file.
        Returns a list containing the todo items.
        """
        with open(self.filepath, "r") as file_local:
            todos_local = file_local.readlines()
        return todos_local

    def write_todos(self, todos):
        """
        Reads the todo items from the "todos.txt" file.
        Writes the updated list back to the "todos.txt" file.
        """
        with open(self.filepath, "w") as file:
            file.writelines(todos)

    def add_todos(self):
        """
        Adds a new todo item to the list.
        Prompts the user to enter a new todo item.
        Writes the updated list back to the "todos.txt" file.
        Prints a message confirming the addition.
        """
        todo = input(self.user_input_todo).strip().title() + "\n"
        todos = self.read_todos()
        todos.append(todo)

        with open(self.filepath, "w") as file:
            file.writelines(todos)

        message = f"Added: {todo}"
        print(message)

    def show_todos(self):
        """
        Displays the current list of todo items.
        If there are no todos, prints "No Pending Todos".
        Otherwise, prints each todo item along with its index.
        """
        todos = self.read_todos()
        if todos == []:
            print("No Pending Todos\n")
        else:
            for index, item in enumerate(todos):
                item = item.strip("\n")
                output = f"{index + 1}: {item}"
                print(output)
        print("\n")

    def edit_todos(self):
        """
        Allows the user to edit an existing todo item.
        Prompts the user to enter the position of the todo item they want to edit.
        Allows the user to enter a new todo item to replace the old one.
        Writes the updated todos back to the "todos.txt" file.
        Prints a message confirming the edit.
        """
        todos = self.read_todos()
        position = int(input(self.user_input_position).strip())
        old_todo = todos[position - 1]

        if position >= 1 and position <= len(todos):
            new_todo = input(self.user_input_new).strip().title()
            todos[position - 1] = new_todo + "\n"
        else:
            while position < 1 or position > len(todos):
                position = int(input(self.user_input_position).strip())

                if position >= 1 and position <= len(todos):
                    new_todo = input(self.user_input_new).strip().title()
                    todos[position - 1] = new_todo + "\n"

        with open(self.filepath, "w") as file:
            file.writelines(todos)

        message = f"Replaced: {old_todo} With: {new_todo}\n"
        print(message)

    def complete_todos(self):
        """
        Marks a todo item as completed.
        Prompts the user to enter the position of the todo item they want to mark as completed.
        Removes the completed todo item from the list.
        Writes the updated todos back to the "todos.txt" file.
        Prints a message confirming the completion.
        """
        todos = self.read_todos()
        position = int(input(self.user_input_complete).strip())
        completed_todo = todos[position - 1]

        if position >= 1 and position <= len(todos):
            todos.pop(position - 1)
        else:
            while position < 1 or position > len(todos):
                position = int(input(self.user_input_complete).strip())

                if position >= 1 and position <= len(todos):
                    todos.pop(position - 1)

        with open(self.filepath, "w") as file:
            file.writelines(todos)

        message = f"Completed Todo: {completed_todo}"
        print(message)

    def clear_todos(self):
        """
        Clears all todos from the list.
        Opens the "todos.txt" file in write mode and immediately closes it.
        """
        open(self.filepath, "w").close()

        message = "All Todos Cleared\n"
        print(message)