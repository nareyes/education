from re import X


user_age = int(input("Enter Age: "))
user_license = input('Are you licensed? (Y/N) ').lower()

if user_age >= 18 and user_license == 'y':
    print('Turn On')
else:
    print('Error: User Not Old Enough')