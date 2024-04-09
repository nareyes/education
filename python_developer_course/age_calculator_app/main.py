import sys
from datetime import date, datetime
from dateutil.relativedelta import relativedelta
from PyQt6.QtWidgets import QApplication, QVBoxLayout, QGridLayout, QLabel, QWidget, QLineEdit, QPushButton


class AgeCalculator(QWidget):
    
    def __init__(self):
        super().__init__()

        grid = QGridLayout()

        # create widgets
        self.setWindowTitle('Age Calculator')

        name_label = QLabel('Name')
        self.name_input = QLineEdit()

        birth_date_label = QLabel('Date of Birth (YYYY-MM-DD)')
        self.birth_date_input = QLineEdit()

        calculate_button = QPushButton('Calculate')
        calculate_button.clicked.connect(self.calculate_age)
        self.age_output_label = QLabel('')

        # add widgets to grid
        grid.addWidget(name_label, 0, 0)
        grid.addWidget(self.name_input, 0, 1)
        grid.addWidget(birth_date_label, 1, 0)
        grid.addWidget(self.birth_date_input, 1, 1)
        grid.addWidget(calculate_button, 2, 0, 1, 2)
        grid.addWidget(self.age_output_label, 3, 0, 1, 2)

        # set layout
        self.setLayout(grid)


    def calculate_age(self):
        current_date = date.today()
        birth_date = self.birth_date_input.text()
        birth_date = datetime.strptime(birth_date, '%Y-%m-%d').date()
        age = relativedelta(current_date, birth_date).years

        self.age_output_label.setText(f'{self.name_input.text()} is {age} Years Old.')


# application logic
app = QApplication(sys.argv)
age_calculator = AgeCalculator()
age_calculator.show()
sys.exit(app.exec())