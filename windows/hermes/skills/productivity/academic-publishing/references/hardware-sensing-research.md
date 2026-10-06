# Extracted Technical Phrasing: IMU, Accelerometer, MEMS, I2C, and ESP8266

Authoritative extracted definitions, Wikipedia phrasing, and academic terminology for the *Hardware Architecture & Sensing Methodology* sections of embedded/wearable papers.

---

## 1. Inertial Measurement Unit (IMU) & 6-DOF Sensing

### Core Definitions & Physical Principles
* **6-DOF Kinematic Sensing:** "An inertial measurement unit (IMU) is an electronic device that measures and reports a body's specific force, angular rate, and sometimes the orientation of the body, using a combination of accelerometers, gyroscopes, and sometimes magnetometers."
* **Strapdown Inertial Navigation:** "A typical implementation referred to as a Strap Down Inertial System integrates angular rate from the gyroscope to calculate angular position. This is fused with the gravity vector measured by the accelerometers in a Kalman filter to estimate attitude."
* **Dead Reckoning & Kinematic Propagation:** "The data collected from the IMU's sensors allows a computer to track craft's position, using a method known as dead reckoning... The attitude estimate is used to transform acceleration measurements into an inertial reference frame where they are integrated once to get linear velocity, and twice to get linear position."

### Error Dynamics & Drift Propagation
* **Accumulated Integration Error:** "Because the guidance system is continually integrating acceleration with respect to time to calculate velocity and position, any measurement errors, however small, are accumulated over time. This leads to 'drift': an ever-increasing difference between where the system thinks it is located and the actual location."
* **Polynomial Error Growth:** "Due to integration, a constant error in acceleration results in a linear error growth in velocity and a quadratic error growth in position. A constant error in attitude rate (gyro) results in a quadratic error growth in velocity and a cubic error growth in position."

---

## 2. Accelerometer & MEMS Fabrication Principles

### Proper Acceleration & Gravitational Field Coupling
* **Proper Acceleration vs. Coordinate Acceleration:** "An accelerometer is a device that measures the proper acceleration of an object. Proper acceleration is the acceleration (the rate of change of velocity) of the object relative to an observer who is in free fall (that is, relative to an inertial frame of reference)."
* **Equivalence Principle & Gravity Offset:** "An accelerometer at rest relative to the Earth's surface will indicate approximately 1 g upwards because the Earth's surface exerts a normal force upwards relative to the local inertial frame... The reason for the appearance of a gravitational offset is Einstein's equivalence principle, which states that the effects of gravity on an object are indistinguishable from acceleration."
* **Vector Quantification:** "A multi-axis accelerometer detects both the magnitude and the direction of the proper acceleration, as a vector quantity, and is usually implemented as several single-axis accelerometers oriented along different axes."

### MEMS Transduction Mechanisms
* **Spring-Mass-Damper Dynamic Model:** "A basic mechanical accelerometer is a damped proof mass on a spring. When the accelerometer experiences an acceleration, Newton's third law causes the spring's compression (or extension) to adjust to exert an equivalent force on the mass to counteract the acceleration... Since the spring's force scales linearly with the length change (Hooke's law)... a measurement of the spring's compression is also a measurement of acceleration."
* **Surface Micromachining & Capacitive Comb Electrodes:** "Surface micromachining uses layers deposited on the surface of a substrate as the structural materials... The original surface micromachining concept was based on thin polycrystalline silicon layers patterned as movable mechanical structures and released by sacrificial etching of the underlying oxide layer. Interdigital comb electrodes were used to produce in-plane forces and to detect in-plane movement capacitively."

---

## 3. I2C Bus Communication & Physical Layer

### Bus Architecture & Open-Drain Signaling
* **Two-Wire Bus Protocol:** "I2C (Inter-Integrated Circuit) is a synchronous, multi-master/multi-slave, single-ended, serial communication bus... widely used for attaching lower-speed peripheral integrated circuits (ICs) to processors and microcontrollers in short-distance, intra-board communication."
* **Open-Drain Physical Topology:** "At the physical layer, both SCL and SDA lines are an open-drain (MOSFET) or open-collector (BJT) bus design, thus a pull-up resistor is needed for each line. A logic 0 is output by pulling the line to ground, and a logic 1 is output by letting the line float (output high impedance) so that the pull-up resistor pulls it high. A line is never actively driven high."

### Timing, Flow Control, and Addressing
* **Bus Speed Tiers:** Standard mode (100 kbit/s), Fast mode (400 kbit/s), Fast mode Plus (1 Mbit/s), and High-speed mode (3.4 Mbit/s).
* **Clock Stretching Flow Control:** "An addressed target device may hold the clock line (SCL) low after receiving (or sending) a byte, indicating that it is not yet ready to process more data. The controller that is communicating with the target may not finish the transmission of the current bit, but must wait until the clock line actually goes high."
* **Addressing Overheads:** 7-bit target address, sub-register pointer addressing, framing START/STOP conditions, and per-byte ACK/NACK acknowledge bits.

---

## 4. ESP8266 Microcontroller Architecture

### Processing Core & Wireless Integration
* **System-on-Chip (SoC) Specifications:** Low-cost Wi-Fi microchip with built-in TCP/IP networking stack and 32-bit RISC core (Tensilica Xtensa L106) clocked at 80 MHz or 160 MHz.
* **Integrated Peripherals:** Integrated 802.11 b/g/n Wi-Fi MAC/baseband/RF transceiver, power amplifier, low-noise receive amplifier, and RF balun.
* **Development Platform Integration:** NodeMCU boards package the ESP-12E module with an on-board USB-to-UART bridge (CP2102 or CH340G) and a 3.3V Low-Dropout (LDO) voltage regulator for development and prototyping.
