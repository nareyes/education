date = input("Enter Today's Date in YYYY-MM-DD Format: ").strip()
mood = input("Rate Today's Mood From 1 to 10: ").strip()
thoughts = input("Share Thoughts: ").strip()

# create new file and write user input
with open(f"data/{date}.txt", "w") as file:
    file.write(f"Date: {date}\n\n")
    file.write(f"Mood Rating: {mood}\n")
    file.write(f"Today's Thoughts: {thoughts}")