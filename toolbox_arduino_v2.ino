/* This file is initially based on Matlab project  */

/* This file is meant to be used with the SCILAB arduino  
   toolbox, however, it can be used from the IDE environment
   (or any other serial terminal) by typing commands like:
   
   0e0   : assigns digital pin #4 (e) as input
   0f1   : assigns digital pin #5 (f) as output
   0n1   : assigns digital pin #13 (n) as output   
   
   1c    : reads digital pin #2 (c) 
   1e    : reads digital pin #4 (e) 
   2n0   : sets digital pin #13 (n) low
   2n1   : sets digital pin #13 (n) high
   2f1   : sets digital pin #5 (f) high
   2f0   : sets digital pin #5 (f) low
   4j2   : sets analog pin #9 (j) to  50=ascii(2) over 255
   4jz   : sets analog pin #9 (j) to 122=ascii(z) over 255
   3a    : reads analog pin #0 (a) 
   3f    : reads analog pin #5 (f) 

   5a    : reads status (attached/detached) of servo #1
   5b    : reads status (attached/detached) of servo #2
   6a1   : attaches servo #1
   8az   : moves servo #1 of 122 degrees (122=ascii(z))
   7a    : reads servo #1 angle
   6a0   : detaches servo #1

  
   Generic DC_Motor
   9ijkl : setup for generic DCmotor number i (1 to 4), PW1 on pin number j, PWM2 or direction on pin number k, mode=l
           k=0 for L293 (2 PWM) and k=1 for L298 (1PWM + 1 bit for direction)
   Aijk  : sets speed for generic DCmotor number i, j=0/1 for direction, k=ascii(0) .. ascii(255)
   Bir   : releases motor i (r=release)

   Generic Interrupt counter
   Eai   : activate counter on INT number i (i=ascii(2 or 3 or 18 or 19 or 20 or 21)
   Eri   : release counter on INT number i
   Epi   : read counter on INT number i
   Ezi   : reset counter on INT number i

   Generic Encoder
   Fajkl: activate encoder on channelA on INT number j (j=ascii(2 or 3 or 18 or 19 or 20 or 21) et channelB on pin k or INT number k (k=ascii(0)..ascii(53))
           and l=1 or 2 or 4 for 1x mode (count every rising of chA) or 2x mode (count every change statement of chA)
           or  4x mode (every change statement of chA et chB)
   Fri   : release encoder on INTi
   Fpi   : read position of encoder on INTi
   Fzi   : reset value of encoder on INTi position
   
   R0    : sets analog reference to DEFAULT
   R1    : sets analog reference to INTERNAL
   R2    : sets analog reference to EXTERNAL

   99 or 91 : returns script type (1 basic, 2 motor, 3 general)
           Ok for Adafruit DCshield matlab default (shield type 1)
   92    : setup for REV3 DCshield (shield type 2) - needed before motors control.  
   */

#include <Servo.h>

/* define internal for the MEGA as 1.1V (as as for the 328)  */
#if defined(__AVR_ATmega1280__) || defined(__AVR_ATmega2560__)
#define INTERNAL INTERNAL1V1
#endif

/* create and initialize servos                              */
Servo servo1;
Servo servo2;


/* Generic motors */
int dcm1_pin1,dcm1_pin2,dcm1_mode;
int dcm2_pin1,dcm2_pin2,dcm2_mode;
int dcm3_pin1,dcm3_pin2,dcm3_mode;
int dcm4_pin1,dcm4_pin2,dcm4_mode;


// Generic encoder 
/* Encoders initialisation */
// volatile declare as those variables will change in interrupts
volatile long int encoder_0_position = 0,encoder_1_position = 0, encoder_2_position = 0, encoder_3_position = 0, encoder_4_position = 0, encoder_5_position = 0;
int encoder_0_int2 ;          // Pin used for encoder0 chanel B : define from scilab
int encoder_1_int2 ;          // Pin used for encoder1 chanel B : define from scilab
int encoder_2_int2 ;          // Pin used for encoder2 chanel B : define from scilab
int encoder_3_int2 ;          // Pin used for encoder3 chanel B : define from scilab
int encoder_4_int2 ;          // Pin used for encoder4 chanel B : define from scilab
int encoder_5_int2 ;          // Pin used for encoder5 chanel B : define from scilab
int encoder_num, encoder_int2;
int corresp[6]={2,3,21,20,19,18}; //Correspondance beetween interrupt number and pin number

//Generic counter
volatile long int counter_0=0,counter_1=0,counter_2=0,counter_3=0,counter_4=0,counter_5=0;

void setup() {
  /* initialize serial                                       */
  Serial.begin(115200);
}

void loop() {
  
  /* variables declaration and initialization                */
  
  static int  s   = -1;    /* state                          */
  static int  pin = 13;    /* generic pin number             */
  static int  srv =  2;    /* generic servo number           */
  static int  dcm =  4;    /* generic dc motor number        */

  static int  stm =  2;    /* generic stepper motor number   */
  static int  dir =  0;    /* direction (stepper)            */
  static int  sty =  0;    /* style (stepper)                */

  int  val =  0;           /* generic value read from serial */
  int  agv =  0;           /* generic analog value           */
  int  dgv =  0;           /* generic digital value          */
  static int  enc   = 1;    /* encoder number 1 (or 2 for Arduino mega)     */
 
  /* The following instruction constantly checks if anything 
     is available on the serial port. Nothing gets executed in 
     the loop if nothing is available to be read, but as soon 
     as anything becomes available, then the part coded after 
     the if statement (that is the real stuff) gets executed */

  if (Serial.available() >0) {
    
    /* whatever is available from the serial is read here    */
    val = Serial.read(); 
    
    /* This part basically implements a state machine that 
       reads the serial port and makes just one transition 
       to a new state, depending on both the previous state 
       and the command that is read from the serial port. 
       Some commands need additional inputs from the serial 
       port, so they need 2 or 3 state transitions (each one
       happening as soon as anything new is available from 
       the serial port) to be fully executed. After a command 
       is fully executed the state returns to its initial 
       value s=-1                                            */

    switch (s) {
      
      /* s=-1 means NOTHING RECEIVED YET ******************* */
      case -1:      

      /* calculate next state when s=-1                      */
      if (val>47 && val<90) {
           /* the first received value indicates the mode       
           49 is ascii for 1, ... 90 is ascii for Z          
           s=0 is change-pin mode
           s=10 is DI;  s=20 is DO;  s=30 is AI;  s=40 is AO; 
           s=50 is servo status; s=60 is aervo attach/detach;  
           s=70 is servo read;   s=80 is servo write         
           s=90 is query script type (1 basic, 2 motor, 3 general)
           s=170 is dc motor set speed 
           s=180 is dc motor run/release         
           s=190 is stepper motor set speed 
           s=200 is stepper motor run/release 
           s=210 is encoder 4x : chA on pin2, chB on pin3
           s=220 is generic encoder        
           s=340 is change analog reference         
                                                             */
        s=10*(val-48);
      }
      
      /* the following statements are needed to handle 
         unexpected first values coming from the serial (if 
         the value is unrecognized then it defaults to s=-1) */
      if ((s>90 && s<170) || (s>222 && s!=340)) {
        s=-1;
      }
      
      /* the break statements gets out of the switch-case, so 
      /* we go back to line 97 and wait for new serial data  */
      break; /* s=-1 (initial state) taken care of           */


     
      /* s=0 or 1 means CHANGE PIN MODE                      */
      
      case 0:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('t')=116, pin 19    */
      if (val>98 && val<117) {
        pin=val-97;                /* calculate pin          */
        s=1; /* next we will need to get 0 or 1 from serial  */
      } 
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=0 taken care of                            */


      case 1:
      /* the third received value indicates the value 0 or 1 */ 
      if (val>47 && val<50) {
        /* set pin mode                                      */
        if (val==48) {
          pinMode(pin,INPUT);
        }
        else {
          pinMode(pin,OUTPUT);
        }
      }
      s=-1;  /* we are done with CHANGE PIN so go to -1      */
      break; /* s=1 taken care of                            */
      


      /* s=10 means DIGITAL INPUT ************************** */
      
      case 10:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('t')=116, pin 19    */
      if (val>98 && val<117) {
        pin=val-97;                /* calculate pin          */
        dgv=digitalRead(pin);      /* perform Digital Input  */
        //Serial.println(dgv);     /* send value via serial  */
        Serial.print(dgv);         /* send 0 or 1 without new lign */
       }
      s=-1;  /* we are done with DI so next state is -1      */
      break; /* s=10 taken care of                           */
      


      /* s=20 or 21 means DIGITAL OUTPUT ******************* */
      
      case 20:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('t')=116, pin 19    */
      if (val>98 && val<117) {
        pin=val-97;                /* calculate pin          */
        s=21; /* next we will need to get 0 or 1 from serial */
      } 
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=20 taken care of                           */

      case 21:
      /* the third received value indicates the value 0 or 1 */ 
      if (val>47 && val<50) {
        dgv=val-48;                /* calculate value        */
	    digitalWrite(pin,dgv);     /* perform Digital Output */
      }
      s=-1;  /* we are done with DO so next state is -1      */
      break; /* s=21 taken care of                           */


	
      /* s=30 means ANALOG INPUT *************************** */
      
      case 30:
      /* the second received value indicates the pin 
         from abs('a')=97, pin 0, to abs('f')=113, pin 15,    
         note that these are the digital pins from 14 to 19  
         located in the lower right part of the board        */
      if (val>96 && val<113) {
        pin=val-97;                /* calculate pin          */
        agv=analogRead(pin);       /* perform Analog Input   */
	    //Serial.println(agv);       /* send value via serial  */
            Serial.write((uint8_t*)&agv,2);
      }
      s=-1;  /* we are done with AI so next state is -1      */
      break; /* s=30 taken care of                           */

	

      /* s=40 or 41 means ANALOG OUTPUT ******************** */
      
      case 40:
      /* the second received value indicates the pin 
         from abs('c')=99, pin 2, to abs('t')=116, pin 19    */
      if (val>98 && val<117) {
        pin=val-97;                /* calculate pin          */
        s=41; /* next we will need to get value from serial  */
      }
      else {
        s=-1; /* if value is not a pin then return to -1     */
      }
      break; /* s=40 taken care of                           */


      case 41:
      /* the third received value indicates the analog value */ 
      analogWrite(pin,val);        /* perform Analog Output  */
      s=-1;  /* we are done with AO so next state is -1      */
      break; /* s=41 taken care of                           */


      
      /* s=50 means SERVO STATUS (ATTACHED/DETACHED) ******* */
      
      case 50:
      /* the second received value indicates the servo number
         from abs('a')=97, servo1, on top, uses digital pin 10
         to abs('b')=98, servo2, bottom, uses digital pin 9  */
      if (val>96 && val<99) {
        srv=val-96;                /* calculate srv          */
        if (srv==1) dgv=servo1.attached();    /* read status */
        if (srv==2) dgv=servo2.attached(); 
        //Serial.println(dgv);       /* send value via serial  */
      }
      s=-1;  /* we are done with servo status so return to -1*/
      break; /* s=50 taken care of                           */
      


      /* s=60 or 61 means SERVO ATTACH/DETACH ************** */
      
      case 60:
      /* the second received value indicates the servo number
         from abs('a')=97, servo1, on top, uses digital pin 10
         to abs('b')=98, servo2, bottom, uses digital pin 9  */
      if (val>96 && val<99) {
        srv=val-96;                /* calculate srv          */
        s=61; /* next we will need to get 0 or 1 from serial */
      } 
      else {
        s=-1; /* if value is not a servo then return to -1   */
      }
      break; /* s=60 taken care of                           */


      case 61:
      /* the third received value indicates the value 0 or 1 
         0 for detach and 1 for attach                       */ 
      if (val>47 && val<50) {
        dgv=val-48;                /* calculate value        */
        //Serial.println(dgv);
        if (srv==1) {
          if (dgv) servo1.attach(10);      /* attach servo 1 */
          else servo1.detach();            /* detach servo 1 */
        }
        if (srv==2) {
          if (dgv) servo2.attach(9);       /* attach servo 2 */
          else servo2.detach();            /* detach servo 2 */
        }
      }
      s=-1;  /* we are done with servo attach/detach so -1   */
      break; /* s=61 taken care of                           */



      /* s=70 means SERVO READ ***************************** */
      
      case 70:
      /* the second received value indicates the servo number
         from abs('a')=97, servo1, on top, uses digital pin 10
         to abs('b')=98, servo2, bottom, uses digital pin 9  */
      if (val>96 && val<99) {
        srv=val-96;                /* calculate servo number */
        if (srv==1) agv=servo1.read();         /* read value */
        if (srv==2) agv=servo2.read();  
	Serial.println(agv);       /* send value via serial  */
      }
      s=-1;  /* we are done with servo read so go to -1 next */
      break; /* s=70 taken care of                           */



      /* s=80 or 81 means SERVO WRITE   ******************** */
      
      case 80:
      /* the second received value indicates the servo number
         from abs('a')=97, servo1, on top, uses digital pin 10
         to abs('b')=98, servo2, bottom, uses digital pin 9  */
      if (val>96 && val<99) {
        srv=val-96;                /* calculate servo number */
        //Serial.println(srv);
        s=81; /* next we will need to get value from serial  */
      }
      else {
        s=-1; /* if value is not a servo then return to -1   */
      }
      break; /* s=80 taken care of                           */


      case 81:
      /* the third received value indicates the servo angle  */ 
      if (srv==1) servo1.write(val);          /* write value */
      if (srv==2) servo2.write(val);
      //Serial.println(val);     
      s=-1;  /* we are done with servo write so go to -1 next*/
      break; /* s=81 taken care of                           */         



//-----------------------     
      /* s=90 means Query Script Type and Motor Shield type selection */
      case 90:
      /* the second received value indicates the motor number
         from abs('1')=49, motor1, to abs('4')=52, motor4    */
      if (val>48 && val<53) {
        dcm=val-48;                /* calculate motor number */
        s=91;  /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
      break;
      
       case 91:
      /* the third received value indicates the pin1 number  
         from ascii(2)=50 to ascii(e)=101                    */
      if (val>49 && val<102) {
        if (dcm==1) dcm1_pin1=val-48;/* calculate motor pin1 */
        if (dcm==2) dcm2_pin1=val-48;/* calculate motor pin1 */
        if (dcm==3) dcm3_pin1=val-48;/* calculate motor pin1 */
        if (dcm==4) dcm4_pin1=val-48;/* calculate motor pin1 */
        pinMode(val-48, OUTPUT); //set pin as output
        analogWrite(val-48,0);   /* DUTY CYCLE */
        s=92;  /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
    break;
     
       case 92:
      /* the fourth received value indicates the pin2 number  
         from ascii(2)=50 to ascii(e)=101                    */
      if (val>49 && val<102) {
        if (dcm==1) dcm1_pin2=val-48;/* calculate motor pin2 */
        if (dcm==2) dcm2_pin2=val-48;/* calculate motor pin2 */
        if (dcm==3) dcm3_pin2=val-48;/* calculate motor pin2 */
        if (dcm==4) dcm4_pin2=val-48;/* calculate motor pin2 */
        pinMode(val-48, OUTPUT); //set pin as output
        s=93;  /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
      break;

       case 93:
      /* the fifth received value indicates the pin2 number  
         from ascii(2)=50 to ascii(e)=101                    */
      if (val>47 && val<50) {
        int mode = val-48;
        if (dcm==1) dcm1_mode=mode;/* calculate motor mode */
        if (dcm==2) dcm2_mode=mode;/* calculate motor mode */
        if (dcm==3) dcm3_mode=mode;/* calculate motor mode */
        if (dcm==4) dcm4_mode=mode;/* calculate motor mode */
        //initialization of port
        if(mode==0){//L293
          if (dcm==1) analogWrite(dcm1_pin2,0);   /* DUTY CYCLE */
          if (dcm==2) analogWrite(dcm2_pin2,0);   /* DUTY CYCLE */
          if (dcm==3) analogWrite(dcm3_pin2,0);   /* DUTY CYCLE */
          if (dcm==4) analogWrite(dcm4_pin2,0);   /* DUTY CYCLE */
        } else if (mode==1) {//L297
          if (dcm==1) digitalWrite(dcm1_pin2, LOW);  /* DIRECTION */
          if (dcm==2) digitalWrite(dcm2_pin2, LOW);  /* DIRECTION */
          if (dcm==3) digitalWrite(dcm3_pin2, LOW);  /* DIRECTION */
          if (dcm==4) digitalWrite(dcm4_pin2, LOW);  /* DIRECTION */      
        }
        Serial.print("OK"); // tell Scilab that motor s initialization finished
                            // Cette commande sert à rien dans la toolbox de base,
                            // sauf si on prévoit d'ajouter des actions à l'init des moteurs
                            // par exemple chercher la position d'origine !
        s=-1;  /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
      break;

      /* s=170 or 171 means DC MOTOR SET SPEED  ************ */
      case 170:
      /* the second received value indicates the motor number
         from abs('1')=49, motor1, to abs('4')=52, motor4    */
      if (val>48 && val<53) {
        dcm=val-48;                /* calculate motor number */
        s=171; /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
      break; /* s=170 taken care of                          */


      case 171:
          /* the third received value indicates the sens direction */
          if (val>47 & val <50){
            int direction=val-48;
            while (Serial.available()==0) {};       // Waiting char
            val = Serial.read();                    //reading next value = 0..255 
            if (dcm==1){
             if(dcm1_mode==0){//L293 
              if(direction==1){
                analogWrite(dcm1_pin1,val);
                analogWrite(dcm1_pin2,0);
              } else {
                analogWrite(dcm1_pin2,val);
                analogWrite(dcm1_pin1,0);
              }
             } else {//L298
              if (direction==0) digitalWrite(dcm1_pin2,LOW);
              if (direction==1) digitalWrite(dcm1_pin2,HIGH);
              analogWrite(dcm1_pin1,val);
             }
            }
            if (dcm==2){
             if(dcm2_mode==0){//L293 
              if(direction==1){
                analogWrite(dcm2_pin1,val);
                analogWrite(dcm2_pin2,0);
              } else {
                analogWrite(dcm2_pin2,val);
                analogWrite(dcm2_pin1,0);
              }
             } else {//L298
              if (direction==0) digitalWrite(dcm2_pin2,LOW);
              if (direction==1) digitalWrite(dcm2_pin2,HIGH);
              analogWrite(dcm2_pin1,val);
             }
            }
            if (dcm==3){
             if(dcm3_mode==0){//L293 
              if(direction==1){
                analogWrite(dcm3_pin1,val);
                analogWrite(dcm3_pin2,0);
              } else {
                analogWrite(dcm3_pin2,val);
                analogWrite(dcm3_pin1,0);
              }
             } else {//L298
              if (direction==0) digitalWrite(dcm3_pin2,LOW);
              if (direction==1) digitalWrite(dcm3_pin2,HIGH);
              analogWrite(dcm3_pin1,val);
             }
            }
            if (dcm==4){
             if(dcm4_mode==0){//L293 
              if(direction==1){
                analogWrite(dcm4_pin1,val);
                analogWrite(dcm4_pin2,0);
              } else {
                analogWrite(dcm4_pin2,val);
                analogWrite(dcm4_pin1,0);
              }
             } else {//L298
              if (direction==0) digitalWrite(dcm4_pin2,LOW);
              if (direction==1) digitalWrite(dcm4_pin2,HIGH);
              analogWrite(dcm4_pin1,val);
             }
            }
         }
      s=-1;  /* we are done with servo write so go to -1 next*/
      break; /* s=171 taken care of                          */



      /* s=180 or 181 means DC MOTOR RUN/RELEASE  ********** */
      case 180:
      /* the second received value indicates the motor number
         from abs('1')=49, motor1, to abs('4')=52, motor4    */
      if (val>48 && val<53) {
        dcm=val-48;                /* calculate motor number */
        s=181; /* next we will need to get value from serial */
      }
      else {
        s=-1; /* if value is not a motor then return to -1   */
      }
      break; /* s=180 taken care of                          */

      case 181:
      /* the third received value indicates forward, backward,
         release, with characters 'f', 'b', 'r', respectively,
         that have ascii codes 102, 98 and 114               */
        if (val==114){
          if(dcm==1) {
           analogWrite(dcm1_pin1,0);
           if(dcm1_mode==0)  analogWrite(dcm1_pin2,0); 
          }
          if(dcm==2) {
           analogWrite(dcm2_pin1,0);
           if(dcm2_mode==0)  analogWrite(dcm2_pin2,0); 
          }
          if(dcm==3) {
           analogWrite(dcm3_pin1,0);
           if(dcm3_mode==0)  analogWrite(dcm3_pin2,0); 
          }
          if(dcm==4) {
           analogWrite(dcm4_pin1,0);
           if(dcm4_mode==0)  analogWrite(dcm4_pin2,0); 
          }
        }
      s=-1;  /* we are done with motor run so go to -1 next  */
      break; /* s=181 taken care of                          */

//-----------------------     
      /*Generic counter functions */
      case 210:
      /* ASKING ACTIVATION OF AN COUNTER     */
      if (val==97) {                                       //activation
         while (Serial.available()==0) {};                 // Waiting char
         val=Serial.read();                                // Read int_number (must be 0 or 1 on UNO / 1 to 5 on MEGA) : int_number set to encoder number
         pinMode(corresp[val],INPUT);              // set interrupt pin as input
         if       (val == 0) {attachInterrupt(val, counter_0_change, RISING);counter_0=0;}  //counter INT0
         else if  (val == 1) {attachInterrupt(val, counter_1_change, RISING);counter_1=0;}  //counter INT1
         else if  (val == 2) {attachInterrupt(val, counter_2_change, RISING);counter_2=0;}  //counter INT2
         else if  (val == 3) {attachInterrupt(val, counter_3_change, RISING);counter_3=0;}  //counter INT3
         else if  (val == 4) {attachInterrupt(val, counter_4_change, RISING);counter_4=0;}  //counter INT4
         else if  (val == 5) {attachInterrupt(val, counter_5_change, RISING);counter_5=0;}  //counter INT5
      }
      /* ASKING POSITION OF AN ENCODER     */ 
      if (val==112) {                        //sending encoder position
         while (Serial.available()==0) {};   // Waiting char
         val = Serial.read()   ;             //reading next value = encoder number
         if      (val==0){ Serial.write((uint8_t*)&counter_0,4); }// asking counter 0 
         else if (val==1){ Serial.write((uint8_t*)&counter_1,4); }// asking counter 1 
         else if (val==2){ Serial.write((uint8_t*)&counter_2,4); }// asking counter 2 
         else if (val==3){ Serial.write((uint8_t*)&counter_3,4); }// asking counter 3 
         else if (val==4){ Serial.write((uint8_t*)&counter_4,4); }// asking counter 4 
         else if (val==5){ Serial.write((uint8_t*)&counter_5,4); }// asking counter 5 
     }
      /* ASKING RELEASE OF AN ENCODER     */ 
      if (val==114) {                             //release encoder 
         while (Serial.available()==0) {};        // Waiting char
         val = Serial.read();                     //reading next value = encoder number
         detachInterrupt(val);                    // Detach interrupt on chanel A of encoder num=val
         if (val==0)       { counter_0=0;}        // Reset counter
         else if (val==1)  { counter_1=0;}        // Reset counter
         else if (val==2)  { counter_2=0;}        // Reset counter
         else if (val==3)  { counter_3=0;}        // Reset counter
         else if (val==4)  { counter_4=0;}        // Reset counter
         else if (val==5)  { counter_5=0;}        // Reset counter
      }
      /* ASKING RESET POSITION OF AN ENCODER     */ 
      if (val==122) {                             //sending encoder position
         while (Serial.available()==0) {};        // Waiting char
         val = Serial.read();                     //reading next value = encoder number
         if (val==0)       { counter_0=0;}        // Reset counter
         else if (val==1)  { counter_1=0;}        // Reset counter
         else if (val==2)  { counter_2=0;}        // Reset counter
         else if (val==3)  { counter_3=0;}        // Reset counter
         else if (val==4)  { counter_4=0;}        // Reset counter
         else if (val==5)  { counter_5=0;}        // Reset counter
       }
      
      
      s=-1;  /* we are done with this so next state is -1    */
      break; /* s=210 terminated                             */

//-----------------------     
      /*Generic encoder functions */
      case 220: 
      /* ASKING ACTIVATION OF AN ENCODER     */
      if (val==97) {                                       //activation
         while (Serial.available()==0) {};                 // Waiting char
         encoder_num=Serial.read();                        // Read int_number (must be 0 or 1 on UNO / 1 to 5 on MEGA) : int_number set to encoer number
         pinMode(corresp[encoder_num],INPUT);              // set interrupt pin as input
         while (Serial.available()==0) {};                 // Waiting char
         encoder_int2=Serial.read();                       // Read int2 (must be a digital PIN with interrupt or not : depends on mode)
                                                           // no declaration for the moment : wait for encoder mode
         while (Serial.available()==0) {};                 // Waiting char
         int mode = Serial.read()-48;                      // Read mode 1 ou 2 (1 counting only rising of chA, 2 counting rising and falling)
         if (mode == 4) {                                  // mode 4x : 2 cases : chA=pin2 / chB=pin3 or chA=pin3/chB=pin2 [Uno retriction]
            pinMode(corresp[encoder_int2],INPUT);          // set interrupt number as input
         } else {
            pinMode(encoder_int2,INPUT);                   // set pin as input
         }
         
         if (encoder_num == 0) {                             //encoder INT0
           encoder_0_position=0;                             // Reset position
           if (mode==4) {
             encoder_0_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A0, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B0, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_0_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_0_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_0_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_0_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         } else if (encoder_num == 1) {                      //encoder INT1
           encoder_1_position=0;                             // Reset position
           if (mode==4) {
             encoder_1_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A1, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B1, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_1_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_1_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_1_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_1_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         } else if (encoder_num == 2) {                      //encoder INT2
           encoder_2_position=0;                             // Reset position
           if (mode==4) {
             encoder_2_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A2, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B2, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_2_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_2_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_2_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_2_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         } else if (encoder_num == 3) {                      //encoder INT3
           encoder_3_position=0;                             // Reset position
           if (mode==4) {
             encoder_3_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A3, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B3, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_3_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_3_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_3_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_3_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         } else if (encoder_num == 4) {                      //encoder INT4
           encoder_4_position=0;                             // Reset position
           if (mode==4) {
             encoder_4_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A4, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B4, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_4_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_4_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_4_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_4_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         } else if (encoder_num == 5) {                      //encoder INT5
           encoder_5_position=0;                             // Reset position
           if (mode==4) {
             encoder_5_int2=corresp[encoder_int2];           // Save pin of second interruption
             attachInterrupt(encoder_num , encoder_change_m4_A5, CHANGE); // Attach interrupt on chanel A change
             attachInterrupt(encoder_int2, encoder_change_m4_B5, CHANGE); // Attach interrupt on chanel B change
           } else if (mode==2) {
             encoder_5_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_5_change_m2, CHANGE); // Attach interrupt on chanel A change
           } else if (mode==1) {
             encoder_5_int2=encoder_int2;
             attachInterrupt(encoder_num, encoder_5_change_m1, RISING); // Attach interrupt on chanel A rising
           }
         }
      }
      /* ASKING POSITION OF AN ENCODER     */ 
      if (val==112) {                        //sending encoder position
         while (Serial.available()==0) {};   // Waiting char
         val = Serial.read()   ;             //reading next value = encoder number
         if      (val==0){ Serial.write((uint8_t*)&encoder_0_position,4); }// asking encoder 0 position
         else if (val==1){ Serial.write((uint8_t*)&encoder_1_position,4); }// asking encoder 1 position
         else if (val==2){ Serial.write((uint8_t*)&encoder_2_position,4); }// asking encoder 2 position
         else if (val==3){ Serial.write((uint8_t*)&encoder_3_position,4); }// asking encoder 3 position
         else if (val==4){ Serial.write((uint8_t*)&encoder_4_position,4); }// asking encoder 4 position
         else if (val==5){ Serial.write((uint8_t*)&encoder_5_position,4); }// asking encoder 5 position
     }
      /* ASKING RELEASE OF AN ENCODER     */ 
      if (val==114) {                                      //release encoder 
         while (Serial.available()==0) {};                 // Waiting char
         val = Serial.read();                              //reading next value = encoder number
         detachInterrupt(val);                             // Detach interrupt on chanel A of encoder num=val
         if (val==0)       { encoder_0_position=0;encoder_0_int2=-1;}        // Reset position
         else if (val==1)  { encoder_1_position=0;encoder_1_int2=-1;}        // Reset position
         else if (val==2)  { encoder_2_position=0;encoder_2_int2=-1;}        // Reset position
         else if (val==3)  { encoder_3_position=0;encoder_3_int2=-1;}        // Reset position
         else if (val==4)  { encoder_4_position=0;encoder_4_int2=-1;}        // Reset position
         else if (val==5)  { encoder_5_position=0;encoder_5_int2=-1;}        // Reset position
         while (Serial.available()==0) {};                 // Waiting char
         val = Serial.read();                              // reading next value = encoder number
         detachInterrupt(val);                             // Detach interrupt on chanel B of encoder num=val (may be the same if mode=1 or 2)
      }
      /* ASKING RESET POSITION OF AN ENCODER     */ 
      if (val==122) {                                      //sending encoder position
         while (Serial.available()==0) {};                 // Waiting char
         val = Serial.read();                              //reading next value = encoder number
         if (val==0)       { encoder_0_position=0;}        // Reset position
         else if (val==1)  { encoder_1_position=0;}        // Reset position
         else if (val==2)  { encoder_2_position=0;}        // Reset position
         else if (val==3)  { encoder_3_position=0;}        // Reset position
         else if (val==4)  { encoder_4_position=0;}        // Reset position
         else if (val==5)  { encoder_5_position=0;}        // Reset position
      }
      
      
      s=-1;  /* we are done with this so next state is -1    */
      break; /* s=220 terminated                             */

//-----------------------     

      /* s=340 or 341 means ANALOG REFERENCE *************** */
      
      case 340:
      /* the second received value indicates the reference,
         which is encoded as is 0,1,2 for DEFAULT, INTERNAL  
         and EXTERNAL, respectively                          */
         
      switch (val) {
        
        case 48:
        analogReference(DEFAULT);
        break;        
        
        case 49:
        analogReference(INTERNAL);
        break;        
                
        case 50:
        analogReference(EXTERNAL);
        break;        
        
        default:                 /* unrecognized, no action  */
        break;
      } 

      s=-1;  /* we are done with this so next state is -1    */
      break; /* s=341 taken care of                          */



      /* ******* UNRECOGNIZED STATE, go back to s=-1 ******* */
      
      default:
      /* we should never get here but if we do it means we 
         are in an unexpected state so whatever is the second 
         received value we get out of here and back to s=-1  */
      
      s=-1;  /* go back to the initial state, break unneeded */



    } /* end switch on state s                               */

  } /* end if serial available                               */
  
} /* end loop statement                                      */


/**************************************/
// Generic interrupt encoder functions//
/**************************************/
//Encoder on INT0
void encoder_0_change_m1() { //encoder0 mode 1x
  int chB=digitalRead(encoder_0_int2);
  if (!chB) { encoder_0_position++;}
  else { encoder_0_position--; }
}
void encoder_0_change_m2() { //encoder0 mode 2x
  int chB=digitalRead(encoder_0_int2);
  int chA=digitalRead(corresp[0]);
  if ((chA & !chB)|(!chA & chB)) { encoder_0_position++; }
  else { encoder_0_position--; }
}
void encoder_change_m4_A0(){//encoder0 mode 4x chA
  int chA=digitalRead(corresp[0]);
  int chB=digitalRead(encoder_0_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_0_position++; }
  else { encoder_0_position--; }
}
void encoder_change_m4_B0(){//encoder0 mode 4x chB
  int chA=digitalRead(corresp[0]);
  int chB=digitalRead(encoder_0_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_0_position++; }
  else { encoder_0_position--; }
}
//Encoder on INT1
void encoder_1_change_m1() { //encoder1 mode 1x
  int chB=digitalRead(encoder_1_int2);
  if (!chB) { encoder_1_position++;}
  else { encoder_1_position--; }
}
void encoder_1_change_m2() { //encoder1 mode 2x
  int chB=digitalRead(encoder_1_int2);
  int chA=digitalRead(corresp[1]);
  if ((chA & !chB)|(!chA & chB)) { encoder_1_position++; }
  else { encoder_1_position--; }
}
void encoder_change_m4_A1(){//encoder1 mode 4x chA
  int chA=digitalRead(corresp[1]);
  int chB=digitalRead(encoder_1_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_1_position++; }
  else { encoder_1_position--; }
}
void encoder_change_m4_B1(){//encoder1 mode 4x chB
  int chA=digitalRead(corresp[1]);
  int chB=digitalRead(encoder_1_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_1_position++; }
  else { encoder_1_position--; }
}
//Encoder on INT2
void encoder_2_change_m1() { //encoder2 mode 1x
  int chB=digitalRead(encoder_2_int2);
  if (!chB) { encoder_2_position++;}
  else { encoder_2_position--; }
}
void encoder_2_change_m2() { //encoder2 mode 2x
  int chB=digitalRead(encoder_2_int2);
  int chA=digitalRead(corresp[2]);
  if ((chA & !chB)|(!chA & chB)) { encoder_2_position++; }
  else { encoder_2_position--; }
}
void encoder_change_m4_A2(){//encoder2 mode 4x chA
  int chA=digitalRead(corresp[2]);
  int chB=digitalRead(encoder_2_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_2_position++; }
  else { encoder_2_position--; }
}
void encoder_change_m4_B2(){//encoder2 mode 4x chB
  int chA=digitalRead(corresp[2]);
  int chB=digitalRead(encoder_2_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_2_position++; }
  else { encoder_2_position--; }
}
//Encoder on INT3
void encoder_3_change_m1() { //encoder3 mode 1x
  int chB=digitalRead(encoder_3_int2);
  if (!chB) { encoder_3_position++;}
  else { encoder_3_position--; }
}
void encoder_3_change_m2() { //encoder3 mode 2x
  int chB=digitalRead(encoder_3_int2);
  int chA=digitalRead(corresp[3]);
  if ((chA & !chB)|(!chA & chB)) { encoder_3_position++; }
  else { encoder_3_position--; }
}
void encoder_change_m4_A3(){//encoder3 mode 4x chA
  int chA=digitalRead(corresp[3]);
  int chB=digitalRead(encoder_3_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_3_position++; }
  else { encoder_3_position--; }
}
void encoder_change_m4_B3(){//encoder3 mode 4x chB
  int chA=digitalRead(corresp[3]);
  int chB=digitalRead(encoder_3_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_3_position++; }
  else { encoder_3_position--; }
}
//Encoder on INT4
void encoder_4_change_m1() { //encoder4 mode 1x
  int chB=digitalRead(encoder_4_int2);
  if (!chB) { encoder_4_position++;}
  else { encoder_4_position--; }
}
void encoder_4_change_m2() { //encoder4 mode 2x
  int chB=digitalRead(encoder_4_int2);
  int chA=digitalRead(corresp[4]);
  if ((chA & !chB)|(!chA & chB)) { encoder_4_position++; }
  else { encoder_4_position--; }
}
void encoder_change_m4_A4(){//encoder4 mode 4x chA
  int chA=digitalRead(corresp[4]);
  int chB=digitalRead(encoder_4_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_4_position++; }
  else { encoder_4_position--; }
}
void encoder_change_m4_B4(){//encoder4 mode 4x chB
  int chA=digitalRead(corresp[4]);
  int chB=digitalRead(encoder_4_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_4_position++; }
  else { encoder_4_position--; }
}
//Encoder on INT5
void encoder_5_change_m1() { //encoder5 mode 1x
  int chB=digitalRead(encoder_5_int2);
  if (!chB) { encoder_5_position++;}
  else { encoder_5_position--; }
}
void encoder_5_change_m2() { //encoder5 mode 2x
  int chB=digitalRead(encoder_5_int2);
  int chA=digitalRead(corresp[5]);
  if ((chA & !chB)|(!chA & chB)) { encoder_5_position++; }
  else { encoder_5_position--; }
}
void encoder_change_m4_A5(){//encoder5 mode 4x chA
  int chA=digitalRead(corresp[5]);
  int chB=digitalRead(encoder_5_int2);
  if ((chA & !chB)|(!chA & chB)) { encoder_5_position++; }
  else { encoder_5_position--; }
}
void encoder_change_m4_B5(){//encoder5 mode 4x chB
  int chA=digitalRead(corresp[5]);
  int chB=digitalRead(encoder_5_int2);
  if ((!chA & !chB)|(chA & chB)) { encoder_5_position++; }
  else { encoder_5_position--; }
}

/**************************************/
// Generic interrupt counter functions//
/**************************************/
//Counter on INT0
void counter_0_change() { //counter 0
  counter_0++;
}
//Counter on INT1
void counter_1_change() { //counter 1
  counter_1++;
}
//Counter on INT2
void counter_2_change() { //counter 2
  counter_2++;
}
//Counter on INT3
void counter_3_change() { //counter 3
  counter_3++;
}
//Counter on INT4
void counter_4_change() { //counter 4
  counter_4++;
}
//Counter on INT5
void counter_5_change() { //counter 5
  counter_5++;
}


