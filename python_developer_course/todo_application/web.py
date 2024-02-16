import module
import streamlit as st

# initialize TodoList object from module
# read exisiting todos from TodoList opbject
todo_app = module.TodoList()
todos = todo_app.read_todos()

# add todos using streamlit session state
def add_todos_st():
    """
    Adds a new todo item to the list.
    Retrieves the new todo item from the session state and appends it to the existing list of todos.
    Writes the updated list back to the "todos.txt" file.
    """
    new_todo = st.session_state['new_todo'].title() + '\n'
    todos.append(new_todo)
    todo_app.write_todos(todos)

# setup streamlit app interface
st.title('Todo App')
st.subheader('Daily Task Manager')

# displaying existing todos and checkboxes to mark them as completed
for index, todo in enumerate(todos):
    completed_todo = st.checkbox(todo, key = todo)

    if completed_todo:
        todos.pop(index)
        todo_app.write_todos(todos)

        del st.session_state[todo]
        st.rerun()

# text input field to add new todos
st.text_input( 
    label = 'user input',
    label_visibility = 'hidden',
    placeholder = 'add new todo...'.title(),
    on_change = add_todos_st,
    key = 'new_todo'
)