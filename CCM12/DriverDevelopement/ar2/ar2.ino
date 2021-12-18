byte INPUT_PIN[] = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15};
byte INPUT_STATE[] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

void setup()
{
    Serial.begin(9600);
    while(!Serial) delay(50);
    for(int i=0; i<sizeof(INPUT_PIN); i++)
        pinMode(INPUT_PIN[i], INPUT_PULLUP);
}

void sync()
{
    for (int i = 0; i < sizeof(INPUT_PIN); i++)
    {   
        byte pin = INPUT_PIN[i];
        byte st = digitalRead(pin);
        if(st != INPUT_STATE[pin])
        {
            INPUT_STATE[pin] = st;
            Serial.print(pin);
            Serial.print(" - ");
            Serial.println(st);
        }
    }
}

void loop()
{
    sync();
}
