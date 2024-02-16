# import modules
import random


# global variables
suits = ('Hearts', 'Diamonds', 'Spades', 'Clubs')

ranks = ('Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Jack', 'Queen', 'King', 'Ace')

values = {
    'Two'   : 2,
    'Three' : 3,
    'Four'  : 4,
    'Five'  : 5,
    'Six'   : 6,
    'Seven' : 7,
    'Eight' : 8,
    'Nine'  : 9,
    'Ten'   : 10,
    'Jack'  : 11,
    'Queen' : 12,
    'King'  : 13,
    'Ace'   : 14
}


# card class (suit, rank, value)
class Card:

    def __init__(self, suit, rank):
        self.suit = suit
        self.rank = rank
        self.value = values[rank]
    
    def __str__(self):
        return f"{self.rank} of {self.suit}"


# deck class (52 card classes)
class Deck:

    def __init__(self):
        self.all_cards = []

        for suit in suits:
            for rank in ranks:
                #create card objects
                created_card = Card(suit, rank)
                self.all_cards.append(created_card)

    def shuffle(self):
        random.shuffle(self.all_cards)
    
    def deal_one(self):
        # use pop method to remove one card from shuffled deck
        return self.all_cards.pop()


# player class
class Player:

    def __init__(self, name):
        self.name = name
        self.all_cards = []
    
    def remove_one(self):
        return self.all_cards.pop(0)

    def add_cards(self, new_cards):
        if type(new_cards) == type([]):
            #multiple card objects
            self.all_cards.extend(new_cards)
        
        else:
            # single card object
            self.all_cards.append(new_cards)

    def __str__(self):
        return f'Player {self.name} has {len(self.all_cards)} cards.'


# game setup
player_one = Player('One')
player_two = Player('Two')

new_deck = Deck()
new_deck.shuffle()

# deal cards
for x in range(26):
    player_one.add_cards(new_deck.deal_one())
    player_two.add_cards(new_deck.deal_one())

# game logic
game_on = True
round_num= 0

# start a new game
while game_on:
    round_num += 1
    print(f'Round {round_num}')

    if len(player_one.all_cards) == 0:
        print('Player Two Wins!')
        game_on = False
        break

    if len(player_two.all_cards) == 0:
        print('Player One Wins!')
        game_on = False
        break

    # start a new round
    player_one_cards = []
    player_one_cards.append(player_one.remove_one())
    
    player_two_cards = []
    player_two_cards.append(player_two.remove_one())

    # round and war logic
    at_war = True

    while at_war:
        # player one wins round
        if player_one_cards[-1].value > player_two_cards[-1].value:
            player_one.add_cards(player_one_cards)
            player_one.add_cards(player_two_cards)
            at_war = False
        
        # player two wins round
        elif player_one_cards[-1].value < player_two_cards[-1].value:
            player_two.add_cards(player_one_cards)
            player_two.add_cards(player_two_cards)
            at_war = False
        
        # player one and two are at war
        else:
            print('WAR!')
            if len(player_one.all_cards) < 3:
                print('Player One Unable to Declare War')
                print('Player Two Wins!')
                game_on = False
                break

            elif len(player_two.all_cards) < 3:
                print('Player Two Unable to Declare War')
                print('Player One Wins!')
                game_on = False
                break

            else:
                for num in range(3):
                    player_one_cards.append(player_one.remove_one())
                    player_two_cards.append(player_two.remove_one())