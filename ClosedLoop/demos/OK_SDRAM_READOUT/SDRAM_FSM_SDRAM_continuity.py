# First we import the library and init the FrontPanel object

import ok
import time
import statistics as st
import math
import csv
import pandas as pd
import sys
# import numpy as np

from datetime import datetime
def MIN(a,b):
    c= a < b and a or b
    return(c)
# =======
# relevant to XEM6310
mem=1
g_nMemSize = 128*1024*1024
g_nMems = 1
READ_SIZE = 320*1000 # bytes

BLOCK_SIZE = 64 # bytes
# =======
dev = ok.okCFrontPanel()
#%% 
bitfilename='SDRAM_FSM_ex2_debug/ramtest'
# Next we open the device and program it
error_OpenBySerial = dev.OpenBySerial("")
error_ConfigureFpga = dev.ConfigureFPGA(bitfilename+".bit");

#%% 
# Display some diagnostic code
print("Open by Serial Error Code: " + str(error_OpenBySerial))
print("Configure FPGA Error Code: " + str(error_ConfigureFpga))

print("Device firmware version: ", str(dev.GetDeviceMajorVersion()),'.',str(dev.GetDeviceMinorVersion()))

print("Device serial number: ", str(dev.GetSerialNumber()));
print("Device ID string: ", str(dev.GetDeviceID()));


# printf("   Generating random data...\n");

#  Reset FIFOs
dev.SetWireInValue(0x00, 0x0004);
dev.UpdateWireIns();
dev.SetWireInValue(0x00, 0x0000);
dev.UpdateWireIns();
# // Enable SDRAM write/read memory transfers
dev.SetWireInValue(0x00, 0x0003);
dev.UpdateWireIns();
print("   Enabling SDRAM WR/RE...", '\n');
read_list =bytearray([])
read = bytearray(int(READ_SIZE))
k=0
start_time=0
while (k<10): # k=500 would prove the continuity of data 
    dev.UpdateWireOuts()
    memoryCount = dev.GetWireOutValue(0x20)
    # print(memoryCount)
    if memoryCount>(READ_SIZE): #approx. 128msec
        ret = dev.ReadFromBlockPipeOut(0xA0, BLOCK_SIZE, read)
        print('readout')
        print('length ',len(read)*8,' bits')
        if (ret<0):
            print('error,  . Code error - ',str(ret))
            break
        read_list.extend(read)
        k=k+1
        dur=time.time()-start_time
        start_time = time.time()
        print('acq time - ',dur)
        # break
        

print('length of readout data - ',len(read))
# for i in range(0,int(g_nMemSize/len(read))):
# print()

outputbits = ''.join(format(byte, '08b')[::-1] for byte in read_list)
# print(type(outputbits))
# print(outputbits)
print(outputbits[0:330])
output_bin_list=[]
output_dec_list=[]
for i in range((READ_SIZE*k//4)):
    dataoutbin=outputbits[10*i:(10*(i+1))]
    dataoutbin=dataoutbin[::-1]
    dataoutdec=int(dataoutbin[0:10],2)
    output_bin_list.append(dataoutbin)
    output_dec_list.append(dataoutdec)
# print((output_dec_list))
temp=0
print ('length of vector is ',(len(output_dec_list)))
for i in range((READ_SIZE*k//4)//32):
    compare1=abs(output_dec_list[32*i+9]-temp)
    if (compare1!=1):
        print(i)
        print(temp)
        print(output_dec_list[32*i])
        print(compare1)
        # print('the data is NOT continues')
        # break
    temp=output_dec_list[32*i+9]
if (compare1==1):
    print('the data is continues')
print(output_dec_list[0:33])
# print(read_list==data_buf)
