import pandas as pd


# import data
df = pd.read_csv('hotels.csv', dtype={'id': str})


# create classes
class Hotel:

    def __init__(self, hotel_id):
        self.hotel_id = hotel_id
        self.hotel_city = df.loc[df['id'] == self.hotel_id, 'city'].squeeze()
        self.hotel_name = df.loc[df['id'] == self.hotel_id, 'name'].squeeze()


    def book(self):
        df.loc[df['id'] == self.hotel_id, 'available'] = 'no'
        df.to_csv('hotels.csv', index=False)

    def available(self):
        availability = df.loc[df['id'] == self.hotel_id, 'available'].squeeze()
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
        Booking Confirmed!
        '''

        return ticket


# application logic
print('\nList of Hotels:\n')
print(df)

hotel_id_input = input('\nEnter Hotel ID: ')
hotel_id = Hotel(hotel_id_input)

if hotel_id.available():
    hotel_id.book()
    user_name = input('Enter Name: ')
    reservation = Reservation(name=user_name, hotel=hotel_id)
    print(reservation.generate())
else:
    print('Hotel Not Available.')