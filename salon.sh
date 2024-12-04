#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SERVICE_START(){
  if [[ $1 ]]	#SERVE A FAR PRINTARE GLI ARGOMENTI PASSATI ALLA FUNZIONE
  then
    echo -e "\n$1"
  fi
  GET_SERVICES_NAMES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  #if no services exists in the db
  if [[ -z $GET_SERVICES_NAMES ]] 
  then
    echo "Sorry, there are no bookable services"
  fi
  echo "$GET_SERVICES_NAMES" | while read SERVICE_ID BAR SERVICE_NAME #IMPORTANTE! ANCHE SE IL SERVICE NAME SONO 2 PAROLE LO LEGGE!!!
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  SERVICE_SELECTION
}

SERVICE_SELECTION() {
  if [[ $1 ]]	#SERVE A FAR PRINTARE GLI ARGOMENTI PASSATI ALLA FUNZIONE
  then
    echo -e "\n$1"
  fi
  echo -e "\nSelect a service"
  read SERVICE_ID_SELECTED
  #è un numero? se non lo è richiedi di inserire. Se lo è controlla se coincide con un servizio disponibile
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then
    echo -e "\nINSERT A VALID NUMBER"
    SERVICE_START 
  else
    #is the selected service in the list?
    LIST=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    if [[ -z $LIST ]]
    then
      SERVICE_START "The service you selected isn't available"
    else
      CUSTOMER_START "Insert your phone number"
    fi
  fi
}

CUSTOMER_START() {
  if [[ $1 ]]	#SERVE A FAR PRINTARE GLI ARGOMENTI PASSATI ALLA FUNZIONE
  then
    echo -e "\n$1"
  fi
  read CUSTOMER_PHONE
  #if THAT phone doesn't exist in db
  PHONEY=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
  if [[ -z $PHONEY ]]
  then
    echo "Insert your name"
    read CUSTOMER_NAME
    CUSTOMER_STATUS=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
  fi
  C_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  C_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo "Insert the time of the appointment"
  read SERVICE_TIME
  TIME_STATUS=$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $C_ID, $SERVICE_ID_SELECTED)")
  if [[ TIME_STATUS="INSERT 0 1" ]] 
  then
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME,$C_NAME."
  fi
}

SERVICE_START