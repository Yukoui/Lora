function [c_recovered] = Demod(IQdata,SF,BW,symbol_num)
%% Parameter passing
Fs = BW;           % sample frequency
symbol_time = 2^SF / BW; 
%% Signal Genneration
t = 0: 1/Fs: (symbol_time - 1/Fs);
f0 = 0;
f1 = BW;
%% design upchirp and downchirp
% upchirp
chirpI = chirp(t, f0, symbol_time, f1, 'linear', 90);
chirpQ = chirp(t, f0, symbol_time, f1, 'linear', 0);
upChirp = complex(chirpI, chirpQ);
clear chirpI chirpQ

%% Signal synchronization and cropping
[corr, lag] = xcorr(IQdata, upChirp);   % I am not sure that whether we should employ more symbols to improve the synchronization performance
% plot(abs(corr))
corrThresh = max(abs(corr))/4;

cLag = find(abs(corr) > corrThresh, 1);
Spl = length(find(abs(corr) > corrThresh));
signalStartIndex = abs(lag(cLag)) + Spl*2^SF;           % We have sett the number of preamble as 8 in the modulation module.
signalEndIndex = signalStartIndex + symbol_num*(2^SF);

x = IQdata(signalStartIndex+1 : signalEndIndex);

%% De-chirping
deChirp = repmat(upChirp , 1 , ceil(length(x) / length(upChirp)) );
signal = x .* deChirp;

%% Spectrogram computation
Nfft = 2^SF; % 512
window_length = Nfft; % same as symbol_time*Fs;
[s, f, t] = spectrogram(signal, blackman(window_length), 0, Nfft, Fs);

%% Bit extraction
[~, symbols_recovered] = max(abs(s));
symbols_recovered = symbols_recovered - 1;        % Because the index of ouput begin with 1

c_recovered = 0;
for i = 1 : length(symbols_recovered)
    c_recovered = [ c_recovered , bitget(symbols_recovered(i) , 1:SF) ];  
end
c_recovered = c_recovered(2:end);

end