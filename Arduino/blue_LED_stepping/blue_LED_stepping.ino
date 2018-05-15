
/*
  FPM code
*/
//Adapted from examples from Adafruit
#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library

//setting range of LED's to use and the color
int xmax;
int centerx = 16, centery = 15, ymax = xmax, xmin = 0, ymin = 0, hue = 0, x, y;
// centerx and centery 16,15 is correct
char r, g, b;
int xstart; // = centerx - ((xmax - 1) / 2), xend = centerx + ((xmax - 1) / 2), ystart = centery - ((ymax - 1) / 2), yend = centery + ((ymax - 1) / 2);
int xend;
int ystart;
int yend;
int total; // = (xmax - xmin) * (ymax - ymin), 
int counter = 1;
int strtcnt = 1;

#define CLK 8
#define OE  9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2
#define D   A3

RGBmatrixPanel matrix(A, B, C, D, CLK, LAT, OE, false);
//define the characters sent by matlab
int matCOM = 0;

void setup() {


  Serial.begin(9600);
  matrix.begin();
  matrix.drawPixel(centerx, centery, matrix.Color333(7, 0, 0));
  Serial.println('a');
  char a = 'b';
  while (a != 'a')
  {
    a = Serial.read();
  }
   matrix.drawPixel(centerx,centery,matrix.Color333(7, 7, 7));
   delay(7000)
   matrix.drawPixel(centerx,centery,matrix.Color333(0, 0, 0));
  while (Serial.available() == 0) {}
  r = (Serial.read() - 48);
  Serial.println(r);
  while (Serial.available() == 0) {}
  g = (Serial.read() - 48);
  Serial.println(g);
  while (Serial.available() == 0) {}
  b = (Serial.read() - 48);
  Serial.println(b);
  while(Serial.available() == 0) {}
     xmax=Serial.read();
      Serial.println(xmax);


  ymax = xmax;
  xstart = centerx-((xmax-1)/2), xend = centerx+((xmax-1)/2), ystart = centery-((ymax-1)/2), yend = centery+((ymax-1)/2);
  total = (xmax-xmin)*(ymax-ymin);


  matrix.drawPixel(centerx, centery, matrix.Color333(r, g, b));
}

// the loop routine runs over and over again until satisfied:
void loop() {
  x = 0;
  y = -1;
  while (counter <= total) {
    if (Serial.available() > 0)
    {
      matCOM = Serial.read();
      if (matCOM == '1')
      {

        triggerNextLed();
      //if (strtcnt ==1 )
       //{
       //delay(1000);
       //strtcnt = 2;
       // 
       //}
        matrix.drawPixel(xstart + x, ystart + y, matrix.Color333(r, g, b));
        Serial.println("2");
        //      Serial.println(x);
        //      Serial.println(y);
        //      Serial.println("Send 1 when ready");
      }
    }
  }
}


int triggerNextLed() {
  matrix.fillRect(xstart, ystart, xmax, ymax, matrix.Color333(0, 0, 0));
  if (y == ymax - 1) {
    x = x + 1;
    y = 0;
  }
  else {
    y = y + 1;
  }
  if (x > xmax - 1) {
    x = 0;
    y = 0;
  }
  return x, y;
}
