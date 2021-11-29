#define BOARD_NAME "RCM64V1"
#define VERSION "2" // must be integer number

// Temporary array size
#define MAX_ARRAY 100

// Default delay time
#define DELAY_TIME 100

// Default output state
#define OUTPUT_STATE 1

// Debug mode
bool DEBUG = true;

byte OUTPUT_PIN[] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57};

byte INPUT_PIN[] = {58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 69};

byte INPUT_STATE[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

String INPUT_STATE_LABEL[] = {"CLOSE", "OPEN"};




/*
-------------------------------------
Input:
  String str: string to print
-------------------------------------
*/
void DBG(String str)
{
  if (DEBUG == true)
    Serial.print(str);
}




/*
-------------------------------------
Input:
  String *iStr: address of string to split,
  String *aStr: address of the string array to contain the strings after splitting,
  byte *aIndex: index of aStr,
  String sSep: start character or separator,
  String eSep: end character,
  byte sD: start delta,
  byte eD: end delta
-------------------------------------
*/
void splitString(String *iStr, String *aStr, byte *aIndex, String sSep, String eSep, byte sD, byte eD)
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





/*
  Startup Message
*/
void startupMessage(){
  Serial.print("<CHECK_CONNECTION,CONNECTED,"+String(VERSION)+">\n");
  Serial.print("<BOARD,"+String(BOARD_NAME)+">\n");
}




/*
  Invalid Command
*/
void invalidCommand(){
  DBG("Invalid Command !");
  startupMessage();
}




/*
  Send state of pin to controller via serial
*/
void sendState(byte pinNum)
{
  byte state = INPUT_STATE[pinNum];
  String strState = INPUT_STATE_LABEL[state];
  Serial.print("<" + String(BOARD_NAME) + "," + String(pinNum) + "," + strState + ">\n");
}




/*
  Get all state of input pins and send to controller
*/
void getAllState()
{
  for (byte i = 0; i < sizeof(INPUT_PIN); i++)
  {
    byte pinNum = INPUT_PIN[i];
    INPUT_STATE[pinNum] = digitalRead(pinNum);
    sendState(pinNum);
  }
}




/*
  check the change of the state of the pins and send to controller
*/
void syncState()
{
  for (byte i = 0; i < sizeof(INPUT_PIN); i++)
  {
    byte pinNum = INPUT_PIN[i];
    if (digitalRead(pinNum) != INPUT_STATE[pinNum])
    {
      INPUT_STATE[pinNum] = digitalRead(pinNum);
      sendState(pinNum);
    }
  }
}




void setup()
{

  Serial.begin(9600);
  while (!Serial)
    continue;
  DBG("Ready\n");
  
  for (byte i = 0; i < sizeof(OUTPUT_PIN); i++)
  {
    DBG("Output: " + String(OUTPUT_PIN[i]) + "\n");
    pinMode(OUTPUT_PIN[i], OUTPUT);
    digitalWrite(OUTPUT_PIN[i], OUTPUT_STATE);
  }

  for (byte i = 0; i < sizeof(INPUT_PIN); i++)
  {
    DBG("Input: " + String(INPUT_PIN[i]) + "\n");
    pinMode(INPUT_PIN[i], INPUT_PULLUP);
  }
  getAllState();

}




void loop()
{
  // Receive data from serial
  if (Serial.available())
  {

    //<RCM64V1,[[10,11],[12,13],[14,15]],[0,DLY1000,1]>
    String input = Serial.readStringUntil('\n');

    //separate by < >
    String command[MAX_ARRAY];
    byte commandIndex = 0;
    splitString(&input, &command[0], &commandIndex, "<", ">", 1, 0);

    if(commandIndex == 0)
    {
      DBG(input+"\n");
      invalidCommand();
    }

    for (byte i = 0; i < commandIndex; i++)
    {
      DBG("Data: " + command[i] + "\n");

      //split by comma
      String arr[MAX_ARRAY];
      byte arrIndex = 0;
      splitString(&command[i], &arr[0], &arrIndex, ",", "", 1, 0);


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
      if (arrIndex == 2)
      {
        DBG("Board: " + arr[0] + "\n");

        if(arr[0] == String(BOARD_NAME))
        {

          String pins[MAX_ARRAY];
          byte pinsIndex = 0;
          splitString(&arr[1], &pins[0], &pinsIndex, "[[", "]]", 1, 1);
          if (pinsIndex == 1)
          {
            DBG("Pins: " + pins[0] + "\n");

            arr[1] = arr[1].substring(arr[1].indexOf("[[") + pins[0].length() + 3, arr[1].length());
            Serial.print("Actions: " + arr[1] + "\n");

            if(arr[1].indexOf("[") >= 0 && arr[1].indexOf("]") >= 0)
            {

              String pinsY[MAX_ARRAY];
              byte pinsYIndex = 0, pin[10][48];
              splitString(&pins[0], &pinsY[0], &pinsYIndex, "[", "]", 1, 0);

              for (byte j = 0; j < pinsYIndex; j++)
              {
                String pinsX[MAX_ARRAY];
                byte pinsXIndex = 0;
                splitString(&pinsY[j], &pinsX[0], &pinsXIndex, ",", "", 1, 0);
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
              splitString(&arr[1], &actions[0], &actionsIndex, ",", "", 1, 0);

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
              invalidCommand();
            }

          }
          else
          {
            invalidCommand();
          }
          

        }
        else
        {
          DBG("Invalid Board !");
        }
        

      }
      else if(arrIndex == 1)
      {
        if(arr[0] == "CHECK_CONNECTION")
        {
          startupMessage();
        }
        else if(arr[0] == "GET_ALL_STATE")
        {
          getAllState();
        }
        else
        {
          invalidCommand();
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
    syncState();
  }
}