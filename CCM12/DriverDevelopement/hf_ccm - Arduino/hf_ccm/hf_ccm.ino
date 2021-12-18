//#define DEBUG false
bool DEBUG = false;
#define BOARD_NAME "CCM12V1"

// The maximum length of the array that contains the sub-elements
// after splitting the string received from serial
#define MAL 14

// Default delay time
#define DELAY_TIME 100

#define DEFAULT_OUTPUT_STATE HIGH
#define TRIGGER_STATE LOW

// define state: 0 as OPEN, 1 as CLOSE
String STATE[2] = {"OPEN", "CLOSE"};

#define NUMBER_INPUT_PIN 14
#define NUMBER_EMERGENCY_INPUT_PIN 2
#define NUMBER_OUTPUT_PIN 2
byte INPUT_PIN[NUMBER_INPUT_PIN] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
byte EMERGENCY_INPUT_PIN[NUMBER_EMERGENCY_INPUT_PIN] = {12, 13};
byte OUTPUT_PIN[NUMBER_OUTPUT_PIN] = {14, 15};

byte INPUT_STATE[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

bool IS_ARM = false;
int ENTRY_DELAY = 0;
bool START_ENTRY_DELAY = false;
bool IN_ENTRY_DELAY = false;
bool IN_ALARM = false;

byte BYPASS_ZONE[NUMBER_INPUT_PIN];

unsigned long thoi_gian = 0;
int giay = 0;

void setup()
{

    Serial.begin(9600);
    while (!Serial) continue;
    if(DEBUG == true)
      delay(5000);

    for(byte i=0; i<NUMBER_INPUT_PIN; i++)
    {
      pinMode(INPUT_PIN[i], INPUT_PULLUP);
      dbg("Input:" + String(INPUT_PIN[i]));
    }
    for(byte i=0; i<NUMBER_OUTPUT_PIN; i++)
    {
      pinMode(OUTPUT_PIN[i], OUTPUT);
      digitalWrite(OUTPUT_PIN[i], DEFAULT_OUTPUT_STATE);
      dbg("Output:" + String(OUTPUT_PIN[i]));
    }
    syncState(true);
    
}






void dbg(String content)
{
  if(DEBUG == true)
    Serial.println(content);
}




void syncState(bool all)
{
  for(byte i=0; i<NUMBER_INPUT_PIN; i++)
  {
    byte pst = INPUT_PIN[i];
    byte vst = digitalRead(pst);
    if(vst != INPUT_STATE[pst]){
      INPUT_STATE[pst] = vst;
      if(vst == TRIGGER_STATE){
        bool isBypass = false, isEmergency = false;
        for(byte j=0; j<NUMBER_EMERGENCY_INPUT_PIN; j++){
          if(EMERGENCY_INPUT_PIN[j] == pst){
            if(EMERGENCY_INPUT_PIN[j] == pst){
              isEmergency = true;
              break;
            }
          }
        }
        if(isEmergency == true){
          alarm("EMERGENCY");
          continue;
        }
        for(byte j=0; j<NUMBER_INPUT_PIN; j++){
          if(BYPASS_ZONE[j] == pst){
            isBypass = true;
            break;
          }
        }
        if(isBypass == false){
          alarm("");
        }
      }else{
        for(byte j=0; j<NUMBER_INPUT_PIN; j++){
          if(BYPASS_ZONE[j] == pst){
            BYPASS_ZONE[j] = 0;
            break;
          }
        }
      }
      sendState(pst);
    }else if(all == true)
      sendState(pst);
  }
}




void sendState(byte pst)
{
  byte state = INPUT_STATE[pst];
  String strState = STATE[state];
  Serial.print("<"+String(BOARD_NAME)+","+String(pst)+","+strState+">");
}




void clearBypass()
{
  for(byte i=0; i<NUMBER_INPUT_PIN; i++)
  {
    BYPASS_ZONE[i] = 0;
  }
}



void arm(){
  ENTRY_DELAY = 0;
  START_ENTRY_DELAY = false;
  clearBypass();
  byte bzi = 0;
  for(byte i=0; i<NUMBER_INPUT_PIN; i++)
  {
    byte pst = INPUT_PIN[i];
    byte vst = digitalRead(pst);
    if(vst == TRIGGER_STATE){
      BYPASS_ZONE[bzi] = pst;
      bzi++;
    }
  }
}





void disarm(){
  ENTRY_DELAY = 0;
  START_ENTRY_DELAY = false;
  clearBypass();
  powerCycle();
  sirenOff();
}





void alarm(String type){
  if(type != "EMERGENCY"){
    sirenOn();
  }else{
    entryDelay();
  }
}





void entryDelay()
{
    if(START_ENTRY_DELAY == false){
        thoi_gian = 0;
        giay = 0;
        IN_ENTRY_DELAY = false;
        START_ENTRY_DELAY = true;
    }
}


void powerCycle(){

}


void sirenOn(){

}


void sirenOff(){
  
}







void timer()
{

    //entry delay
    if (START_ENTRY_DELAY == true && ((millis() - thoi_gian >= 1000) || (millis() - thoi_gian < 0)))
    {
        giay++;
        thoi_gian = millis();
        if (giay >= ENTRY_DELAY)
          sirenOn();
    }

}







void loop()
{

    if (Serial.available())
    {
        String input = Serial.readStringUntil('\n');
        dbg(input);
        String command[MAL];
        byte commandIndex = 0;
        int st = input.indexOf("<"), en = input.indexOf(">");
        while (en > st && st > -1)
        {
            command[commandIndex] = input.substring(st + 1, en);
            commandIndex++;
            st = input.indexOf("<", st + 1);
            en = input.indexOf(">", en + 1);
        }

        for (byte i = 0; i < commandIndex; i++)
        {

            String subCommand[MAL];
            byte separator[MAL];
            separator[0] = 0;
            byte subCommandIndex = 0, SI = 1;
            int si = command[i].indexOf(",");
            while (si > -1)
            {
                if (command[i].indexOf("{") == -1 || si < command[i].indexOf("{") || command[i].indexOf("}", si) == -1)
                {
                    separator[SI] = si;
                    SI++;
                }
                si = command[i].indexOf(",", si + 1);
            }
            separator[SI] = command[i].length();
            for (byte j = 0; j < SI; j++)
            {
                if (j == 0)
                {
                    subCommand[subCommandIndex] = command[i].substring(separator[j], separator[j + 1]);
                }
                else
                {
                    subCommand[subCommandIndex] = command[i].substring(separator[j] + 1, separator[j + 1]);
                }
                subCommandIndex++;
            }


            if (subCommandIndex == 1)
            {
                if (subCommand[0] == "CHECK_CONNECTION")
                {
                    Serial.print("<CHECK_CONNECTION,CONNECTED>");
                }
                else if (subCommand[0] == "GET_ALL")
                {
                    syncState(true);
                }
            }
            else if (subCommandIndex > 0)
            {
                for (byte ji = 0; ji < subCommandIndex; ji++){
                    dbg(subCommand[ji]);
                }
            }
            else
            {
                dbg("INVALID COMMAND");
            }
        }
    }
    else
    {
        syncState(false);
        timer();
    }
}
