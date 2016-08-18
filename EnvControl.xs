#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <wiringPi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define false 0
#define true 1

#define MAXTIMINGS  85

typedef struct env_data {
    int temp;
    int humidity;
} EnvData;

EnvData read_env(int dht_pin);
int c_temp(int dht_pin);
int c_humidity(int dht_pin);
bool c_status(int pin);
bool c_control(int pin, int state);
int c_cleanup(int dht_pin, int temp_pin, int humidity_pin);

bool noboard_test(); // unit testing with no RPi board
bool sanity();

EnvData read_env(int dht_pin){
    int data[5] = {0, 0, 0, 0, 0};
    
    uint8_t laststate = HIGH;
    uint8_t counter = 0;
    uint8_t j = 0, i;

    data[0] = data[1] = data[2] = data[3] = data[4] = 0;
    
    pinMode(dht_pin, OUTPUT);
    digitalWrite(dht_pin, LOW);
    delay(18);
    
    digitalWrite(dht_pin, HIGH);
    delayMicroseconds(40);
    
    pinMode(dht_pin, INPUT);

    for (i = 0; i < MAXTIMINGS; i++){
        counter = 0;
        while (digitalRead(dht_pin) == laststate){
            counter++;
            delayMicroseconds(1);
            if (counter == 255){
                break;
            }
        }
        laststate = digitalRead(dht_pin);

        if (counter == 255)
            break;

        if ((i >= 4) && (i % 2 == 0)){
            data[j / 8] <<= 1;
            if (counter > 16)
                data[j / 8] |= 1;
            j++;
        }
    }

    EnvData env_data;
    
    if ((j >= 40) &&
         (data[4] == ((data[0] + data[1] + data[2] + data[3]) & 0xFF))){

         // printf( "Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",
         //       data[0], data[1], data[2], data[3], f );

        int t = data[2];
        int h = data[0];

        env_data.temp = t;
        env_data.humidity = h;
    }
    else {
        env_data.temp = -1;
        env_data.humidity = -1;
    }
    return env_data;
}

int c_temp(int dht_pin){
    // get & return temperature

    if (noboard_test())
        return 0;

    EnvData env_data;
    int data = -1;

    while (data == -1 && data != 0){
        env_data = read_env(dht_pin);
        data = env_data.temp;
    }
    return env_data.temp;
}

int c_humidity(int dht_pin){
    // get & return humidity

    if (noboard_test())
        return 0;

    EnvData env_data;
    int data = -1;

    while (data == -1 && data != 0){
        env_data = read_env(dht_pin);
        data = env_data.humidity;
    }
    return env_data.humidity;
}

bool c_status(int pin){
    // get the status of a pin

    if (noboard_test())
        return false;

    return digitalRead(pin);
}

bool c_control(int pin, int state){
    // turn on/off the temp/humidity action pin
     
    if (noboard_test()){
        if (state)
            return true;
        else
            return false;
    }

    pinMode(pin, OUTPUT);
    digitalWrite(pin, state);
    return digitalRead(pin);
}

int c_cleanup(int dht_pin, int temp_pin, int humidity_pin){
    // reset the pins to default status

    digitalWrite(dht_pin, LOW);
    pinMode(dht_pin, INPUT);

    if (temp_pin > -1){
        digitalWrite(temp_pin, LOW);
        pinMode(temp_pin, INPUT);
    }
    if (humidity_pin > -1){
        digitalWrite(humidity_pin, LOW);
        pinMode(humidity_pin, INPUT);
    }
    return(0);
}

bool noboard_test(){
    if (getenv("RDE_NOBOARD_TEST") && atoi(getenv("RDE_NOBOARD_TEST")) == 1)
        return true;
    return false;
}

bool sanity(){
    if (! noboard_test()){
        if (wiringPiSetup() == -1)
            exit(1);
    }
    return true;
}

MODULE = RPi::DHT11::EnvControl  PACKAGE = RPi::DHT11::EnvControl

PROTOTYPES: DISABLE

int
c_temp (dht_pin)
	int	dht_pin

int
c_humidity (dht_pin)
	int	dht_pin

bool
c_status (pin)
    int pin

bool
c_control (pin, state)
    int pin
    int state

int
c_cleanup (dht_pin, temp_pin, humidity_pin)
	int	dht_pin
	int	temp_pin
	int	humidity_pin

bool
sanity()
