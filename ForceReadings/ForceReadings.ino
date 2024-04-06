#include "HX711.h"

#define DOUT  3
#define CLK  2

HX711 scale;


float calibration_factor = -387;
float current_reading;

void setup() {
  Serial.begin(115200);
  scale.begin(DOUT, CLK);
  scale.set_scale();
  scale.tare();
}

float runningAverage(float M) {
  #define LM_SIZE 3
  static float LM[LM_SIZE];
  static byte index = 0;
  static float sum = 0;
  static byte count = 0;

  sum -= LM[index];
  LM[index] = M;
  sum += LM[index];
  index++;
  index = index % LM_SIZE;
  if (count < LM_SIZE) count++;

  return sum / count;
}

void loop() {

  scale.set_scale(calibration_factor);
  current_reading = (scale.get_units());
  Serial.println(-runningAverage(current_reading)*9.81/1000.0,4); // Output compressive force in N
  delay(500);

}
