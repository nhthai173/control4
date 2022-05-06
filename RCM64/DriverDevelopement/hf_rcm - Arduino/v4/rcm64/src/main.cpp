#include <Arduino.h>
#include "SimpleTimer.h"
#include <EEPROM.h>

#define BOARD_NAME "RCM64V1"
#define VERSION "4" // must be integer number

// Temporary array size
#define MAX_ARRAY 50

// Input state size
#define INPUT_STATE_SIZE 12

// Default time delay between 2 commands sending
#define DELAY_SEND_TIME 100

// Default output state
#define OUTPUT_STATE 1

// When analog value changes greater than this number -> send to serial
const unsigned int ANALOG_DELTA = 8;

// Debug mode
bool DEBUG = false;
byte DEBUG_LEVEL = 1;

byte OUTPUT_PIN[] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57};

const byte INPUT_LENGTH = 12;
byte INPUT_PIN[INPUT_LENGTH] = {58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69};
byte INPUT_MODE[INPUT_LENGTH];
unsigned int INPUT_STATE[INPUT_LENGTH][INPUT_STATE_SIZE] = {{}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}, {}};

const byte DIGITAL_MODE = 0;
const byte ANALOG_MODE = 1;

String INPUT_STATE_LABEL[] = {"CLOSE", "OPEN"};

String SERIAL_SEND[5 * INPUT_LENGTH];

SimpleTimer timer;

/*
===================================
            SUB FUNCTION
===================================
*/

void restart();

/**
 * @brief Print string to Serial
 *
 * @param str String to print
 */
void DBG(String str, byte level = 0)
{
    if (DEBUG == true && DEBUG_LEVEL >= level)
        Serial.print(str);
}

/**
 * @brief
 *
 * @param iStr address of string to split
 * @param aStr address of the string array to contain the strings after splitting
 * @param aIndex index of aStr
 * @param sSep start character or separator
 * @param eSep end character
 * @param sD start delta
 * @param eD end delta
 */

void splitString(String *iStr, String *aStr, byte *aIndex, String sSep = "", String eSep = "", byte sD = 0, byte eD = 0)
{
    if (eSep != "")
    {
        int st = (*iStr).indexOf(sSep), en = (*iStr).indexOf(eSep);
        while (en > st && st > -1)
        {
            *(aStr + *aIndex) = (*iStr).substring(st + sD, en + eD);
            (*aIndex)++;
            st = (*iStr).indexOf(sSep, st + 1);
            en = (*iStr).indexOf(eSep, en + 1);
        }
    }
    else
    {
        int sepIndexList[12];
        byte sepIndex = 1;
        sepIndexList[0] = 0;
        int iTemp = (*iStr).indexOf(",");
        while (iTemp > -1)
        {
            if ((*iStr).indexOf("[") == -1 || iTemp < (*iStr).indexOf("[") || (*iStr).indexOf("]", iTemp) == -1)
            {
                sepIndexList[sepIndex] = iTemp;
                sepIndex++;
            }
            iTemp = (*iStr).indexOf(",", iTemp + 1);
        }
        sepIndexList[sepIndex] = (*iStr).length();
        for (byte i = 0; i < sepIndex; i++)
        {
            if (i == 0)
            {
                *(aStr + *aIndex) = (*iStr).substring(sepIndexList[i], sepIndexList[i + 1]);
            }
            else
            {
                *(aStr + *aIndex) = (*iStr).substring(sepIndexList[i] + 1, sepIndexList[i + 1]);
            }
            (*aIndex)++;
        }
    }
}

/**
 * @brief Messages to send on startup
 *
 */
void startupMessage()
{
    Serial.print("<CHECK_CONNECTION,CONNECTED," + String(VERSION) + ">\n");
    // Serial.print("<BOARD,"+String(BOARD_NAME)+">\n");
}

/**
 * @brief Message to send on invalid commands
 *
 */
void invalidCommand(int number = 0)
{
    DBG("Invalid Command [" + String(number) + "]\n");
    startupMessage();
}

int firstEmptySerialSend(byte fromPOS = 0)
{
    for (byte i = fromPOS; i < 5 * INPUT_LENGTH; i++)
    {
        if (SERIAL_SEND[i] == "")
            return i;
    }
    return -1;
}
int firstSerialSend(byte fromPOS = 0)
{
    for (byte i = fromPOS; i < 5 * INPUT_LENGTH; i++)
    {
        if (SERIAL_SEND[i] != "")
            return i;
    }
    return -1;
}
void sortSerialSend()
{
    int empty = firstEmptySerialSend();
    int valid = firstSerialSend();
    if (valid >= 0)
    {
        while (empty >= 0 && empty < valid)
        {
            SERIAL_SEND[empty] = SERIAL_SEND[valid];
            SERIAL_SEND[valid] = "";
            empty = firstEmptySerialSend(valid);
            valid = firstSerialSend(valid);
        }
    }
}

void send2serial()
{
    int index = firstSerialSend();
    if (index >= 0)
    {
        DBG("Send at: ", 1);
        DBG(String(millis()), 1);
        DBG("\t", 1);
        Serial.print(SERIAL_SEND[index]);
        SERIAL_SEND[index] = "";
        sortSerialSend();
        timer.setTimeout((long)DELAY_SEND_TIME, send2serial);
    }
}

/**
 * @brief Send pin state to Serial
 *
 * @param pinNum
 */
void sendState(byte pinIndex, byte mode = DIGITAL_MODE)
{
    unsigned int state = INPUT_STATE[pinIndex][0];
    String strState = "";
    if (mode == DIGITAL_MODE)
        strState = INPUT_STATE_LABEL[state];
    else if (mode == ANALOG_MODE)
    {
        DBG("Current: ", 3);
        DBG(String(analogRead(INPUT_PIN[pinIndex])), 3);
        DBG(" - ", 3);
        strState = String(state);
    }
    String data2send = "<" + String(BOARD_NAME) + "," + String(INPUT_PIN[pinIndex]) + "," + strState + ">\n";
    int nssIndex = firstEmptySerialSend();
    if (nssIndex >= 0)
    {
        SERIAL_SEND[nssIndex] = data2send;
        if (timer.getNumTimers() <= 2)
            timer.setTimeout((long)DELAY_SEND_TIME, send2serial);
    }
    else
    {
        DBG("Send to Serial fail - not enough empty slot\n");
        DBG("Data: " + data2send + "\n");
    }
}

//
void analogAverage(byte index)
{
    // position 0: average value
    // position 1: last send to serial value
    byte empty = 0;
    unsigned long sum = 0;
    for (byte i = 2; i < INPUT_STATE_SIZE; i++)
    {
        if (INPUT_STATE[index][i] == 0)
            empty++;
        else
            sum += INPUT_STATE[index][i];
    }
    if (sum > 0)
    {
        INPUT_STATE[index][0] = (unsigned int)floor(sum / (INPUT_STATE_SIZE - 2 - empty));
        for (byte i = 2; i < INPUT_STATE_SIZE; i++)
            INPUT_STATE[index][i] = 0;
    }
}

/**
 * @brief sync state loop
 *
 */
void syncStateALL(bool sendAfterSync = true)
{
    for (byte i = 0; i < INPUT_LENGTH; i++)
    {
        byte pinNum = INPUT_PIN[i];
        if (INPUT_MODE[i] == DIGITAL_MODE && (unsigned int)digitalRead(pinNum) != INPUT_STATE[i][0])
        {
            INPUT_STATE[i][0] = digitalRead(pinNum);
            if (sendAfterSync)
                sendState(i);
        }
        else if (INPUT_MODE[i] == ANALOG_MODE)
        {
            bool wrote = false;
            for (byte j = 2; j < INPUT_STATE_SIZE; j++)
            {
                if (INPUT_STATE[i][j] == 0)
                {
                    INPUT_STATE[i][j] = analogRead(INPUT_PIN[i]);
                    wrote = true;
                }
            }
            if (!wrote)
            {
                analogAverage(i);
                INPUT_STATE[i][2] = analogRead(INPUT_PIN[i]);
            }
        }
    }
}

/**
 * @brief sync state loop
 *
 */
void syncState()
{
    syncStateALL(true);
}

/**
 * @brief sync state analog loop
 *
 */
void syncStateAnalog()
{
    for (byte i = 0; i < INPUT_LENGTH; i++)
    {
        if (INPUT_MODE[i] == ANALOG_MODE)
        {
            analogAverage(i);
            int current = analogRead(INPUT_PIN[i]);
            DBG("Current: ", 3);
            DBG(String(current), 3);
            DBG("\nAverage: ", 3);
            DBG(String(INPUT_STATE[i][0]), 3);
            unsigned int delta = abs(INPUT_STATE[i][1] - INPUT_STATE[i][0]);
            DBG("\nDelta: ", 3);
            DBG(String(delta) + "\n", 3);
            if (ANALOG_DELTA < delta)
            {
                INPUT_STATE[i][1] = INPUT_STATE[i][0];
                sendState(i, ANALOG_MODE);
            }
        }
    }
}

void writeEEPROM(byte addr, byte type)
{
    EEPROM.begin();
    EEPROM.write(addr, type);
    EEPROM.end();
}

void getAllState()
{
    syncStateALL(false);
    for (byte i = 0; i < INPUT_LENGTH; i++)
    {
        if (INPUT_MODE[i] == ANALOG_MODE)
        {
            analogAverage(i);
            sendState(i, ANALOG_MODE);
        }
        else
        {
            sendState(i);
        }
    }
}

void changePinMode(byte pinIndex, String mode)
{
    bool success = true;
    if (mode == "ANALOG")
        writeEEPROM(pinIndex, ANALOG_MODE);
    else if (mode == "DIGITAL")
        writeEEPROM(pinIndex, DIGITAL_MODE);
    else
    {
        // invalid mode input
        success = false;
        DBG("Invalid Pin Mode");
    }
    if (success)
    {
        DBG("Change success!\n", 3);
        delay(500);
        restart();
    }
}

/*
===================================
        END SUB FUNCTION
===================================
*/

void startup()
{
    DBG("Startup!\n", 3);
    EEPROM.begin();
    for (byte i = 0; i < INPUT_LENGTH; i++)
    {
        byte eVal = EEPROM.read(i);
        if (eVal == ANALOG_MODE)
        {
            INPUT_MODE[i] = ANALOG_MODE;
            pinMode(INPUT_PIN[i], INPUT);
            DBG("Input: " + String(INPUT_PIN[i]) + " - Analog\n");
        }
        else if (eVal == DIGITAL_MODE)
        {
            INPUT_MODE[i] = DIGITAL_MODE;
            pinMode(INPUT_PIN[i], INPUT_PULLUP);
            DBG("Input: " + String(INPUT_PIN[i]) + " - Digital\n");
        }
        else
        {
            EEPROM.write(i, DIGITAL_MODE);
            delay(200);
            INPUT_MODE[i] = DIGITAL_MODE;
            pinMode(INPUT_PIN[i], INPUT_PULLUP);
            DBG("Input: " + String(INPUT_PIN[i]) + " - Digital\n");
        }
    }
    EEPROM.end();
}

void destroy()
{
    DBG("Destroy!\n", 3);
    for (byte i = 0; i < INPUT_LENGTH; i++)
    {
        for (byte j = 0; j < INPUT_STATE_SIZE; j++)
            INPUT_STATE[i][j] = 0;
    }
}

void restart()
{
    destroy();
    startup();
}

void setup()
{
    Serial.begin(9600);
    while (!Serial)
        delay(20);
    for (byte i = 0; i < 5 * INPUT_LENGTH; i++)
        SERIAL_SEND[i] = "";
    DBG("Ready\n", 3);
    startup();
    for (byte i = 0; i < sizeof(OUTPUT_PIN) / sizeof(OUTPUT_PIN[0]); i++)
    {
        DBG("Output: " + String(OUTPUT_PIN[i]) + "\n");
        pinMode(OUTPUT_PIN[i], OUTPUT);
        digitalWrite(OUTPUT_PIN[i], OUTPUT_STATE);
    }
    timer.setInterval(100L, syncState);
    timer.setInterval(1000L, syncStateAnalog);
    getAllState();
}

void loop()
{
    // Receive data from serial
    if (Serial.available())
    {

        //<RCM64V1,[[10,11],[12,13],[14,15]],[0,DLY1000,1]>
        String input = Serial.readStringUntil('\n');

        // separate by < >
        String command[MAX_ARRAY];
        byte commandIndex = 0;
        splitString(&input, &command[0], &commandIndex, "<", ">", 1, 0);

        if (commandIndex == 0)
        {
            DBG(input + "\n");
            invalidCommand(-2);
        }

        for (byte i = 0; i < commandIndex; i++)
        {
            DBG("Data: " + command[i] + "\n");

            // split by comma
            String arr[MAX_ARRAY];
            byte arrIndex = 0;
            splitString(&command[i], &arr[0], &arrIndex);

            /*
                <SET_PIN,55,ANALOG>
                <SET_PIN,56,DIGITAL>
            */
            if (arrIndex == 3)
            {
                if (arr[0] == "SET_PIN")
                {
                    byte addr = 50;
                    for (byte i = 0; i < INPUT_LENGTH; i++)
                    {
                        if (INPUT_PIN[i] == arr[1].toInt())
                        {
                            addr = i;
                            break;
                        }
                    }
                    if (addr < 50)
                    {
                        DBG("Change " + String(INPUT_PIN[addr]) + " -> " + arr[2] + "\n\n");
                        changePinMode(addr, arr[2]);
                    }
                }
            }

            /*
            -----------------------------
            Data contains only one comma
              "BOARD_NAME",CHECK
            or
              "BOARD_NAME",[[LIST_Of_PIN],[LIST_OF_ACTION]]
              RCM64V1,[[10,11],[12,13],[14,15]],[0,DLY100,1]
              RCM64V1,[[6]],[0]
            -----------------------------
            */
            else if (arrIndex == 2)
            {
                DBG("Board: " + arr[0] + "\n");

                if (arr[0] == String(BOARD_NAME))
                {

                    String pins[MAX_ARRAY];
                    byte pinsIndex = 0;
                    splitString(&arr[1], &pins[0], &pinsIndex, "[[", "]]", 1, 1);
                    if (pinsIndex == 1)
                    {
                        DBG("Pins: " + pins[0] + "\n");

                        arr[1] = arr[1].substring(arr[1].indexOf("[[") + pins[0].length() + 3, arr[1].length());
                        DBG("Actions: " + arr[1] + "\n");

                        if (arr[1].indexOf("[") >= 0 && arr[1].indexOf("]") >= 0)
                        {

                            String pinsY[MAX_ARRAY];
                            byte pinsYIndex = 0, pin[10][48];
                            splitString(&pins[0], &pinsY[0], &pinsYIndex, "[", "]", 1, 0);

                            for (byte j = 0; j < pinsYIndex; j++)
                            {
                                String pinsX[MAX_ARRAY];
                                byte pinsXIndex = 0;
                                splitString(&pinsY[j], &pinsX[0], &pinsXIndex);
                                for (byte k = 0; k < pinsXIndex; k++)
                                {
                                    pin[j][k] = pinsX[k].toInt();
                                }
                            }

                            // print pin array
                            /*
                            for(byte j=0; j<pinsYIndex; j++){
                              for(byte k=0; k<2; k++){
                                DBG("pin["+String(j)+"]["+String(k)+"]: " + String(pin[j][k]) + "\n");
                              }
                            }
                            */

                            String actions[MAX_ARRAY];
                            byte actionsIndex = 0;
                            arr[1] = arr[1].substring(1, arr[1].length() - 1);
                            splitString(&arr[1], &actions[0], &actionsIndex);

                            byte pinC = 0;
                            for (byte j = 0; j < actionsIndex; j++)
                            {
                                String action = actions[j];
                                if (action.indexOf("DLY") == 0)
                                {
                                    action = action.substring(3, action.length());
                                    DBG("Delay: " + action + "\n");
                                    delay(action.toInt());
                                }
                                else
                                {
                                    for (byte k = 0; k < pinsYIndex; k++)
                                    {
                                        DBG("DigitalWrite: " + String(pin[k][pinC]) + " -> " + action + "\n");
                                        digitalWrite(pin[k][pinC], action.toInt());
                                    }
                                    pinC++;
                                }
                            }
                        }
                        else
                        {
                            // invalid actions
                            invalidCommand(2);
                        }
                    }
                    else
                    {
                        // invalid pins
                        invalidCommand(3);
                    }
                }
                else
                {
                    DBG("Invalid Board !");
                }
            }

            /*
                <CHECK_CONNECTION>
                <GET_ALL_STATE>
            */
            else if (arrIndex == 1)
            {
                if (arr[0] == "CHECK_CONNECTION")
                {
                    startupMessage();
                    getAllState();
                }
                else if (arr[0] == "GET_ALL_STATE")
                {
                    getAllState();
                }
                else
                {
                    invalidCommand(-1);
                }
            }

            else
            {
                invalidCommand();
            }

            DBG("\n-----------------------\n");
        }
    }
    else
    {
        timer.run();
    }
}