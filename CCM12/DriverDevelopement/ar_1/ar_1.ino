bool DEBUG = true;

#define BOARD_NAME "CCM12V1"
String STATE[2] = {"OPEN", "CLOSE"};

//#define NUMBER_INPUT_PIN 14
#define NUMBER_INPUT_PIN 13
//byte INPUT_PIN[NUMBER_INPUT_PIN] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};
byte INPUT_PIN[NUMBER_INPUT_PIN] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15};
byte INPUT_STATE[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
//byte INPUT_STATE[] = {LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW, LOW};

void dbg(String str){
    if(DEBUG == true)
        Serial.println(str);
}

void sendState(byte pinNum){
    byte state = INPUT_STATE[pinNum];
    String strState = STATE[state];
    Serial.print("<" + String(BOARD_NAME) + "," + String(pinNum) + "," + strState + ">\n");
}

void syncStateLite(){
    for(byte i=0; i<NUMBER_INPUT_PIN; i++){
        byte pin = INPUT_PIN[i];
        if(digitalRead(pin) != INPUT_STATE[pin]){
            INPUT_STATE[pin] = !INPUT_STATE[pin];
            sendState(pin);
        }
    }
}

void setup(){
    Serial.begin(9600);
    while (!Serial)
        continue;
    if (DEBUG == true)
        delay(5000);

    for(byte i=0; i<NUMBER_INPUT_PIN; i++){
        pinMode(INPUT_PIN[i], INPUT_PULLUP);
        dbg("Input:" + String(INPUT_PIN[i]));
    }
}


void loop(){
    syncStateLite();
}
