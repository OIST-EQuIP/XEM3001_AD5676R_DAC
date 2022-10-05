# XEM3001_AD5676R_DAC
The project creates a voltage generator. 

Its hardware uses an Opal Kelly XEM3001(Xilinx Spartan-3 FPGA) board to control a DAC AD5676R evaluation board.

What are those files: 
1, AD5676R.v: the DAC circuit implemented on FPGA
2, top.v: the top circuit on FPGA, using Opal Kelly FrontPanel framework to pass command and data from PC to the DAC circuit.
3, dac_tb.v: test bench to simulate the above implementation.
4, DAC_0.ucf: FPGA constraint file.
5, DAC_0.xpf: a GUI written in XML, supported by Opel Kelly FrontPanel API, to test the DAC.
6, ad5676r_dac.bit: the .bit file (binary file) created from AD5676R.v, top.v, and DAC_0.ucf, by ISE14.7 SDK.
7, XEM3001_AD5676R_DAC.py: a Python module for end user. It uses Opel Kelly FrontPanel API to control the DAC.

How to use:
1, Pre-requirement:
(1) Pyhton 3 
  Developped and tested in Python 3.7
(2) Opel Kelly FrontPanel USB driver and Python API
  Download and install the FrontPanel USB driver. 
  The API with be installed at the same time, under <FP_root>, normally which is "C:\Program Files\Opal Kelly\FrontPanelUSB\".
  Modify PATH and PYTHONPATH variables for the API: 
        Add "<FP_root>\API\lib\x64" and "<FP_root>\API\Python\3.7\x64" to PATH. 
        Add "<FP_root>\API\Python\3.7\x64" to PYTHONPATH 
  After that, Python is good to run following command:
   import ok
(3) Python module for DAC and the .bit file
  Put files XEM3001_AD5676R_DAC.py and ad5676r_dac.bit under the same directory with user's codes.

2, End user code examples
(1) input voltage in float value
  import XEM3001_AD5676R_DAC
  mydac = XEM3001_AD5676R_DAC.XEM3001_AD5676R_DAC()
  channel = 1
  volt = 1.056 #default, input as float voltage 
  mydac.dac(channel, volt) #channel 1 will output 1.056V.

(2) input voltage in hex value (range: 0x0000 ~ 0xffff)
  import XEM3001_AD5676R_DAC
  mydac = XEM3001_AD5676R_DAC.XEM3001_AD5676R_DAC()
  channel = 5
  mydac.input_type = 2 #input in hex
  volt = 0x3fff #for voltage range 0.0 ~ 5.0v, it means 0x3fff * 5.0 / 0xffff = 1.249943V
  mydac.dac(channel, volt) #channel 5 will output 1.249943V.
