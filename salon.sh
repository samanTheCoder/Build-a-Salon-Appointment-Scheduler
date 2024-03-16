#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c "

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

GET_SERVICES=$($PSQL "
SELECT *
FROM services
")

#show services in id) <service> format
SHOW_SERVICES () {
  if [[ ! -z $1 ]]
  then echo -e $1
  fi

  echo "$GET_SERVICES" | while read SERVICE_ID BAR NAME
  do
  echo "$SERVICE_ID) $NAME"
  done
}

SHOW_SERVICES

#prompt service_id, phone number, a name if they aren’t already a customer, and a time
#SERVICE_ID_SELECTED, CUSTOMER_PHONE, CUSTOMER_NAME, and SERVICE_TIME
CHOOSE_SERVICE () {
  read SERVICE_ID_SELECTED

  SERVICE_ID=$($PSQL "
  SELECT service_id
  FROM services
  WHERE service_id = $SERVICE_ID_SELECTED
  ")
}

CHOOSE_SERVICE

while [[ -z $SERVICE_ID ]]
do
  SHOW_SERVICES "\nI could not find that service. What would you like today?"
  CHOOSE_SERVICE
done

echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

#check phone number, if not available, get the customers name and enter it, and the phone number, into the customers table
CUSTOMER_ID=$($PSQL "
  SELECT customer_id
  FROM customers
  WHERE phone = '$CUSTOMER_PHONE'
")

if [[ -z $CUSTOMER_ID ]]
then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  INSERT_NEW_CUSTOMER=$($PSQL "
  INSERT
  INTO customers(phone, name)
  VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')
  ")

  CUSTOMER_ID=$($PSQL "
  SELECT customer_id
  FROM customers
  WHERE phone = '$CUSTOMER_PHONE'
")
fi

CUSTOMER_NAME=$($PSQL "
  SELECT name
  FROM customers
  WHERE customer_id = '$CUSTOMER_ID'
")

echo -e "\nWhat time would you like your cut, $(echo $CUSTOMER_NAME | sed 's/^ //')?"
read SERVICE_TIME

#I have put you down for a <service> at <time>, <name>.
INSERT_NEW_appointment=$($PSQL "
  INSERT
  INTO appointments(time, customer_id, service_id)
  VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)
  ")

SELECTED_SERVICE=$($PSQL "
  SELECT name
  FROM services
  WHERE service_id = $SERVICE_ID_SELECTED
")

echo -e "\nI have put you down for a $(echo $SELECTED_SERVICE | sed 's/^ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/^ //')."