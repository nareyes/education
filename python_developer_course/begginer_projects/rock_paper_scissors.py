import random


def get_choices():
    player_choice = input('Enter Choice: Rock, Paper, or Scissors? ')

    computer_options = ['Rock', 'Paper', 'Scissors']
    computer_choice = random.choice(computer_options)

    choices = {
        'player': player_choice,
        'computer': computer_choice
    }

    return choices


def check_win(player, computer):
    print(f'Player Chose: {player}')
    print(f'Computer Chose: {computer}')

    if player == computer:
        return 'It\'s a Tie!'
    
    elif player == 'Rock':
        if computer == 'Scissors':
            return 'Rock Beats Scissors! You Win!'
        else:
            return 'Paper Beats Rock! You Lose!'

    elif player == 'Paper':
        if computer == 'Rock':
            return 'Paper Beats Rock! You Win!'
        else:
            return 'Scissors Beats Paper! You Lose!'

    elif player == 'Scissors':
        if computer == 'Paper':
            return 'Scissors Beats Paper! You Win!'
        else:
            return 'Rock Beats Scissors! You Lose!'


choices = get_choices()
result = check_win(choices['player'], choices['computer'])

print(result)