#!/bin/bash
NUMBER_TO_GUESS=$(( (RANDOM % 1000) + 1 ))
GUESSES_TAKEN=1
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo 'Enter your username: '
read USERNAME_INPUT
USER=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'");
if [[ -z $USER ]]; then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users (username, games_played, best_game) VALUES ('$USERNAME_INPUT', 0, 0)")
  USER=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT'");
else
  USER_INFO=$($PSQL "SELECT games_played, best_game FROM users WHERE user_id=$USER");
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< $USER_INFO
  echo "Welcome back, $USERNAME_INPUT! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses. "
fi
echo "Guess the secret number between 1 and 1000:"
echo "number to guess $NUMBER_TO_GUESS"
read GUESS_INPUT
while [[ $GUESS_INPUT -ne $NUMBER_TO_GUESS ]];
do
  (( GUESSES_TAKEN++ ))
  if [[ "$GUESS_INPUT" =~ ^[0-9]+$ ]]; then
    if [[ $GUESS_INPUT -gt $NUMBER_TO_GUESS ]]; then
      echo "It's lower than that, guess again: "
    else
      echo "It's higher than that, guess again: "
    fi  
  else
    echo "That is not an integer, guess again: "
  fi
  read GUESS_INPUT
done
echo "You guessed it in $GUESSES_TAKEN tries. The secret number was $NUMBER_TO_GUESS. Nice job! "
UPDATE_GAME=$($PSQL "UPDATE users SET games_played = $(( ++GAMES_PLAYED )) WHERE user_id=$USER")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id=$USER")
if [[ $BEST_GAME -eq 0 || $BEST_GAME -gt $GUESSES_TAKEN ]]; then
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $GUESSES_TAKEN WHERE user_id=$USER")
fi
