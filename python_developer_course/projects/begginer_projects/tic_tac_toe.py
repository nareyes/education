def display_board(board):
    blank_board = """
    ___________________
    |     |     |     |
    |  1  |  2  |  3  |
    |     |     |     |
    |-----------------|
    |     |     |     |
    |  4  |  5  |  6  |
    |     |     |     |
    |-----------------|
    |     |     |     |
    |  7  |  8  |  9  |
    |     |     |     |
    |-----------------|

    """

    # replaces position number inside blank_board with the player choice or a blank
    for i in range(1, 10):
        if (board[i] == 'O' or board[i] == 'X'):
            blank_board = blank_board.replace(str(i), board[i])

        else:
            blank_board = blank_board.replace(str(i), ' ')

    print(blank_board)


# captures player input for marker choice and assigns marker for second player
def player_input():
    player_one = input("Please pick a marker, 'X' or 'O': ").upper()

    while True:
        if player_one == 'X':
            player_two = 'O'
            print(f"\nPlayer One is {player_one}")
            print(f"Player Two is {player_two} \n")

            return player_one, player_two

        elif player_one == 'O':
            player_two = 'X'
            print(f"Player One is {player_one}")
            print(f"Player Two is {player_two}")

            return player_one, player_two

        else:
            player_one = input("Please pick a marker, 'X' or 'O': ").upper()


# assigns the marker to the board list and replaces the # at the given position
def place_marker(board, marker, position):
    board[position] = marker
    return board


# returns true if the input position is free
def space_check(board, position):
    return board[position] == '#'


# stores player input choice as long as the position is free
def player_choice(board):
    choice = input("Please select an empty space between 1 and 9: ")

    while not space_check(board, int(choice)):
        choice = input(
            "This space isn't free. Please select an empty space between 1 and 9: ")

    return choice


# returns true if board is full
def full_board_check(board):
    return len([x for x in board if x == '#']) == 1


# returns true if a player has one
def win_check(board, mark):
    # check rows
    if board[1] == board[2] == board[3] == mark:
        return True
    if board[4] == board[5] == board[6] == mark:
        return True
    if board[7] == board[8] == board[9] == mark:
        return True

    # check columns
    if board[1] == board[4] == board[7] == mark:
        return True
    if board[2] == board[5] == board[8] == mark:
        return True
    if board[3] == board[6] == board[9] == mark:
        return True

    # check diagonals
    if board[1] == board[5] == board[9] == mark:
        return True
    if board[3] == board[5] == board[7] == mark:
        return True

    return False


def replay():
    play_again = input("Do you want to play again (Y/N)? ").upper()

    if play_again == 'Y':
        return True
    if play_again == 'N':
        return False


# run the game
if __name__ == "__main__":
    print(
        '''
    Welcome to Tic-Tac-Toe!

    ___________________
    |     |     |     |
    |  1  |  2  |  3  |
    |     |     |     |
    |-----------------|
    |     |     |     |
    |  4  |  5  |  6  |
    |     |     |     |
    |-----------------|
    |     |     |     |
    |  7  |  8  |  9  |
    |     |     |     |
    |-----------------|


    Reference the above board for index locations. \n
    '''
    )

    i = 1

    # choose your marker
    players = player_input()

    # empty board
    board = ['#'] * 10

    while True:
        # game setup
        game_on = full_board_check(board)

        while not game_on:
            # player chooses position
            position = player_choice(board)

            # determine who is playing
            if i % 2 == 0:
                marker = players[1]
            else:
                marker = players[0]

            # play
            place_marker(board, marker, int(position))

            # check board
            display_board(board)

            i += 1

            if win_check(board, marker):
                print("You Won!")
                break

            game_on = full_board_check(board)

        if not replay():
            break

        else:
            i = 1

            # choose side
            players = player_input()

            # empty board
            board = ['#'] * 10
