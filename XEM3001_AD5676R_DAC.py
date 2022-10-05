"""
Module XEM3001_AD5676R_DAC
This molude uses XEM3001_AD5676R_DAC voltage generator.
Usage: 
  As shown in demo codes in __main__ block below, to use this DAC, just instantiate a "XEM3001_AD5676R_DAC" class, then use its "dac" method to generate a voltage in the specified channel. Eg:
  >>>import XEM3001_AD5676R_DAC
  >>>mydac = XEM3001_AD5676R_DAC.XEM3001_AD5676R_DAC()
  >>>channel = 1
  >>>volt = 1.056 #default, input as float voltage 
  >>>mydac.dac(channel, volt)
  
  >>>mydac.input_type = 2 #input in hex
  >>>volt = 0x3fff #for voltage range 0.0 ~ 5.0v, it means 0x3fff * 5.0 / 0xffff = 1.249943v
  >>>mydac.dac(channel, volt)
"""

import ok
import time
import sys
import ctypes

class XEM3001_AD5676R_DAC:
    def __init__(self, input_type=1, input_value=0.0, input_value_hex=0x0000, channel=1, dev_serial='102900007Z', bit_file='ad5676r_dac.bit'):
        self._channel = channel
        self._input_type = input_type #1 - volt, 2 - hex.
        self._input_value = input_value
        self._input_value_hex = input_value_hex
        self._dev_serial = dev_serial # device serial of our FPGA is '102900007Z'. Open the first FPGA if given a empty serial number ''.
        self._bit_file = bit_file
        self._volt_min = 0.0
        self._volt_max = 5.0  # 2 * Vref. AD5675R internal Vref is 2.5v.
        self._hex_volt_min = 0x0000
        self._hex_volt_max = 0xffff
        self._channel_min = 1
        self._channel_max = 8
        self.init_dev()

    @property
    def input_type(self):
        return int(self._input_type)

    @input_type.setter
    def input_type(self, input_t):
        self._input_type = input_t

    @property
    def input_value(self):
        return self._input_value
        
    @input_value.setter
    def input_value(self, input_v):
        self._input_value = input_v
        if (input_v < self._volt_min): self._input_value = self._volt_min
        if (input_v > self._volt_max): self._input_value = self._volt_max

    @property
    def input_value_hex(self):
        return int(self._input_value_hex)
        
    @input_value_hex.setter
    def input_value_hex(self, input_v_hex):
        self._input_value_hex = int(input_v_hex)
        if (self._input_value_hex < self._hex_volt_min): self._input_value_hex = self._hex_volt_min
        if (self._input_value_hex > self._hex_volt_max): self._input_value_hex = self._hex_volt_max
        
    @property
    def channel(self):
        return int(self._channel)

    @channel.setter
    def channel(self, chan):
        self._channel = int(chan)
        if (self._channel < self._channel_min): self._channel = self._channel_min
        if (self._channel > self._channel_max): self._channel = self._channel_max

    @property
    def dev_serial(self):
        return self._dev_serial

    @dev_serial.setter
    def dev_serial(self, dev_seri):
        self._dev_serial = dev_seri

    @property
    def bit_file(self):
        return self._bit_file

    @bit_file.setter
    def bit_file(self, bit_f):
        self._bit_file = bit_f

    def volt2hex(self):
        self.input_value_hex = int(round((self.input_value - self._volt_min) * (self._hex_volt_max - self._hex_volt_min) / (self._volt_max - self._volt_min))) + self._hex_volt_min

    def hex2volt(self):
        self.input_value = (self.input_value_hex - self._hex_volt_min) * (self._volt_max - self._volt_min) / (self._hex_volt_max - self._hex_volt_min) + self._volt_min

    def init_dev(self):
        self._device = ok.okCFrontPanel()
        if (self._device.GetDeviceCount() < 1):
            sys.exit("Error: no Opal Kelly FPGA device.")
        try: 
            self._device.OpenBySerial(self.dev_serial)
            error = self._device.ConfigureFPGA(self.bit_file)
        except:
            sys.exit("Error: can't open Opal Kelly FPGA device by serial number %s" % self.dev_serial)
        if (error != 0):
            sys.exit("Error: can't program Opal Kelly FPGA device by file %s" % self.bit_file)

    def dac(self, chan, volt):
        cmd_addr_base = 0x0010; #bit7~4: dac command fixed to "1". bit3~0: dac channel address, start from 0.
        self.channel = chan
        if (self.input_type == 1):
            self.input_value = volt
            self.volt2hex()
        else:
            self.input_value_hex = int(volt)
            self.hex2volt()
        
        cmd_addr = cmd_addr_base + self.channel - 0x0001 #channel address start from 0
        
        # if it is needed, following codes can create raw hex data as binary bytes.
        # prefix = b'\x00\x00'
        # bit1 = self.input_value_hex >> 8
        # but2 = self.input_value_hex - bit1 << 8
        # hex_value = bytes([bit1]) + bytes([bit2]) 

        print("Output in channel {0}: {1: .6f}V".format(self.channel, self.input_value))
        self._device.SetWireInValue(0x00, int(self.input_value_hex)) # 0x00 is the WireIn address of the variable in FPGA for dac input value
        self._device.SetWireInValue(0x01, cmd_addr) # 0x01 is the WireIn address of the variable in FPGA for dac command and address
        self._device.UpdateWireIns() #update the WireIns to FPGA, let dac output the voltage in the specified channel.

# here are demos for the using this module.        
if __name__ == '__main__':
    mydac = XEM3001_AD5676R_DAC()
    k = 0
    chan1 = 1
    chan7 = 7
    volt = mydac._volt_min
    volt_inc = (mydac._volt_max - mydac._volt_min) / 7
    #demo1: change input volts in float. (input_type = 1 (default))
    while (k < 15):
        mydac.dac(chan1, volt)
        time.sleep(0.3)
        mydac.dac(chan7, volt)
        volt = volt + volt_inc
        if (volt >= mydac._volt_max or volt <= mydac._volt_min): 
            volt_inc = -volt_inc
            if (volt >= mydac._volt_max): volt = mydac._volt_max
            if (volt <= mydac._volt_min): volt = mydac._volt_min
        k = k + 1
        time.sleep(0.5)

    time.sleep(2.0) 
    
    #demo2: change input volts in hex 0x0000~0xffff. (input_type = 2) 
    mydac.input_type = 2
    volt = mydac._hex_volt_min
    volt_inc = int((mydac._hex_volt_max - mydac._hex_volt_min) / 11)
    k = 0
    while (k < 20):
        mydac.dac(chan1, volt)
        time.sleep(0.3)
        mydac.dac(chan7, volt)
        volt = volt + volt_inc
        if (volt >= mydac._hex_volt_max or volt <= mydac._hex_volt_min): 
            volt_inc = -volt_inc
            if (volt >= mydac._hex_volt_max): volt = mydac._hex_volt_max
            if (volt <= mydac._hex_volt_min): volt = mydac._hex_volt_min
        k = k + 1
        time.sleep(0.5)