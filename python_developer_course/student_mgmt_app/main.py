import sys
import sqlite3 as sql
from datetime import date, datetime
from dateutil.relativedelta import relativedelta
from PyQt6.QtCore import Qt 
from PyQt6.QtGui import QAction
from PyQt6.QtWidgets import QApplication, QDialog, QLineEdit, QMainWindow, QPushButton, QTableWidget, QTableWidgetItem, QVBoxLayout


class MainWindow(QMainWindow):
    
    def __init__(self):

        super().__init__()

        # set title and layout
        self.setWindowTitle('Student Management System')
        self.setFixedWidth(600)
        self.setFixedHeight(300)

        # add menu items
        file_menu = self.menuBar().addMenu('&File')
        help_menu = self.menuBar().addMenu('&Help')
        edit_menu = self.menuBar().addMenu('&Edit')

        # add menu actions
        add_student_action = QAction('Add Student', self)
        add_student_action.triggered.connect(self.insert_data)
        file_menu.addAction(add_student_action)

        about_action = QAction('About', self)
        help_menu.addAction(about_action)
        about_action.setMenuRole(QAction.MenuRole.NoRole)

        search_action = QAction('Search', self)
        edit_menu.addAction(search_action)
        search_action.triggered.connect(self.search)

        # add table structure
        self.table = QTableWidget()
        self.table.setColumnCount(4)
        self.table.verticalHeader().setVisible(False)
        self.table.setHorizontalHeaderLabels(('Id', 'Name', 'Course', 'Mobile'))
        self.setCentralWidget(self.table)

    
    def load_data(self):

        # create connection and load data
        connection = sql.connect('database.db')
        result = connection.execute('select * from students')

        # write data to table
        self.table.setRowCount(0)

        for row_number, row_data in enumerate(result):
            self.table.insertRow(row_number)
            for column_number, data in enumerate(row_data):
                self.table.setItem(row_number, column_number, QTableWidgetItem(str(data)))
        
        connection.close()
    

    def insert_data(self):
        dialog = InsertDialog()
        dialog.exec()

    
    def search(self):
        dialog = SearchDialog()
        dialog.exec()
    

class InsertDialog(QDialog):

    def __init__(self):
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
        name = self.student_name.text()
        course = self.course_name.text()
        phone = self.phone_number.text()

        # connect to db and write data
        connection = sql.connect('database.db')
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


class SearchDialog(QDialog):

    def __init__(self):
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
        name = self.student_name.text()

        # connect to db and search data
        connection = sql.connect('database.db')
        cursor = connection.cursor()
        result = cursor.execute('select * from students where name = ?', (name,))
        rows = list(result)
        
        items = student_mgmt.table.findItems(name, Qt.MatchFlag.MatchFixedString)

        for item in items:
            student_mgmt.table.item(item.row(), 1).setSelected(True)
        
        cursor.close()
        connection.close()


# application logic
app = QApplication(sys.argv)
student_mgmt = MainWindow()
student_mgmt.show()
student_mgmt.load_data()

sys.exit(app.exec())