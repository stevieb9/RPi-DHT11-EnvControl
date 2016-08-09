#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"

#include <wiringPi.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#define false 0
#define true 1

#define MAXTIMINGS  85

typedef struct env_data {
    float temp;
    float humidity;
} EnvData;

EnvData read_env(int dht_pin);
float temp(int dht_pin);
float humidity(int dht_pin);
bool control(int pin, int state);
bool noboard_test(); // unit testing with no RPi board
void sanity();

EnvData read_env(int dht_pin){
    sanity();

    int dht11_dat[5] = {0, 0, 0, 0, 0};
    
    uint8_t laststate = HIGH;
    uint8_t counter = 0;
    uint8_t j = 0, i;
    float f; /* fahrenheit */

    dht11_dat[0] = dht11_dat[1] = dht11_dat[2] = dht11_dat[3] = dht11_dat[4] = 0;
    
    pinMode(dht_pin, OUTPUT);
    digitalWrite(dht_pin, LOW);
    delay(18);
    
    digitalWrite(dht_pin, HIGH);
    delayMicroseconds(40);
    
    pinMode(dht_pin, INPUT);

    for (i = 0; i < MAXTIMINGS; i++){
        counter = 0;
        while (digitalRead( dht_pin) == laststate){
            counter++;
            delayMicroseconds(1);
            if (counter == 255){
                break;
            }
        }
        laststate = digitalRead(dht_pin);

        if (counter == 255)
            break;

        if ( (i >= 4) && (i % 2 == 0)){
            dht11_dat[j / 8] <<= 1;
            if (counter > 16)
                dht11_dat[j / 8] |= 1;
            j++;
        }
    }

    EnvData env_data;

    if ((j >= 40) &&
         (dht11_dat[4] == ((dht11_dat[0] + dht11_dat[1] + dht11_dat[2] + dht11_dat[3]) & 0xFF)) && ! noboard_test()){
        f = dht11_dat[2] * 9. / 5. + 32;

        env_data.temp = f;
        env_data.humidity = (float)dht11_dat[0];

        /*
         * printf( "Humidity = %d.%d %% Temperature = %d.%d *C (%.1f *F)\n",
         * dht11_dat[0], dht11_dat[1], dht11_dat[2], dht11_dat[3], f );
         */
    }
    else {
        env_data.temp = 0.0;
        env_data.humidity = 0.0;
    }
    return env_data;
}

float temp(int dht_pin){
    // get & return temperature

    sanity();
    EnvData env_data;
    env_data = read_env(dht_pin);
    return env_data.temp;
}

float humidity(int dht_pin){
    // get & return humidity

    sanity();
    EnvData env_data;
    env_data = read_env(dht_pin);
    return env_data.humidity;
}

bool control(int pin, int state){
    // turn on/off the temp/humidity action pin
   
    sanity();
     
    bool ro = false;
    if (state == -1)
        ro = true;
    else
        state = (bool)state;

    if (noboard_test()){
        if (ro)
            return true;
        if (state)
            return true;
        else
            return false;
    }

    if (ro)
        return digitalRead(pin);

    pinMode(pin, OUTPUT);
    digitalWrite(pin, state);
    return digitalRead(pin);
}

int cleanup(int dht_pin, int temp_pin, int humidity_pin){
    // reset the pins to default status

    sanity();

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
    if (atoi(getenv("RDE_NOBOARD_TEST")) == 1)
        return true;
    return false;
}

void sanity(){
    if (! noboard_test()){
        if (wiringPiSetup() == -1)
            exit(1);
    }
}

MODULE = RPi::DHT11::EnvControl  PACKAGE = RPi::DHT11::EnvControl

PROTOTYPES: DISABLE

float
temp (dht_pin)
	int	dht_pin

float
humidity (dht_pin)
	int	dht_pin

bool
control (pin, state)
    int pin
    int state

int
cleanup (dht_pin, temp_pin, humidity_pin)
	int	dht_pin
	int	temp_pin
	int	humidity_pin

