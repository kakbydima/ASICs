
import time
import numpy as np
# cnt is used to keep data continuos 
def sinedata(Tproc,Tacq,Fs,ch,Am,f_sine,cnt):
    a=int(Tacq*Fs)
    tsamples = list(range(cnt*a,(cnt+1)*a))
    t = [x/Fs for x in tsamples]
    y = np.round(Am * np.sin(2 * np.pi * f_sine * np.array(t)),2)
    y1=[list(y)]*ch
    time.sleep(Tproc)
    return y1

