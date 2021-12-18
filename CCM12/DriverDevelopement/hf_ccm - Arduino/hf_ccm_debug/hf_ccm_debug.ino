void setup(){
    Serial.begin(9600);
    while(!Serial)
        continue;
    delay(5000);
    Serial.println("<Hello from NANO>");
}

void loop(){
    if (Serial.available()){
        String input = Serial.readStringUntil('\n');
        delay(50);
        Serial.print(input);
    }
}
