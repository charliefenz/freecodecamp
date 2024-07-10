#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"
ERROR_MESSAGE="I could not find that element in the database."

getSearchQuery() {
  SEARCH_QUERY="SELECT atomic_number FROM elements WHERE $1='$2'"
}
getPropertiesQuery() {
  PROPERTIES_QUERY="SELECT elements.name, elements.symbol, properties.atomic_mass, properties.melting_point_celsius, properties.boiling_point_celsius, types.type FROM elements JOIN properties ON elements.atomic_number=properties.atomic_number JOIN types ON properties.type_id=types.type_id WHERE elements.atomic_number='$1'"  
}
getOkMessage() {
  getPropertiesQuery $1
  QUERY_RESULT=$($PSQL "$PROPERTIES_QUERY")
  IFS='|' read -r ELEMENT_NAME ELEMENT_SYMBOL ATOMIC_MASS MELTING_POINT BOILING_POINT TYPE <<< $QUERY_RESULT
  echo "The element with atomic number $ATOMIC_NUMBER is $ELEMENT_NAME ($ELEMENT_SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $ELEMENT_NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
}

if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
else
  INPUT_ELEMENT=$1
  SEARCH_CONDITION='name'
  getSearchQuery $SEARCH_CONDITION $INPUT_ELEMENT
  ATOMIC_NUMBER=$($PSQL "$SEARCH_QUERY");
  if [[ -z $ATOMIC_NUMBER ]]; then
    if [[ "$INPUT_ELEMENT" =~ ^[0-9]+$ ]]; then
      SEARCH_CONDITION='atomic_number'
      getSearchQuery $SEARCH_CONDITION $INPUT_ELEMENT
      ATOMIC_NUMBER=$($PSQL "$SEARCH_QUERY");
      if [[ -z $ATOMIC_NUMBER ]]; then
        echo $ERROR_MESSAGE
      else
        getOkMessage $ATOMIC_NUMBER
      fi
    else
      SEARCH_CONDITION='symbol'
      getSearchQuery $SEARCH_CONDITION $INPUT_ELEMENT
      ATOMIC_NUMBER=$($PSQL "$SEARCH_QUERY");
      if [[ -z $ATOMIC_NUMBER ]]; then
        echo $ERROR_MESSAGE
      else
        getOkMessage $ATOMIC_NUMBER
      fi
    fi
  else
    getOkMessage $ATOMIC_NUMBER
  fi
fi