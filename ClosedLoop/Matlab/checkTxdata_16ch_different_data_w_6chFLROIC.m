%% CLEAR WORKSPACE
clc
close all
clear all
%% CREATE PREAMBLE TO COMPARE WITH
preamble_end_idx = 0; % Parameter to find. End index of preamble.

data_size = 12*16; %size of ERC data
data_block_size = 12;

size = 88;
preamble = (['10010101']);
data = zeros(1, size);

data = (preamble - '0');
initial = data; %codewordGen(data);
size_out = length(initial);


%% LOAD AND INTERPOLATE AFE DATA
txdata = csvread('TX_H_Output_6ch_FLROIC_rtl.csv');
time = txdata(1:end,1);
data = (txdata(1:end,2))>=1;
freq = 10e6;

% interpolation * skip if not needed 
t2 = time(1):1/freq:(time(end)-1/freq);
i=i+1
 for i = 1:length(t2)
  index = find(round(time*10e6) <= round(t2(i)*10e6));
  dataout1(i) = data(index(end));
  temp_time = t2(i);
  temp_data =  dataout1(i);
 end
% interpolation end 

%dataout1 = data'; % un-comment if interpolation is not needed 
%t2 = time'; % un-comment if interpolation is not needed
figure(333)
subplot(2,1,1)
stem(t2, dataout1);
subplot(2,1,2)
stem(time, data);

%% CHECK PREAMBLE

preamble_time_start_aprox = 6.17e-3; % DEFINE APPROXIMATE START OF PREABLE
idx = find(round(t2*1e6)<=round(preamble_time_start_aprox*1e6));

figure(555);
for i = 1:length(dataout1(idx(end):end))
    idx_start = idx(end)+i;
    idx_end = idx(end)+size_out+i-1;
    a = dataout1(idx_start:idx_end);
    b = initial;
    R = corrcoef(a, b);
    stem(t2(idx_start:idx_end),a); hold on; stem(t2(idx_start:idx_end),b); hold off; grid on;
    xlim([t2(idx_start) t2(idx_end)])
    pause(0.03);
    if (abs(max(max(triu(R,1)))-1)<1e-15) 
        preamble_end_idx = idx_end; 
         a
         b
        disp('MATCH!');
        break;
    end
end
%% CHECK MESSAGE NUMBER 
msg_num_idx = preamble_end_idx+1;
msg_num =  dataout1(msg_num_idx:msg_num_idx+10);
msg_num_dec = bin2dec(num2str(fliplr(msg_num)))
%% SKIP REGISTER BITS AND CHECK IF AFE_READY==1
% signal consists of 
% preamble(8bit) -> message number(10bit) -> registers (18bit)

% register 18 bit consists of 
% LED active(1bit)
% ADDLOC (8bit)
% DATALOC (8bit)
% FLROIC (17bit)
% AFE READY (1bit)
% AFE_DATA (16x12bit)
% 
%

AFE_READY_idx = preamble_end_idx+10+17+102;
FLROIC_idx =  preamble_end_idx+10+17;
FLROIC_data = zeros(6,17);
for i = 1:6
    FLROIC_data(i,:) = dataout1(FLROIC_idx+1+(i-1)*17:FLROIC_idx+17+(i-1)*17);
end 
FLROIC_data
FLROIC_data_mock = cell2mat(struct2cell(load('FLROIC_data_mock','FLROIC_data')))
if (FLROIC_data_mock==FLROIC_data)
    display('====FLROIC data MATCH!====')
end
AFE_READY_data =dataout1(AFE_READY_idx+1);
%


%% CREATE AFE DATA TO COMPARE WITH
N2 = 0:data_size/data_block_size-1;

m2 = fliplr(dec2bin(N2, data_block_size) - '0');
m2 = m2';
message2 = m2(:)';

%erc_data = message2;
load('data_par.mat')
erc_data = data_par';
%% CHECK AFE DATA

figure;
tol = 1e-5;
% preamble_end_idx = preamble_end_idx - 100;
size_to_check = length(erc_data);
for i = 1:length(dataout1(AFE_READY_idx:end))
    idx_start = AFE_READY_idx+i;
%     idx_end = preamble_end_idx+size_to_check+i-1;
    idx_end = AFE_READY_idx+size_to_check+i-1;
    a = dataout1(idx_start:idx_end);
    b = erc_data(1:size_to_check);
    R = corrcoef(a, b);
    stem(a,'fill'); hold on; stem(b); hold off; grid on;
    pause(0.03);
    max(max(triu(R,1)))
    if abs(max(max(triu(R,1))) - 1) < tol
        %preamble_end_idx = idx_end;
        disp('MATCH!');
        break;
    end
end