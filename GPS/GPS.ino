#include <TinyGPS++.h>
#include <SoftwareSerial.h>

static const int RXPin = 4, TXPin = 3;
static const uint32_t GPSBaud = 9600; // Ubah jika perlu

TinyGPSPlus gps;
SoftwareSerial ss(RXPin, TXPin);

const int timezoneOffset = 7;

void setup()
{
  Serial.begin(115200);
  ss.begin(GPSBaud);

  Serial.println(F("DeviceExample.ino"));
  Serial.println(F("A simple demonstration of TinyGPS++ with an attached GPS module"));
  Serial.print(F("Testing TinyGPS++ library v. ")); Serial.println(TinyGPSPlus::libraryVersion());
  Serial.println();
}

void loop()
{
  while (ss.available() > 0)
  {
    char c = ss.read();
    Serial.print(c); // Debugging: tampilkan data mentah GPS
    if (gps.encode(c))
      displayInfo();
  }

  if (millis() > 5000 && gps.charsProcessed() < 10)
  {
    Serial.println(F("No GPS detected: check wiring."));
    while(true);
  }
}

void displayInfo()
{
  Serial.print(F("Location: ")); 
  if (gps.location.isValid())
  {
    Serial.print(gps.location.lat(), 6);
    Serial.print(F(","));
    Serial.print(gps.location.lng(), 6);
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.print(F("  Date/Time: "));
  if (gps.date.isValid() && gps.time.isValid())
  {
    int localHour = gps.time.hour() + timezoneOffset;
    int localMinute = gps.time.minute();
    int localSecond = gps.time.second();
    
    // Adjust the hour for overflow
    if (localHour >= 24) {
      localHour -= 24;

      int day = gps.date.day();
      int month = gps.date.month();
      int year = gps.date.year();
      
      day += 1;
      
      // Handle days in a month
      if ((month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10) && day == 31) {
        day = 1;
        month += 1;
      } else if ((month == 4 || month == 6 || month == 9 || month == 11) && day == 30) {
        day = 1;
        month += 1;
      } else if (month == 2) {
        // Check for leap year
        if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
          if (day == 29) {
            day = 1;
            month += 1;
          }
        } else {
          if (day == 28) {
            day = 1;
            month += 1;
          }
        }
      } else if (month == 12 && day == 31) {
        day = 1;
        month = 1;
        year += 1;
      }

      Serial.print(month);
      Serial.print(F("/"));
      Serial.print(day);
      Serial.print(F("/"));
      Serial.print(year);
    } else {
      Serial.print(gps.date.month());
      Serial.print(F("/"));
      Serial.print(gps.date.day());
      Serial.print(F("/"));
      Serial.print(gps.date.year());
    }

    // Print the time
    Serial.print(F(" "));
    if (localHour < 10) Serial.print(F("0"));
    Serial.print(localHour);
    Serial.print(F(":"));
    if (localMinute < 10) Serial.print(F("0"));
    Serial.print(localMinute);
    Serial.print(F(":"));
    if (localSecond < 10) Serial.print(F("0"));
    Serial.print(localSecond);
    Serial.print(F("."));
    if (gps.time.centisecond() < 10) Serial.print(F("0"));
    Serial.print(gps.time.centisecond());
  }
  else
  {
    Serial.print(F("INVALID"));
  }

  Serial.println();
}