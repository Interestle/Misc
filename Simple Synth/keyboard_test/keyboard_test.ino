/*
 * This is a simple test program for using my shift-register push-button keyboard.
 * It simply prints whatever is being pressed on the keyboard.
 */

/* Pins */
int p_load = 4;
int clk    = 5;
int clk_en = 6;
int Q7     = 7; 
int nQ7    = 8;


void setup() {
  Serial.begin(115200);

  pinMode(p_load, OUTPUT);
  pinMode(clk, OUTPUT);
  pinMode(clk_en, OUTPUT);
  pinMode(Q7, INPUT);
  pinMode(nQ7, INPUT);

}

void loop() {
  tone(12, 440);
  digitalWrite(p_load, LOW);
  delayMicroseconds(5);
  digitalWrite(p_load, HIGH);
  delayMicroseconds(5);

  digitalWrite(clk, HIGH);
  digitalWrite(clk_en, LOW);
  uint16_t data = (shiftIn(nQ7, clk, MSBFIRST) << 8) | shiftIn(nQ7, clk, MSBFIRST);
  data &= 0x1FFF; 
  digitalWrite(clk_en, HIGH);

  Serial.print("Pins: \r\n");
  Serial.println(data, HEX);
  delay(100);
}
