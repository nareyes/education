"""
A PyQt6-based application for managing student records.

This application provides functionalities such as adding, searching, editing, and deleting student records.
It offers a user-friendly interface with features like table display of student information, toolbar shortcuts,
and status bar feedback.

Dependencies:
    - Python 3.x
    - PyQt6
    - SQL Lite 3

"""

import sys
import sqlite3 as sql
from PyQt6.QtCore import Qt 
from PyQt6.QtGui import QAction, QIcon
from PyQt6.QtWidgets import QApplication, QDialog, QGridLayout, QLabel, QLineEdit, QMainWindow, \
    QMessageBox, QPushButton, QMessageBox, QStatusBar, QTableWidget, QTableWidgetItem, QToolBar, QVBoxLayout


class DatabaseConnection:
    """
    Handles the database connection.

    Attributes:
        database (str): The name of the database file.
    """

    def __init__(self, database='database.db'):
        self.database = database
    
    def connect(self):
        """
        Establishes a connection to the database.

        Returns:
            sqlite3.Connection: A connection object to the database.
        """

        connection = sql.connect(self.database)
        return connection


class MainWindow(QMainWindow):
    """
    Main window of the application.

    Attributes:
        table (QTableWidget): Table widget to display student records.
        statusbar (QStatusBar): Status bar to show messages and actions.
    """

    def __init__(self):
        """
        Initializes the MainWindow object.
        """

        super().__init__()

        # set title and layout
        self.setWindowTitle('Student Management System')
        self.setFixedWidth(600)
        self.setFixedHeight(500)

        # add menu items
        file_menu = self.menuBar().addMenu('&File')
        help_menu = self.menuBar().addMenu('&Help')
        edit_menu = self.menuBar().addMenu('&Edit')

        # add menu actions
        add_student_action = QAction(QIcon('icons/add.png'), 'Add Student', self)
        add_student_action.triggered.connect(self.insert_data)
        file_menu.addAction(add_student_action)

        about_action = QAction('About', self)
        help_menu.addAction(about_action)
        about_action.setMenuRole(QAction.MenuRole.NoRole)
        about_action.triggered.connect(self.about)

        search_action = QAction(QIcon('icons/search.png'), 'Search', self)
        edit_menu.addAction(search_action)
        search_action.triggered.connect(self.search)

        # add table structure
        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.verticalHeader().setVisible(False)
        self.table.setHorizontalHeaderLabels(('Id', 'Name', 'Course', 'Mobile'))
        self.setCentralWidget(self.table)

        # create toolbar and add elements
        toolbar = QToolBar()
        self.addToolBar(toolbar)

        toolbar.addAction(add_student_action)
        toolbar.addAction(search_action)

        # create statusbar and add elements
        self.statusbar = QStatusBar()
        self.setStatusBar(self.statusbar)

        self.table.cellClicked.connect(self.cell_selected)


    def load_data(self):
        """
        Loads data from the database and populates the table.
        """

        # create connection and load data
        connection = DatabaseConnection().connect()
        result = connection.execute('select * from students')

        # write data to table
        self.table.setRowCount(0)

        for row_number, row_data in enumerate(result):
            self.table.insertRow(row_number)
            for column_number, data in enumerate(row_data):
                self.table.setItem(row_number, column_number, QTableWidgetItem(str(data)))
        
        connection.close()
    

    def cell_selected(self):
        """
        Displays edit and delete buttons in the status bar upon cell selection.
        """

        # add edit button
        edit_button = QPushButton('Edit Record')
        edit_button.clicked.connect(self.edit_data)

        # add delete button
        delete_button = QPushButton('Delete Record')
        delete_button.clicked.connect(self.delete_data)

        # set buttons visible upon cell selection
        children = self.findChildren(QPushButton)
        if children:
            for child in children:
                self.statusbar.removeWidget(child)

        self.statusbar.addWidget(edit_button)
        self.statusbar.addWidget(delete_button)


    def about(self):
        """
        Displays information about the application.
        """

        dialog = AboutDialog()
        dialog.exec()


    def search(self):
        """
        Opens the search dialog for searching student records.
        """

        dialog = SearchDialog()
        dialog.exec()


    def insert_data(self):
        """
        Opens the insert dialog for adding new student data.
        """

        dialog = InsertDialog()
        dialog.exec()


    def edit_data(self):
        """
        Opens the edit dialog for editing existing student data.
        """

        dialog = EditDialog()
        dialog.exec()
    

    def delete_data(self):
        """
        Opens the delete dialog for deleting existing student data.
        """

        dialog = DeleteDialog()
        dialog.exec()


class AboutDialog(QMessageBox):
    """
    Dialog box to display information about the application.
    """

    def __init__(self):
        """
        Initializes the AboutDialog object.
        """

        super().__init__()

        # set title
        self.setWindowTitle('About')

        # set and display content
        content = '''
        The "Student Management App" is a PyQt6-based application designed for managing student records. It offers a simple yet efficient solution for organizing and managing student data effectively.

        Users can perform various operations such as adding new student data, searching for specific students by name, and editing or deleting existing records.

        The application provides a user-friendly interface with features like table display of student information, toolbar shortcuts for quick access to functions, and status bar feedback for actions like editing or deleting records.
        '''
        self.setText(content)


class SearchDialog(QDialog):
    """
    Dialog box for searching student records.
    """

    def __init__(self):
        """
        Initializes the SearchDialog object.
        """

        super().__init__()

        # set title and layout
        self.setWindowTitle('Search Student')
        self.setFixedWidth(400)
        self.setFixedHeight(300)
        layout = QVBoxLayout()

        # add student search input
        self.student_name = QLineEdit()
        self.student_name.setPlaceholderText('Enter Student Name')
        layout.addWidget(self.student_name)

        # add create button
        button = QPushButton('Search')
        button.clicked.connect(self.search)
        layout.addWidget(button)

        # set layout
        self.setLayout(layout)

    
    def search(self):
        """
        Searches for the student record based on the provided name.
        """

        name = self.student_name.text()

        # connect to db and search data
        connection = DatabaseConnection().connect()
        cursor = connection.cursor()
        result = cursor.execute('select * from students where name = ?', (name,))
        rows = list(result)
        
        items = student_mgmt.table.findItems(name, Qt.MatchFlag.MatchFixedString)

        for item in items:
            student_mgmt.table.item(item.row(), 1).setSelected(True)
        
        cursor.close()
        connection.close()


class InsertDialog(QDialog):
    """
    Dialog box for inserting new student data.
    """

    def __init__(self):
        """
        Initializes the InsertDialog object.
        """

        super().__init__()
    
        # set title and layout
        self.setWindowTitle('Insert New Student Data')
        self.setFixedWidth(400)
        self.setFixedHeight(300)
        layout = QVBoxLayout()

        # add student input
        self.student_name = QLineEdit()
        self.student_name.setPlaceholderText('Enter Student Name')
        layout.addWidget(self.student_name)

        # add course input
        self.course_name = QLineEdit()
        self.course_name.setPlaceholderText('Enter Course Name')
        layout.addWidget(self.course_name)

        # add phone input
        self.phone_number = QLineEdit()
        self.phone_number.setPlaceholderText('Enter Student Phone Number')
        layout.addWidget(self.phone_number)

        # add submit button
        button = QPushButton('Submit')
        button.clicked.connect(self.add_student)
        layout.addWidget(button)

        # set layout
        self.setLayout(layout)
    

    def add_student(self):
        """
        Adds a new student record to the database.
        """

        name = self.student_name.text()
        course = self.course_name.text()
        phone = self.phone_number.text()

        # connect to db and write data
        connection = DatabaseConnection().connect()
        cursor = connection.cursor()
        cursor.execute(
            'insert into students (name, course, mobile) values (?, ?, ?)',
            (name, course, phone)
        )
        connection.commit()
        cursor.close()
        connection.close()

        # refresh data
        student_mgmt.load_data()

        # close dialog box
        self.close()


class EditDialog(QDialog):
    """
    Dialog box for updating existing student data.
    """

    def __init__(self):
        """
        Initializes the EditDialog object.
        """

        super().__init__()
    
        # set title and layout
        self.setWindowTitle('Update Student Data')
        self.setFixedWidth(400)
        self.setFixedHeight(300)
        layout = QVBoxLayout()

        # get current student data
        index = student_mgmt.table.currentRow()
        self.student_id_selected = student_mgmt.table.item(index, 0).text()
        student_name_selected = student_mgmt.table.item(index, 1).text()
        course_name_selected = student_mgmt.table.item(index, 2).text()
        phone_number_selected = student_mgmt.table.item(index, 3).text()

        # add student input
        self.student_name = QLineEdit(student_name_selected)
        self.student_name.setPlaceholderText('Enter Student Name')
        layout.addWidget(self.student_name)

        # add course input
        self.course_name = QLineEdit(course_name_selected)
        self.course_name.setPlaceholderText('Enter Course Name')
        layout.addWidget(self.course_name)

        # add phone input
        self.phone_number = QLineEdit(phone_number_selected)
        self.phone_number.setPlaceholderText('Enter Student Phone Number')
        layout.addWidget(self.phone_number)

        # add submit button
        button = QPushButton('Submit')
        button.clicked.connect(self.update_student)
        layout.addWidget(button)

        # set layout
        self.setLayout(layout)
    

    def update_student(self):
        """
        Updates the selected student record in the database.
        """

        name = self.student_name.text()
        course = self.course_name.text()
        phone = self.phone_number.text()
        id = self.student_id_selected

        # connect to db and update data
        connection = DatabaseConnection().connect()
        cursor = connection.cursor()
        cursor.execute(
            'update students set name = ?, course = ?, mobile = ? where id = ?',
            (name, course, phone, id)
        )
        connection.commit()
        cursor.close()
        connection.close()

        # refresh data
        student_mgmt.load_data()

        # close dialog box
        self.close()


class DeleteDialog(QDialog):
    """
    Dialog box for deleting student data.
    """

    def __init__(self):
        """
        Initializes the DeleteDialog object.
        """

        super().__init__()
    
        # set title and layout
        self.setWindowTitle('Delete Student Data')
        # self.setFixedWidth(400)
        # self.setFixedHeight(300)
        layout = QGridLayout()

        # add confirmation message
        confirmation = QLabel('Delete Student Record?')
        confirm_yes = QPushButton('Yes')
        confirm_no = QPushButton('No')
        layout.addWidget(confirmation, 0, 0, 1, 2)
        layout.addWidget(confirm_yes, 1, 0)
        layout.addWidget(confirm_no, 1, 1)

        # get current student data
        index = student_mgmt.table.currentRow()
        self.student_id_selected = student_mgmt.table.item(index, 0).text()

        # delete student
        confirm_yes.clicked.connect(self.delete_student)

        # set layout
        self.setLayout(layout)


    def delete_student(self):
        """
        Deletes the selected student record from the database.
        """
        
        id = self.student_id_selected

        # connect to db and update data
        connection = DatabaseConnection().connect()
        cursor = connection.cursor()
        cursor.execute(
            'delete from students where id = ?',
            (id, )
        )
        connection.commit()
        cursor.close()
        connection.close()

        # refresh data
        student_mgmt.load_data()

        # close dialog box
        self.close()
        confirmation_widget = QMessageBox()
        confirmation_widget.setWindowTitle('Confirmation')
        confirmation_widget.setText('Record Deleted')
        confirmation_widget.exec()
        

# application logic
app = QApplication(sys.argv)
student_mgmt = MainWindow()
student_mgmt.show()
student_mgmt.load_data()

sys.exit(app.exec())