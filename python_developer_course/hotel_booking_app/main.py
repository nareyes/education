import pandas as pd


# import data
df_hotels = pd.read_csv('hotels.csv', dtype={'id': str})
df_cards = pd.read_csv('cards.csv', dtype=str).to_dict(orient='records')
df_cards_sec = pd.read_csv('cards_security.csv', dtype=str)


# create classes
class Hotel:

    def __init__(self, hotel_id):
        self.hotel_id = hotel_id
        self.hotel_city = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'city'].squeeze()
        self.hotel_name = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'name'].squeeze()


    def book(self):
        df_hotels.loc[df_hotels['id'] == self.hotel_id, 'available'] = 'no'
        df_hotels.to_csv('hotels.csv', index=False)

    def available(self):
        availability = df_hotels.loc[df_hotels['id'] == self.hotel_id, 'available'].squeeze()

        if availability == 'yes':
            return True 
        else:
            return False


class Reservation:
    
    def __init__(self, name, hotel):
        self.name = name
        self.hotel = hotel

    def generate(self):
        ticket = f'''
        Name: {self.name}
        City: {self.hotel.hotel_city}
        Hotel: {self.hotel.hotel_name}
        Payment and Booking Confirmed!
        '''

        return ticket


class CreditCard:
    
    def __init__(self, number):
        self.number = number

    def validate(self, expiration, cvc, holder):
        card_data = {
            'number': self.number,
            'expiration': expiration,
            'cvc': cvc,
            'holder': holder
        }

        if card_data in df_cards:
            return True
        else:
            return False


class AuthenticateCreditCard(CreditCard):
    def authenticate(self, password_input):
        password = df_cards_sec.loc[df_cards_sec['number'] == self.number, 'password'].squeeze()

        if password == password_input:
            return True
        else:
            return False


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