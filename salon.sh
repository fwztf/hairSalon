#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

SALON_FUNCTION() {
    if [[ $1 ]]
    then
        echo -e "\n$1"
    fi
    
    echo -e "Which service would you like to book?\n"
    
    #retrieve list of services from DB
    SERVICES_OFFERED=$($PSQL "SELECT * FROM services")
    
    #display formatted list of services
    echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE_NAME
    do
        if [[ $SERVICE_ID != "service_id" ]]
        then
            echo "$SERVICE_ID) $SERVICE_NAME"
        fi
    done
    
    #get user input
    read SERVICE_ID_SELECTED
    
    #check if user input is a valid service
    VALID_SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
    #if user input is invalid
    if [[ -z $VALID_SERVICE_ID ]]
    then
        #display the same list of services again
        echo "$SERVICES_OFFERED" | while read SERVICE_ID BAR SERVICE_NAME
        do
            if [[ $SERVICE_ID != "service_id" ]]
            then
                echo "$SERVICE_ID) $SERVICE_NAME"
            fi
        done
    else
        #if user input is valid
        #ask for user's phone number
        echo -e "\nEnter your phone number: "
        read CUSTOMER_PHONE
        
        #check if user is already a customer
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
        
        #if user is not a customer
        if [[ -z $CUSTOMER_ID ]]
        then
            #ask user for their name
            echo -e "\nEnter your name: "
            read CUSTOMER_NAME
            
            #insert new user record into customers table
            NEW_CUSTOMER_RECORD=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
            
            #get new customer_id
            NEW_CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
            
            #ask user for appointment time
            echo -e "\nEnter desired service time: "
            read SERVICE_TIME
            
            #book appointment for new customer
            NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($NEW_CUSTOMER_ID, $VALID_SERVICE_ID, '$SERVICE_TIME')")
            
            #get name of selected service
            NAME_OF_SELECTED_SERVICE_FORMATTED=$(echo "$($PSQL "SELECT name FROM services WHERE service_id=$VALID_SERVICE_ID")" | sed -r 's/^ *| *$//g')
            
            #get customer name
            VALID_CUSTOMER_NAME_FORMATTED=$(echo "$($PSQL "SELECT name FROM customers WHERE customer_id=$NEW_CUSTOMER_ID")" | sed -r 's/^ *| *$//g')
            
            #display successful appointment booking message
            echo -e "\nI have put you down for a $NAME_OF_SELECTED_SERVICE_FORMATTED at $SERVICE_TIME, $VALID_CUSTOMER_NAME_FORMATTED."
        else
            #if user is already a customer
            #ask user for appointment time
            echo -e "\nEnter desired service time: "
            read SERVICE_TIME
            
            #book appointment for existing customer
            NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $VALID_SERVICE_ID, '$SERVICE_TIME')")
            
            #get name of selected service
            NAME_OF_SELECTED_SERVICE_FORMATTED=$(echo "$($PSQL "SELECT name FROM services WHERE service_id=$VALID_SERVICE_ID")" | sed -r 's/^ *| *$//g')
            
            #get customer name
            VALID_CUSTOMER_NAME_FORMATTED=$(echo "$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")" | sed -r 's/^ *| *$//g')
            
            #display successful appointment booking message
            SUCCESS_MSG_FORMATTED="I have put you down for a $NAME_OF_SELECTED_SERVICE_FORMATTED at $SERVICE_TIME, $VALID_CUSTOMER_NAME_FORMATTED."
            
            #print formatted success message
            echo -e "\n$SUCCESS_MSG_FORMATTED"
        fi
    fi
    
}

SALON_FUNCTION
