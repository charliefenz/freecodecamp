#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

INSERT_TEAM() {
  for arg in "$@"
  do
    # check team is present in teams
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$arg'")
    if [[ -z $TEAM_ID ]]
    then
      # if not, insert it
      TEAM_INSERTION=$($PSQL "INSERT INTO teams(name) VALUES('$arg')")
      if [[ $TEAM_INSERTION = "INSERT 0 1" ]]
      then
        echo Inserted team $arg into table teams
      else
        echo An error ocurred trying to insert team $arg into table teams: $TEAM_INSERTION
      fi
    fi
  done
}

# Clear tables
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS=',' read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then
    INSERT_TEAM "$WINNER" "$OPPONENT"
    # get the id
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    # insert data with team id instead of team name
    GAME_INSERTION=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $GAME_INSERTION = "INSERT 0 1" ]]
    then
      echo Inserted game $ROUND - $WINNER - $OPPONENT into table games
    else
      echo An error ocurred trying to insert game $ROUND - $WINNER - $OPPONENT into table games: $GAME_INSERTION
    fi  
  fi
done