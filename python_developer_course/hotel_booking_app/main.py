import pandas as pd


# import data
df_hotels = pd.read_csv('hotels.csv', dtype={'id': str})
df_cards = pd.read_csv('cards.csv', dtype=str).to_dict(orient='records')
df_cards_sec = pd.read_csv('cards_security.csv', dtype=str)


class Hotel:
    """
    Represents a hotel with its attributes and methods.

    Attributes:
        hotel_id (str): The ID of the hotel.
        hotel_city (str): The city where the hotel is located.
        hotel_name (str): The name of the hotel.
    """

    def __init__(self, hotel_id):
        """
        Initializes a Hotel object with the given hotel ID.

        Args:
            hotel_id (str): The ID of the hotel.
        """

        self.hotel_id = hotel_id
        self.hotel_city = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'city'].squeeze()
        self.hotel_name = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'name'].squeeze()

    def book(self):
        """
        Marks the hotel as unavailable for booking.
        """

        df_hotels.loc[df_hotels['id'] == self.hotel_id, 'available'] = 'no'
        df_hotels.to_csv('hotels.csv', index=False)

    def available(self):
        """
        Checks the availability of the hotel for booking.

        Returns:
            bool: True if the hotel is available, False otherwise.
        """

        availability = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'available'].squeeze()

        return availability == 'yes'


class Reservation:
    """
    Represents a reservation for a hotel.

    Attributes:
        name (str): The name of the visitor making the reservation.
        hotel (Hotel): The hotel object for which the reservation is made.
    """

    def __init__(self, name, hotel):
        """
        Initializes a Reservation object.

        Args:
            name (str): The name of the visitor making the reservation.
            hotel (Hotel): The hotel object for which the reservation is made.
        """

        self.name = name
        self.hotel = hotel

    def generate(self):
        """
        Generates a reservation ticket.

        Returns:
            str: The reservation ticket containing visitor's name, hotel city, hotel name, and confirmation message.
        """

        ticket = f'''
        Name: {self.name}
        City: {self.hotel.hotel_city}
        Hotel: {self.hotel.hotel_name}
        Payment and Booking Confirmed!
        '''

        return ticket


class CreditCard:
    """
    Represents a credit card.

    Attributes:
        number (str): The credit card number.
    """

    def __init__(self, number):
        """
        Initializes a CreditCard object.

        Args:
            number (str): The credit card number.
        """

        self.number = number

    def validate(self, expiration, cvc, holder):
        """
        Validates the credit card details.

        Args:
            expiration (str): The expiration date of the credit card.
            cvc (str): The CVC code of the credit card.
            holder (str): The name of the credit card holder.

        Returns:
            bool: True if the credit card details are valid, False otherwise.
        """

        card_data = {
            'number': self.number,
            'expiration': expiration,
            'cvc': cvc,
            'holder': holder
        }

        return card_data in df_cards


class AuthenticateCreditCard(CreditCard):
    """
    Represents an authenticated credit card.

    Inherits from CreditCard class.

    Attributes:
        number (str): The credit card number.
    """

    def authenticate(self, password_input):
        """
        Authenticates the credit card using a password.

        Args:
            password_input (str): The password for authentication.

        Returns:
            bool: True if the authentication is successful, False otherwise.
        """

        password = df_cards_sec.loc[df_cards_sec['number'] == self.number, 'password'].squeeze()
        
        return password == password_input


# print hotel availability
print('\nList of Hotels:\n')
print(df_hotels)


# user input
hotel_id_input = input('\nEnter Hotel ID: ')
user_name_input = input('Enter Visitor Name: ')
cc_holder_input = input('Enter Credit Card Holder (John Smith): ')
cc_number_input = input('Enter Credit Card Number (1234): ')
cc_expiration_input = input('Enter Credit Card Expiration Date (12/26): ')
cc_cvc_input = input('Enter Credit Card CVC (123): ')
auth_password_input = input('Enter Payment Authentication (mypass): ')


# application logic
hotel_id = Hotel(hotel_id_input)

if hotel_id.available():
    credit_card = AuthenticateCreditCard(number=cc_number_input)

    if credit_card.validate(expiration=cc_expiration_input, cvc=cc_cvc_input, holder=cc_holder_input):

        if credit_card.authenticate(password_input=auth_password_input):
            hotel_id.book()
            # user_name = input('Enter Name: ')
            reservation = Reservation(name=user_name_input, hotel=hotel_id)
            print(reservation.generate())
        else:
            print('Incorrect Password')

    else:
        print('Incorrect Payment.')

else:
    print('Hotel Not Available.')