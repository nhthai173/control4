bool DEBUG = true; // Debug mode

#define BOARD_NAME "CCM12V1" // board name
#define VERSION 1 // firmware version

#define MAX_ARRAY 32

byte SIREN_STATE = 1; // state to trigger siren
byte POWERCYCLE_STATE = 1;// State to trigger powercycle
byte POWERCYCLE_DELAY = 200;
byte TRIGGER_STATE = 0; // input trigger state
String STATE[2] = {"OPEN", "CLOSE"}; // input state: integer -> string (0 -> CLOSE, 1 -> OPEN)

#define NUMBER_INPUT_PIN 12
#define NUMBER_EMERGENCY_INPUT_PIN 2

byte INPUT_PIN[NUMBER_INPUT_PIN] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13};
byte EMERGENCY_INPUT_PIN[NUMBER_EMERGENCY_INPUT_PIN] = {12, 13};
byte SIREN_PIN[] = {14};
byte POWERCYCLE_PIN[] = {15};

byte INPUT_STATE[] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1};

// bypass zone init with 0. If a zone is bypassed then BYPASS_ZONE array will be replaced 0 with the pin number
byte BYPASS_ZONE[NUMBER_INPUT_PIN] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

bool IS_ARM = false;
int ENTRY_DELAY = 0;
bool START_ENTRY_DELAY = false;
bool END_ENTRY_DELAY = false;
unsigned long ENTRY_DELAY_ = 0;

//bool IN_ALARM = false;

bool IN_SENDALL = false;
byte SENDALL_INDEX = 0;
byte SENDALL_INTERVAL = 150;
unsigned long SENDALL_ = 0;




// print to serial when DEBUG == true
void dbg(String str)
{
    if (DEBUG == true)
        Serial.println(str);
}




// Send pin state to serial
void sendState(byte pinNum)
{
    byte state = INPUT_STATE[pinNum];
    String strState = STATE[state];
    Serial.print("<" + String(BOARD_NAME) + "," + String(pinNum) + "," + strState + ">\n");
}




// clear all bypass zones
void clearBypass()
{
    for (byte i = 0; i < NUMBER_INPUT_PIN; i++)
        BYPASS_ZONE[i] = 0;
    dbg("CLEAR BYPASS");
}




void sirenOn(){
    for (byte i = 0; i < sizeof(SIREN_PIN); i++)
        digitalWrite(SIREN_PIN[i], SIREN_STATE);
    dbg("SIREN ON");
}




void sirenOff(){
    for (byte i = 0; i < sizeof(SIREN_PIN); i++)
        digitalWrite(SIREN_PIN[i], !SIREN_STATE);
    dbg("SIREN OFF");
}




void powerCycle(){
    dbg("POWER CYCLE");
    for (byte i = 0; i < sizeof(POWERCYCLE_PIN); i++)
        digitalWrite(POWERCYCLE_PIN[i], !POWERCYCLE_STATE);
    delay(POWERCYCLE_DELAY);
    for (byte i = 0; i < sizeof(POWERCYCLE_PIN); i++)
        digitalWrite(POWERCYCLE_PIN[i], POWERCYCLE_STATE);
}




void entryDelay()
{
    if(START_ENTRY_DELAY == false){
        ENTRY_DELAY_ = millis();
        END_ENTRY_DELAY = false;
        START_ENTRY_DELAY = true;
        dbg("START ENTRY DELAY");
    }
}




/*
    alarm: When armed and a zone passed
    if emergency pin -> turn siren on
    else -> entry delay mode
*/
void alarm(String type)
{
    if (type == "EMERGENCY")
        sirenOn();
    else
        entryDelay();
}




void timer()
{
    //entry delay
    if (START_ENTRY_DELAY == true && END_ENTRY_DELAY == false && (((millis()-ENTRY_DELAY_) >= (1000*ENTRY_DELAY)) || (millis() - ENTRY_DELAY_ < 0) || ENTRY_DELAY == 0))
    {
        sirenOn();
        END_ENTRY_DELAY = true;
    }

    // send all state with delay interval
    if(IN_SENDALL == true && millis()-SENDALL_ >= SENDALL_INTERVAL)
    {
        SENDALL_ = millis();
        if(SENDALL_INDEX < NUMBER_INPUT_PIN)
        {
            byte pst = INPUT_PIN[SENDALL_INDEX];
            byte vst = digitalRead(pst);
            INPUT_STATE[pst] = vst;
            sendState(pst);
            SENDALL_INDEX++;
        }else
            IN_SENDALL = false;
    }
}




/*
    Arm mode:
    clear bypass and append all pins had state as TRIGGER_STATE to bypass
*/
void arm(bool st, byte ed)
{
    START_ENTRY_DELAY = false;
    END_ENTRY_DELAY = false;
    clearBypass();
    ENTRY_DELAY = ed;
    dbg("Entry delay: "+String(ENTRY_DELAY));
    if(st == true)
    {
        IS_ARM = true;
        byte bzi = 0;
        for (byte i = 0; i < NUMBER_INPUT_PIN; i++)
        {
            byte pst = INPUT_PIN[i];
            byte vst = digitalRead(pst);
            if (vst == TRIGGER_STATE)
            {
                BYPASS_ZONE[bzi] = pst;
                bzi++;
            }
        }
        dbg("ARMED");
    }
    else
    {
        IS_ARM = false;
    }
}




/*
    Disarm:
    clear bypass, power cycle and turn siren off
*/
void disarm()
{
    arm(false, 0);
    powerCycle();
    sirenOff();
    dbg("DISARMED");
}




// sync all changes of pin state
void syncStateLite()
{
    for (byte i = 0; i < NUMBER_INPUT_PIN; i++)
    {
        byte pin = INPUT_PIN[i];
        if (digitalRead(pin) != INPUT_STATE[pin])
        {
            INPUT_STATE[pin] = !INPUT_STATE[pin];
            sendState(pin);
        }
    }
}




// Get all state: send all state of input pins
void getAllState()
{
    IN_SENDALL = true;
    SENDALL_INDEX = 0;
    SENDALL_ = millis();
}




/* 
    Sync state: sync all changes of pin state
    when armed and a pin has a state the same as TRIGGER_STATE -> alarm()
*/
void syncState()
{
    for (byte i = 0; i < NUMBER_INPUT_PIN; i++)
    {
        byte pst = INPUT_PIN[i];
        byte vst = digitalRead(pst);
        if (vst != INPUT_STATE[pst])
        {
            INPUT_STATE[pst] = vst;
            sendState(pst);
            if (vst == TRIGGER_STATE)
            {
                bool isEmergency = false;
                for (byte j = 0; j < NUMBER_EMERGENCY_INPUT_PIN; j++)
                {
                    if (EMERGENCY_INPUT_PIN[j] == pst)
                    {
                        isEmergency = true;
                        break;
                    }
                }
                if (isEmergency == true)
                {
                    alarm("EMERGENCY");
                    continue;
                }
                if (IS_ARM == true)
                {
                    bool isBypass = false;
                    for (byte j = 0; j < NUMBER_INPUT_PIN; j++)
                    {
                        if (BYPASS_ZONE[j] == pst)
                        {
                            isBypass = true;
                            break;
                        }
                    }
                    if (isBypass == false)
                    {
                        alarm("");
                        continue;
                    }
                }
            }
            else if (IS_ARM == true)
            {
                // when armed and input state != TRIGGER_STATE -> remove pin from bypass
                for (byte j = 0; j < NUMBER_INPUT_PIN; j++)
                {
                    if (BYPASS_ZONE[j] == pst)
                    {
                        BYPASS_ZONE[j] = 0;
                        break;
                    }
                }
            }
        }
    }
}





void setup()
{
    Serial.begin(9600);
    while (!Serial)
        continue;
    dbg("ready");

    for (byte i = 0; i < NUMBER_INPUT_PIN; i++)
    {
        pinMode(INPUT_PIN[i], INPUT_PULLUP);
        dbg("Input:" + String(INPUT_PIN[i]));
    }

    for (byte i = 0; i < sizeof(SIREN_PIN); i++)
    {
        pinMode(SIREN_PIN[i], OUTPUT);
        digitalWrite(SIREN_PIN[i], !SIREN_STATE);
        dbg("Siren: " + String(SIREN_PIN[i]));
    }

    for (byte i = 0; i < sizeof(POWERCYCLE_PIN); i++)
    {
        pinMode(POWERCYCLE_PIN[i], OUTPUT);
        digitalWrite(POWERCYCLE_PIN[i], POWERCYCLE_STATE);
        dbg("POWERCYCLE: " + String(POWERCYCLE_PIN[i]));
    }

    getAllState();
}




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




void loop()
{

    if (Serial.available())
    {
        String input = Serial.readStringUntil('\n');
        String command[MAX_ARRAY];
        byte commandIndex = 0;
        splitString(&input, &command[0], &commandIndex, "<", ">", 1, 0);
        for(byte i=0; i<commandIndex; i++)
        {
            dbg("Data: "+command[i]);
            String subcommand[MAX_ARRAY];
            byte subcommandIndex = 0;
            splitString(&command[i], &subcommand[0], &subcommandIndex, ",", "", 1, 0);
            /*
            <ARM,TRUE,30>
            <ALARM>
            <DISARM>
            <GET_ALL_STATE>
            */
            if (subcommandIndex == 3 && subcommand[0] == "ARM")
            {
                if(subcommand[1] == "TRUE"){
                    arm(true, subcommand[2].toInt());
                }
                else if (subcommand[1] == "FALSE"){
                    arm(false, subcommand[2].toInt());
                }
            }
            else if (subcommandIndex == 1)
            {
                if(subcommand[0] == "DISARM")
                    disarm();
                else if(subcommand[0] == "GET_ALL_STATE")
                    getAllState();
                else if(subcommand[0] == "ALARM")
                    sirenOn();
            }
        }
    }
    else
    {
        syncState();
        timer();
    }
}