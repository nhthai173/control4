/*
Sample data received from serial
<RCM64V1,DM,CON1,C1,OPEN>
*/

/*
This project uses ArduinoJson v6
Pinout for each board is fixed. Please declare in json
Please declare Analog pins as pins number
*/

#include <ArduinoJson.h>
//#define DEBUG false
bool DEBUG = true;
#define BOARD_NAME "RCM64V1"

//The maximum length of the array that contains the sub-elements
//after splitting the string received from serial
#define MAL 48

//Default delay time
#define DELAY_TIME 100

StaticJsonDocument<20000> doc;
StaticJsonDocument<1000> inputState;
char json[] = "{\"RCM64V1\":{\"PIN\":{\"OUTPUT\":[\"2\",\"3\",\"4\",\"5\",\"6\",\"7\",\"8\",\"9\",\"10\",\"11\",\"12\",\"13\",\"22\",\"23\",\"24\",\"25\",\"26\",\"27\",\"28\",\"29\",\"30\",\"31\",\"32\",\"33\",\"34\",\"35\",\"36\",\"37\",\"38\",\"39\",\"40\",\"41\",\"42\",\"43\",\"44\",\"45\",\"46\",\"47\",\"48\",\"49\",\"50\",\"51\",\"52\",\"53\",\"54\",\"55\",\"56\",\"57\"],\"OL\":\"48\"},\"DM\":{\"STATE\":{\"PIN\":\"2\",\"CLOSE\":[\"0\",\"0\"],\"STOP\":[\"0\",\"1\"],\"OPEN\":[\"1\",\"0\"],\"NONE\":[\"1\",\"1\"]},\"RULE\":{\"OPEN\":[\"0\",\"1\"],\"CLOSE\":[\"0\",\"1\"],\"STOP\":[\"0\",\"1\"],\"NONE\":[\"0\",\"1\"]},\"CON1\":{\"C1\":[\"31\",\"29\"],\"C2\":[\"33\",\"27\"],\"C3\":[\"35\",\"25\"],\"C4\":[\"37\",\"23\"],\"C5\":[\"39\",\"47\"],\"C6\":[\"41\",\"49\"],\"C7\":[\"43\",\"51\"],\"C8\":[\"45\",\"53\"]},\"CON3\":{\"C1\":[\"52\",\"22\"],\"C2\":[\"50\",\"24\"],\"C3\":[\"48\",\"26\"],\"C4\":[\"46\",\"28\"],\"C5\":[\"44\",\"30\"],\"C6\":[\"42\",\"32\"],\"C7\":[\"40\",\"34\"],\"C8\":[\"38\",\"36\"]},\"CON2\":{\"C1\":[\"5\",\"6\"],\"C2\":[\"4\",\"7\"],\"C3\":[\"3\",\"8\"],\"C4\":[\"2\",\"9\"],\"C5\":[\"54\",\"10\"],\"C6\":[\"55\",\"11\"],\"C7\":[\"56\",\"12\"],\"C8\":[\"57\",\"13\"]}},\"MM\":{\"STATE\":{\"PIN\":\"2\",\"OPEN\":[\"0\",\"0\"],\"CLOSE\":[\"1\",\"0\"],\"STOP\":[\"1\",\"1\"],\"NONE\":[\"1\",\"1\"]},\"RULE\":{\"DELAY\":\"100\",\"OPEN\":[\"0\",\"DELAY\",\"1\"],\"CLOSE\":[\"1\",\"DELAY\",\"0\"],\"STOP\":[\"1\",\"DELAY\",\"0\"],\"NONE\":[\"1\",\"DELAY\",\"0\"]},\"CON1\":{\"C1\":[\"31\",\"29\"],\"C2\":[\"33\",\"27\"],\"C3\":[\"35\",\"25\"],\"C4\":[\"37\",\"23\"],\"C5\":[\"39\",\"47\"],\"C6\":[\"41\",\"49\"],\"C7\":[\"43\",\"51\"],\"C8\":[\"45\",\"53\"]},\"CON3\":{\"C1\":[\"52\",\"22\"],\"C2\":[\"50\",\"24\"],\"C3\":[\"48\",\"26\"],\"C4\":[\"46\",\"28\"],\"C5\":[\"44\",\"30\"],\"C6\":[\"42\",\"32\"],\"C7\":[\"40\",\"34\"],\"C8\":[\"38\",\"36\"]},\"CON2\":{\"C1\":[\"5\",\"6\"],\"C2\":[\"4\",\"7\"],\"C3\":[\"3\",\"8\"],\"C4\":[\"2\",\"9\"],\"C5\":[\"54\",\"10\"],\"C6\":[\"55\",\"11\"],\"C7\":[\"56\",\"12\"],\"C8\":[\"57\",\"13\"]}}}}";

void setup() {
  Serial.begin(9600);
  while (!Serial) continue;
  delay(5000);

  //Check json valid
  DeserializationError error = deserializeJson(doc, json);
  if (error) {
    Serial.print(F("deserializeJson() failed: "));
    Serial.println(error.f_str());
    return;
  }
  
  dbg("---- READY ----");

  String ol = doc[BOARD_NAME]["PIN"]["OL"];
  for(int i=0; i<ol.toInt(); i++){
    String pinNum = doc[BOARD_NAME]["PIN"]["OUTPUT"][i];
    dbg("Output: "+pinNum);
    //pinMode(pinNum.toInt(), OUTPUT);
    //digitalWrite(pinNum.toInt(), 1);
    delay(DELAY_TIME);
  }

  String inputValid = doc[BOARD_NAME]["INPUT"];
  if(inputValid != "null"){
    String il = doc[BOARD_NAME]["PIN"]["IL"];
    for(int i=0; i<il.toInt(); i++){
      String pinNum = doc[BOARD_NAME]["PIN"]["INPUT"][i];
      dbg("Input: "+pinNum);
      //pinMode(pinNum.toInt(), INPUT_PULLUP);
      String pinLabel = doc[BOARD_NAME]["INPUT"][pinNum];
      inputState[pinLabel] = 0;
      sendToC4(pinLabel);
      delay(DELAY_TIME);
    }
    if(DEBUG == true){
      serializeJsonPretty(inputState, Serial);
    }
  }
  
}




void dbg(String content){
  if(DEBUG == true){
    Serial.println(content);
  }
}






void syncState(){
  /*
  String inputValid = doc[BOARD_NAME]["INPUT"];
  if(inputValid != "null"){
      String il = doc[BOARD_NAME]["PIN"]["IL"];
      for(int i=0; i<il.toInt(); i++){
        String pin = doc[BOARD_NAME]["PIN"]["INPUT"][i];
        String pinLabel = doc[BOARD_NAME]["INPUT"][pin];
        if(digitalRead(pin.toInt()) != inputState[pinLabel]){
          inputState[pinLabel] = digitalRead(pin.toInt());
          if(inputState[pinLabel] == HIGH)
            inputState[pinLabel] = 1;
          if(inputState[pinLabel] == LOW)
            inputState[pinLabel] = 0;
          sendToC4(pinLabel);
        }
      }
  }
  */
}






void sendToC4(String p){
  String stt = inputState[p];
  String stte = doc[BOARD_NAME]["INPUT"]["STATE"][stt];
  Serial.print("<" + String(BOARD_NAME) + "," + p + "," + stte + ">");
}









void loop() {
  
  if(Serial.available()){
    //unsigned long sttime = millis();
    String input = Serial.readString();
    dbg(input);
    String command[MAL];
    int commandIndex = 0, st = input.indexOf("<"), en = input.indexOf(">");

    //unsigned long stttime = millis();
    while(en > st && st > -1){
      command[commandIndex] = input.substring(st+1, en);
      commandIndex++;
      st = input.indexOf("<", st+1);
      en = input.indexOf(">", en+1);
    }
    
    for(int i=0; i<commandIndex; i++){
      String subCommand[MAL];
      int separator[MAL];
      separator[0] = 0;
      int subCommandIndex = 0, SI = 1, si = command[i].indexOf(",");
      while(si > -1){
        separator[SI] = si;
        SI++;
        si = command[i].indexOf(",", si+1);
      }
      separator[SI] = command[i].length();
      for(int j=0; j<SI; j++){
        if(j == 0){
          subCommand[subCommandIndex] = command[i].substring(separator[j], separator[j+1]);
        }else{
          subCommand[subCommandIndex] = command[i].substring(separator[j]+1, separator[j+1]);
        }
        subCommandIndex++;
      }
      if(subCommandIndex == 1 && subCommand[0] == "CHECK_CONNECTION"){
        Serial.print("<CHECK_CONNECTION,CONNECTED>");
      }else if(subCommandIndex == 5){
        String nop = doc[subCommand[0]][subCommand[1]]["STATE"]["PIN"];
        /*
        for(int j=0; j<nop.toInt(); j++){
          String pinNum = doc[subCommand[0]][subCommand[1]][subCommand[2]][subCommand[3]][j];
          String pinState = doc[subCommand[0]][subCommand[1]]["STATE"][subCommand[4]][j];
          if(pinNum != "null" && pinState != "null"){
            dbg("digitalWrite("+pinNum+", "+pinState+")");
            digitalWrite(pinNum.toInt(), pinState.toInt());
            delay(200);
          }
        }
        */
        String ruleDelay = doc[subCommand[0]][subCommand[1]]["RULE"]["DELAY"];
        for(int j=0; j<nop.toInt()+3; j++){
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
                //digitalWrite(pinNum.toInt(), pinState.toInt());
              }
            }
          }else{
            break;
          }
        }
      }else{
        Serial.println("INVALID COMMAND");
      }
    }
/*
    unsigned long endtime = millis();
    Serial.print("Start: ");
    Serial.println(sttime);
    Serial.print("Start computing: ");
    Serial.println(stttime);
    Serial.print("end: ");
    Serial.println(endtime);
    Serial.print("Total duration: ");
    Serial.println(endtime - sttime);
    Serial.print("Computing duration: ");
    Serial.println(endtime - stttime);
*/
  }


  syncState();
  
  }
