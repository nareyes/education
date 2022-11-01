class Item:
    def __init__(self, name, price, quantity):
        self.name = name
        self.price = price
        self.quantity = quantity
    
    def calculate_total_price(self, x, y):
        return x * y


# create an instance of a class and assign attributes (example 1)
item1 = Item(name = 'Phone', price = 100, quantity = 5)

# create an instance of a class and assign attributes (example 2)
item2 = Item(name = 'Laptop', price = 1000, quantity = 3)



print(item1.name)
print(item1.price)
print(item1.quantity)

print(item2.name)
print(item2.price)
print(item2.quantity)