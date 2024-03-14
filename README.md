# **Handson-3-The-customized-stopwatch-on-CMOD-A7**
*Michael Lim Kee Hian, Ten Wei Lin, Stephanie-Ann T. Loy, Zachary Wu Xuan* 

Our group was tasked to design a stopwatch modification for the CMOD A7 board. We aimed to develop a timer design which could allow us to set the time and start the countdown until 0, which would trigger a buzzer alarm. The design also incorporates reset, stop, and start functions.  
## **Setup**
The respective CMOD A7 pins and buttons were set up as module inputs and outputs.   

![timer 0](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/7b84287f-f21a-4503-bbee-4eee69911236)  

The following elements were designed to fulfill the timer functions:   

![table 1](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/b441ebcb-25a2-4a73-979f-b0a05a6d5cc5)
![table 2](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/2f6fb71d-0852-49dd-be2a-dd000ad328f4)  

![timer 1](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/32a8f308-e248-4078-9337-581d19379b6c) 

The “running” state allows the start/stop button to toggle between the start and stop state by interrupting the clock.    

![timer 2](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/5de173b5-1cd2-463c-958a-2d8fcf5f207c)

The 10 Hz clock was generated from the 1500 Hz, 500 Hz, and 100 Hz clocks.  
 
![timer 3](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/c1c9c18c-75f8-478b-9542-eb593c0fee1a)  
![timer 4](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/ef5c141b-6186-46f7-aa1f-2cccad81add1)  

The 10 Hz clock was also generated to regulate the min/sec up and min/sec down functions when setting the time, while the 0.5 Hz clock is used to trigger the flashing colon on the 7-segment display. The 10 Hz clock also ensures that clicking the min/sec up and min/sec down buttons can be done quickly by holding down the button, instead of repeatedly having to press the button multiple times.  Sec_unit_bcd_r, sec_deca_bcd_r, min_unit_bcd_r, and min_deca_bcd_r register the value for the ones and tenths places of the second and minute display of the timer.   

The default clock tree was removed as modularisation of the clock tree posed problems in the FPGA logic for creating the if-else case statement between the running “start” and “stop” states. This is why the count up/down and time set logic has been shoved into the 10Hz clock rather than being an independent “@always”/module as FPGA logic does not like non-clock based triggers, multiple triggers, or multiple triggers attempting to write to the same register/output, even if these triggers are technically controlled by a clock.  This method allows all the logic to be directly controlled/dictated by/tied to the clock, which is the optimal method of running FPGA logic.  

## **Countdown Logic**  
Once the start button is pressed and the running state is initiated, a series of if-else statements were used to subtract a value of 1 from the registered time set – starting from the ones and tenths places of the seconds to the ones and tenths places of the minutes, which is why there are many conditions to ensure that the digits change at the correct conditions (e.g. the tenths places of the seconds are subtracted by 1 and the ones places of the seconds begin from 9 when the minutes ≠ 0 but seconds = 0), while also accounting that there are 60 seconds in a minute.  

![timer 5](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/48cd7b3b-50fa-46c6-b629-621ae7996ab0)
![timer 6](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/9f7fb3a3-501f-498e-b7a6-c8a053cbde8f)
  
## **Timer Setting Logic**  
The time setting buttons (sec/min up and sec/min down buttons) were assigned to the secup, minup, secdn, and mindn states accordingly. The values can only affect the stored timer value when the running state is set to stop. Once the time setting buttons are pressed, the value gets sent to the second and minute register which is linked to the countdown logic. Similar to the countdown logic, a series of if-else statements were also used to ensure that the display value for minutes and seconds change according to the correct conditions (e.g. once the second up button is pressed when sec_unit_bcd_r = 9, the ones places of the seconds turns to zero and the tenths places increases by a value of 1).  

![timer 7](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/ad718a0e-835a-456a-9e5f-0569af2c3bd7)  
![timer 8](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/10127786-92d2-4522-8e45-21de39dce274)  

The values in the second and minute register were assigned to the 7 segment display module.   

![timer 9](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/87efc7be-20bf-4624-860e-545f673d6d22)  

The segment module used in the timer remained unchanged from the original segment module provided to us, except for a change in the values listed in the case statement to allow for separate programming of the column pin.  

![timer 10](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/9c651826-2a62-4128-a264-caff523f9028)  

## **Final Product**  
A 3D printed case was designed by Michael to house the CMOD A7 timer :) 
(video of timer was submitted separately)  

![photo1709873216](https://github.com/stephlovesfries/Handson-3-The-customized-stopwatch-on-CMOD-A7/assets/115708694/fa931965-23d3-4b62-b13a-65528afd990d)  

## **Challenges and learnings**   
Our group found it challenging to translate the design logic we wanted into Verilog form, especially because a timer requires the organization of many conditional statements in order to function properly (e.g. setting the time, countdown, display of digits). But through this project, we were able to expand the application of what we learned in class, while incorporating designs and ideas of our own.   





