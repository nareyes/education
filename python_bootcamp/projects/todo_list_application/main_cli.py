# todo list cli application
user_prompt = "Enter a Todo: "
todos = []

while True:
    todo = input(user_prompt).title()
    todos.append(todo)
    print(todos)