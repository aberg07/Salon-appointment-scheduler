#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  #Read through the services table, storing id and name into SERVICE_ID and SERVICE_NAME
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  #Sends user back to start if the service does not exist
  if [[ -z $SERVICE ]]
  then
    MAIN_MENU "Please enter a valid option."
  else
    #Pass the service ID user selected and the name of that service as arguments to the MAKE_APPOINTMENT function
    MAKE_APPOINTMENT $SERVICE_ID_SELECTED $SERVICE
  fi
}

MAKE_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  #Add user to database if their phone number is not in the database
  if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nWhat's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
  echo -e "\nWhat time would you like to book your appointment for, $(echo $CUSTOMER_NAME | sed 's/ $//')?"
  read SERVICE_TIME
  MAKE_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $1, '$SERVICE_TIME')")
  if [[ $MAKE_APPOINTMENT_RESULT="INSERT 0 1" ]]
  then
    #Using sed to trim whitespace at the end of the user's name that gets added along the way.
    echo -e "\nI have put you down for a $2 at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ $//')."
  fi
}

echo -e "\n~~~~ Cloud 9 Salon ~~~~\n"
echo -e "Which service would you like to book an appointment for?"
MAIN_MENU