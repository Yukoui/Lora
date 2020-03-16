clear all;
clc;
%% LoRa Communication Protocol
%% Parameter  Setting
BW = 125e3;     % 7.8, 10.4, 15.6, 20.8, 31.2, 41.7, 62.5, 125, 250, 500
SF = 12;             % range from 6 to 12
Fc = 1.2e6; 

parity_num = 4;
CR = 4/(4 + parity_num);           % code rate

byte_num = 120;
info_bit_num = 8 * byte_num;
code_num = info_bit_num / CR;        %the number of codeword

%% EnCoding (Hamming)
bits = randn(1,info_bit_num) > 0;     % randomly generate information
[code_bit] = HammingCode(parity_num,bits);

%% InterleaveCode
[interLeave_codeword,cOld_length] = Interleavecode(code_bit,parity_num,SF);

%% Modulation
[IQdata,symbol_num] = Modulation(interLeave_codeword,SF,BW,parity_num,byte_num);

%% Demod
[c_recovered] = Demod(IQdata,SF,BW,symbol_num);

%% DeInterleavecode
[codeword_old] = DeInterleavecode(c_recovered,cOld_length,parity_num,SF);

%% Decode (Hamming)
[source_code] = HammingDecode(parity_num,codeword_old);

test1 = (c_recovered - interLeave_codeword);
test2 = (codeword_old - code_bit);
test3 = (source_code - bits);
[max(test1) max(test2) max(test3)]
BER = sum(abs(test3))/length(test3);
['BER = ' num2str(BER)]
disp('run success!');