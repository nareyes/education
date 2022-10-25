# create a basic class
# functions inside classes are called methods
class Item:
    def calculate_total_price(self, x, y):
        return x * y


# create an instance of a class and assign attributes (example 1)
item1 = Item()
item1.name = 'Phone'
item1.price = 100
item1.quantity = 5


# create an instance of a class and assign attributes (example 2)
item2 = Item()
item2.name = 'Laptop'
item2.price = 1000
item2.quantity = 3


# call method from instance of a class (example 1)
item1_total = item1.calculate_total_price(item1.price, item1.quantity)
print(item1_total)


# call method from instance of a class (example 2)
item2_total = item2.calculate_total_price(item2.price, item2.quantity)
print(item2_total)