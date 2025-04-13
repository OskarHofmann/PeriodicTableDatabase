#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ -z "$1" ]
then
  echo "Please provide an element as an argument."
else
  # if argument is number
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number='$1'")
  else
    ASSUME_SYMBOL_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$1'")
    if [[ -n $ASSUME_SYMBOL_RESULT ]]
    then
      ATOMIC_NUMBER=$ASSUME_SYMBOL_RESULT
    else
      ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$1'")
    fi
  fi

  if [[ -n $ATOMIC_NUMBER ]]
  then
    IFS='|' read -r NAME SYMBOL TYPE MASS MELTING BOILING < <(echo $($PSQL "SELECT name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius FROM elements FULL JOIN properties USING(atomic_number) FULL JOIN types USING(type_id) WHERE atomic_number=$ATOMIC_NUMBER"))
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  else
    echo "I could not find that element in the database."
  fi
fi
