import sys
import threading
from backend import ChatBot
from PyQt6.QtWidgets import QApplication, QLineEdit, QMainWindow, QPushButton, QTextEdit


class ChatBotWindow(QMainWindow):
    """
    A graphical interface for interacting with the ChatBot.
    """
    
    def __init__(self):
        """
        Initializes the ChatBotWindow instance.
        """

        super().__init__()

        self.chatbot = ChatBot()

        # set window size
        self.setWindowTitle('Chat Bot')
        self.setMinimumSize(700, 500)

        # add chat area widget
        self.chat_area = QTextEdit(self)
        self.chat_area.setReadOnly(True)
        self.chat_area.setGeometry(10, 10, 480, 320)

        # add input field widget
        self.input_field = QLineEdit(self)
        self.input_field.setGeometry(10, 340, 480, 40)
        self.input_field.returnPressed.connect(self.send_message)

        # add send button
        self.send_button = QPushButton('Send', self)
        self.send_button.setGeometry(500, 340, 100, 40)
        self.send_button.clicked.connect(self.send_message)

        # show window
        self.show()

    def send_message(self):
        """
        Sends the user's message to the ChatBot and displays it in the chat area.
        """

        # capture and display user input
        user_input = self.input_field.text().strip()
        self.chat_area.append(f"<p style='color:#333333'>Question: {user_input}</p>")
        self.input_field.clear()

        # start a new thread to get the bot's response asynchronously
        thread = threading.Thread(target=self.get_bot_response, args=(user_input,))
        thread.start()
    
    def get_bot_response(self, user_input):
        """
        Gets the response from the ChatBot and displays it in the chat area.
        
        Args:
            user_input (str): The user's input message.
        """

        # send input to ChatBot
        response = self.chatbot.get_response(user_input)
        self.chat_area.append(f"<p style='color:#333333; background-color: #E9E9E9'>Question: {response}</p>")


app = QApplication(sys.argv)
main_window = ChatBotWindow()
sys.exit(app.exec())