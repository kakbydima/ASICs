
import time
import statistics as st
import math
import pandas as pd
import struct 
import numpy as np
from matplotlib import pyplot as plt
import pickle
import sys
from datetime import datetime
# from bitarray import bitarray

# imporint our sine function
import sine_func1

# FUNCTIONS USED
def square(list):
    return [i ** 2 for i in list]
    
def sub(list,a):
    return [i -a for i in list]

def set_plot_array(ch2plot):
    switch_dic = {
         2: [1,2],
         4: [2,2],
         8: [2,4],
         16: [4,4],
         32: [8,4]
    }
    return switch_dic.get(ch2plot)
    
def prepare_subplots(ch2plot,plot_xlim,plot_ylim):
    ncol,nrow = set_plot_array(ch2plot) 
    fig, ax = plt.subplots(nrows=nrow,ncols=ncol)
    line = [[] for dummy in range(ncol*nrow)] 
    k=0
    for row in ax:
        for col in row:
            col.set_xlim(plot_xlim)
            col.set_ylim(plot_ylim)
            line[k], =col.plot([], lw=3)
            k=k+1
    fig.canvas.draw()   # note that the first draw comes before setting data 
    axbackground=fig.canvas.copy_from_bbox(fig.bbox)
    plt.show(block=False)
    return fig, ax, axbackground, line, ncol, nrow

READ_SIZE = 32*4*1024
BLOCK_SIZE = 512 # bytes
# ====VARIABLES====
chStart=1
chEnd=16
Fs = 8e3;
win_size = 1
ch2turnon = 0xffff
ch2plot = 8 # number of channels to plot
save_raw = 1

ch2read=( (chEnd<<8)|chStart)
samples = int(READ_SIZE//32//4*32//(chEnd-chStart+1))
win_size_chunks = round(win_size*Fs/samples)

plot_xlim = [0,Fs/samples/win_size_chunks]
plot_ylim = [-10, 10]
# =================

## print current time
now = datetime.now()
current_time = now.strftime("%H_%M_%S")
print("Current Time =", current_time)
## Prepare things for image 
fig, ax, axbackground, line, ncol,nrow = prepare_subplots(ch2plot,plot_xlim,plot_ylim)

chs_mean=[]
chs_rms=[]
#======================================================


msg_size = 32;
datain = bytearray(int(READ_SIZE))
samplecnt=0
output_bin_list= []
channels=[]
output_dec_list=[]
channels_dec = []
max_acq_time=0
data2ch =[]
dataout =[]
channel =[]
start_time = time.time() 
cnt=0
try:
    x=1/Fs*np.array((range(int(samples*win_size_chunks))))
    # data2plot = [0]*samples*win_size_chunks
    data2plot = [[0]*samples*win_size_chunks for dummy in range(chEnd-chStart+1)] 
    
    datamapped2plot = [[] for dummy in range(chEnd-chStart+1)] 
    while (True):
        Tproc = .060
        Fs = 8e3
        Tacq = samples/Fs
        # print(Tacq)
        Am = 10
        f_sine = 1
        convDurStart=time.time()  
        
        datamapped2plot=sine_func1.sinedata(Tproc,Tacq,Fs,(chEnd-chStart+1),Am,f_sine,cnt)
        cnt=cnt+1
        # assigning new datachunks to maxtrix that plots whole window 
        for qq in range(ch2plot):
            temp=data2plot[qq]
            temp = temp[samples:]+datamapped2plot[qq]
            data2plot[qq] = temp
        # updating plot
        pltUpdStart=time.time()
        fig.canvas.restore_region(axbackground)
        k=0
        for row in ax:
            for col in row:
                line[k].set_data(x,data2plot[k])
                col.draw_artist(line[k])
                k=k+1
        fig.canvas.blit(fig.bbox)
        fig.canvas.flush_events()
        pltUpdDur=round(1000*(time.time()-pltUpdStart))
        dur1=time.time() - start_time
        convDur=round(1000*(time.time() - convDurStart))
        # print("--- %s Mbps ---" % (str(temp_sr).ljust(6)),' conv_time ' +str(convDur)+' sec' )
        print(' conv_time ' +str(convDur)+' msec',' Plot update time ' +str(pltUpdDur)+' msec' )
        start_time = time.time()
               
except KeyboardInterrupt:
    print('Done Recording')
            

print('saving pickle')
pickle2save ={'channel':channels,'datapoint':dataout}
pickle.dump( pickle2save, open( "./data/"+filename_raw+'.p', "wb" ) )

# saving_pickle=time.time() - start_time - sort_time - makingdf_time - saving_time
saving_pickle=time.time() - start_time 
print( 'took ',saving_pickle, ' sec')



