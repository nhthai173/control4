/*
This project uses ArduinoJson v6
Pinout for each board is fixed. Please declare in json
Please declare Analog pins as pins number
*/

#include <ArduinoJson.h>
//#define DEBUG false
bool DEBUG = false;
#define BOARD_NAME "CCM12V1"

//The maximum length of the array that contains the sub-elements
//after splitting the string received from serial
#define MAL 64

//Default delay time
#define DELAY_TIME 100

StaticJsonDocument<800> doc;
DynamicJsonDocument inputState(100);
char json[] = "{\"CCM12V1\":{\"INPUT\":{\"5\":\"ZONE1\",\"6\":\"ZONE2\",\"7\":\"ZONE3\",\"8\":\"ZONE4\",\"9\":\"ZONE5\",\"10\":\"ZONE6\",\"11\":\"ZONE7\",\"12\":\"ZONE8\",\"13\":\"ZONE9\",\"14\":\"ZONE10\",\"15\":\"ZONE11\",\"16\":\"ZONE12\",\"PIN\":[\"5\",\"6\",\"7\",\"8\",\"9\",\"10\",\"11\",\"12\",\"13\",\"14\",\"15\",\"16\"],\"STATE\":{\"0\":\"CLOSE\",\"1\":\"OPEN\"}},\"OUTPUT\":{\"LEVEL1\":{\"STATE\":{\"ON\":\"0\",\"OFF\":\"1\"},\"DURATION\":\"200\",\"PIN\":[\"19\"]},\"LEVEL2\":{\"STATE\":{\"ON\":\"0\",\"OFF\":\"1\"},\"PIN\":[\"20\"]}}}}";

void setup() {
  Serial.begin(9600);
  //  while (!Serial) continue;
  //delay(5000);

  //Check json valid
  DeserializationError error = deserializeJson(doc, json);
  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }
  
  dbg("---- READY ----");

  String in = doc[BOARD_NAME]["INPUT"]["PIN"];
  if(in != "null"){
    byte ini = 0;
    while(1){
      String inp = doc[BOARD_NAME]["INPUT"]["PIN"][ini];
      if(inp != "null"){
        dbg("Input: " + inp);
        pinMode(inp.toInt(), INPUT_PULLUP);
        String pinLabel = doc[BOARD_NAME]["INPUT"][inp];
        inputState[pinLabel] = 0;
        sendToC4(pinLabel);
        ini++;
      }else{
        break;
      }
    }
    // sendToC4(pinLabel);
    if (DEBUG == true){
      serializeJsonPretty(inputState, Serial);
    }
  }

  String ou = doc[BOARD_NAME]["OUTPUT"];
  if(ou != "null"){
    byte oui = 0;
    while(1){
      String oup1 = doc[BOARD_NAME]["OUTPUT"]["LEVEL1"]["PIN"][oui];
      String oup2 = doc[BOARD_NAME]["OUTPUT"]["LEVEL2"]["PIN"][oui];
      if(oup1 != "null" || oup2 != "null"){
        if(oup1 != "null"){
          dbg("Output: " + oup1);
          pinMode(oup1.toInt(), OUTPUT);
          digitalWrite(oup1.toInt(), 1);
        }
        if(oup2 != "null"){
          dbg("Output: " + oup2);
          pinMode(oup2.toInt(), OUTPUT);
          digitalWrite(oup2.toInt(), 1);
        }
        oui++;
      }else{
        break;
      }
    }
  }

}




void dbg(String content){
  if(DEBUG == true){
    Serial.println(content);
  }
}






void syncState(){
  String inputValid = doc[BOARD_NAME]["INPUT"]["PIN"];
  if(inputValid != "null"){
    byte ini = 0;
    while(1){
      String inp = doc[BOARD_NAME]["INPUT"]["PIN"][ini];
      if(inp != "null"){
        String pinLabel = doc[BOARD_NAME]["INPUT"][inp];
        if(digitalRead(inp.toInt()) != inputState[pinLabel]){
          inputState[pinLabel] = digitalRead(inp.toInt());
          if(inputState[pinLabel] == HIGH)
            inputState[pinLabel] = 1;
          if(inputState[pinLabel] == LOW)
            inputState[pinLabel] = 0;
          sendToC4(pinLabel);
        }
        ini++;
      }else{
        break;
      }
    }
    // sendToC4();
  }
}





void getAllState(){
  String inputValid = doc[BOARD_NAME]["INPUT"]["PIN"];
  if(inputValid != "null"){
    byte ini = 0;
    while(1){
      String inp = doc[BOARD_NAME]["INPUT"]["PIN"][ini];
      if(inp != "null"){
        String pinLabel = doc[BOARD_NAME]["INPUT"][inp];
        sendToC4(pinLabel);
        ini++;
      }else{
        break;
      }
    }
    // sendToC4();
  }
}








void sendToC4(String p){
  String stt = inputState[p];
  String stte = doc[BOARD_NAME]["INPUT"]["STATE"][stt];
  Serial.print("<" + String(BOARD_NAME) + "," + p + "," + stte + ">");
}









void loop() {
  
  if(Serial.available()){
    String input = Serial.readStringUntil('\n');
    dbg(input);
    String command[MAL];
    byte commandIndex = 0;
    int st = input.indexOf("<"), en = input.indexOf(">");
    while(en > st && st > -1){
      command[commandIndex] = input.substring(st+1, en);
      commandIndex++;
      st = input.indexOf("<", st+1);
      en = input.indexOf(">", en+1);
    }
    
    for(byte i=0; i<commandIndex; i++){
            
      String subCommand[MAL];
      byte separator[MAL];
      separator[0] = 0;
      byte subCommandIndex = 0, SI = 1;
      int si = command[i].indexOf(",");
      while(si > -1){
        if(command[i].indexOf("{") == -1 || si < command[i].indexOf("{") || command[i].indexOf("}", si) == -1){
          separator[SI] = si;
          SI++;
        }
        si = command[i].indexOf(",", si+1);
      }
      separator[SI] = command[i].length();
      for(byte j=0; j<SI; j++){
        if(j == 0){
          subCommand[subCommandIndex] = command[i].substring(separator[j], separator[j+1]);
        }else{
          subCommand[subCommandIndex] = command[i].substring(separator[j]+1, separator[j+1]);
        }
        subCommandIndex++;
      }
      if(subCommandIndex == 1){
        if(subCommand[0] == "CHECK_CONNECTION"){
          Serial.print("<CHECK_CONNECTION,CONNECTED>");
        }else if(subCommand[0] == "GET_ALL"){
          getAllState();
        }
      }else if(subCommandIndex == 5){
        String nop = doc[subCommand[0]][subCommand[1]]["STATE"]["PIN"];
        String ruleDelay = doc[subCommand[0]][subCommand[1]]["RULE"]["DELAY"];
        for(byte j=0; j<nop.toInt()+3; j++){
          String rule = doc[subCommand[0]][subCommand[1]]["RULE"][subCommand[4]][j];
          if(rule != "null"){
            if(rule == "DELAY"){
              //delay(ruleDelay.toInt());
              delay(DELAY_TIME);
            }else{
              String pinNum = doc[subCommand[0]][subCommand[1]][subCommand[2]][subCommand[3]][rule.toInt()];
              String pinState = doc[subCommand[0]][subCommand[1]]["STATE"][subCommand[4]][rule.toInt()];
              if(pinNum != "null" && pinState != "null"){
                dbg("digitalWrite("+pinNum+", "+pinState+")");
                //dbg(subCommand[2]+subCommand[3]+subCommand[4]);
                digitalWrite(pinNum.toInt(), pinState.toInt());
              }
            }
          }else{
            break;
          }
        }
      }else{
        dbg("INVALID COMMAND");
      }
    }
    
  }else{

    syncState();

  }
  
}
