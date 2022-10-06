% SCRIPT - Output quantization error of a digital processing process %

% BRIEFING %
% -This script analyzes how Quantization Noise caused by sampling a   % 
% periodic analog signal behaves when processed by a digital filter   %
% and the improvement we can obtain on the SNR when we use Dithering. %

% ----------Config ADC---------- % 
Nbits = 12;
Vref = 3.3;
LSB = Vref/(2^Nbits);

% ----------Signals to be sampled---------- %
f1 = 50*10^3 ;  % Signal freq of 50kHz
Vcc1 = 1.65;  
A1 = 0.8;   % Amplitude
y1 = @(t) Vcc1 + A1*sin(2*pi*f1*t) ;    % Sinusoidal signal example 

% ----------Sampling interval---------- %
fs = 2*10^6 ; % Sampling freq of 1MHz
t1 = 0 ;
Np = 20 ;
t2 = Np/f1 ;  % Sampling Np periods of y1
Ts = 1/fs ;
t = [t1:Ts:t2];

% ----------Sampled signal---------- %
Y = y1(t);
L = length(Y);             % Length of signal

% ----------Signal + random noise (Dithering)---------- %
Nd = 5;                             % N-bit dithering
Y_dith = Y + rand(1,L)*Nd*LSB;      % N-LSB random noise

% ----------Quantized signals---------- %
partition = 0+LSB/2:LSB/2:Vref;             % Under this intervals, the signal is quantized
codebook = 0:LSB/2:Vref;                    % rounding down (floor)
[ind,qY] = quantiz(Y,partition,codebook);               % Obtention of quantized signal (qY)
[ind2,qY_dith] = quantiz(Y_dith,partition,codebook);    % Obtention of quantized(signal+noise)

% ----------Quantization error sequences---------- %
EqY = Y - qY;  % Discrete sequence: quantiz. error
EqY_dith = Y_dith - qY_dith;  % Discrete sequence: quantiz. error with dithering

% ----------Single-Sided Amplitude Spectrum of EqY---------- %
Eq1f = fft(EqY);
P2 = abs(Eq1f/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f1 = fs*(0:(L/2))/L;

% ----------Single-Sided Amplitude Spectrum of EqYdith---------- %
Eq1f_dith = fft(EqY_dith);
P2_dith = abs(Eq1f_dith/L);
P1_dith = P2_dith(1:L/2+1);
P1_dith(2:end-1) = 2*P1_dith(2:end-1);

% ----------Single-Sided Amplitude Spectrum of Y---------- %
Yf = fft(Y);
Py2 = abs(Yf/L);
Py1 = Py2(1:L/2+1);
Py1(2:end-1) = 2*Py1(2:end-1);

% ----------Single-Sided Amplitude Spectrum of Y_dith---------- %
Yf_dith = fft(Y_dith);
Py2_dith = abs(Yf_dith/L);
Py1_dith = Py2_dith(1:L/2+1);
Py1_dith(2:end-1) = 2*Py1_dith(2:end-1);

% ----------Single-Sided Amplitude Spectrum of qY---------- %
Yqf = fft(qY);
Pyq2 = abs(Yqf/L);
Pyq1 = Pyq2(1:L/2+1);
Pyq1(2:end-1) = 2*Pyq1(2:end-1);

% ----------Single-Sided Amplitude Spectrum of qY_dith---------- %
Yqf_dith = fft(qY_dith);
Pyq2_dith = abs(Yqf_dith/L);
Pyq1_dith = Pyq2_dith(1:L/2+1);
Pyq1_dith(1:end-1) = 2*Pyq1_dith(1:end-1);

% ---------- N-th order IIR filter -> N cascaded single pole IIR ---------- %
ALPHA = 0.0001;
N=3;
a = [1];
for i = 1:N
    aux = [1 -ALPHA];
    a = conv(a,aux);
end

% ---------- N-th order "complementary" IIR filter -> N cascaded single pole IIR ---------- %
N=3;
a = [1];
for i = 1:N
    aux = [1 -(1-ALPHA)];
    a = conv(a,aux);
end

h1 = freqz(ALPHA^N,a,f1,fs);
h2 = freqz((1-ALPHA)^N,a,f1,fs);

% ---------- Plotting ---------- %
figure(1)
P1_dB = 20*log(h1.*P1);
%P2_dB = 20*log(h2.*P1);
subplot(4,1,1)
plot(f1(1:end),P1_dB(1:end))
%hold on
%plot(f1(1:end),P2_dB(1:end))
title('Freq. response of filtered Quantization Noise')
%legend('N-th order filter','N-th order complementary filter');
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

Py1_dB = 20*log(h1.*Py1);
subplot(4,1,2)
plot(f1(1:end),Py1_dB(1:end))
%ylim([-100 inf])
title('Freq. response of filtered signal')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

Pyq1_dB = 20*log(h1.*Pyq1);
subplot(4,1,3)
plot(f1(1:end),Pyq1_dB(1:end))
%ylim([-100 inf])
title('Freq. response of filtered: signal + noise')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

SNR_dB = Py1_dB - P1_dB;
subplot(4,1,4)
plot(f1(1:end),2*(SNR_dB(1:end)))
%ylim([-60 inf])
title('SNR - Signal / Quantiz. Noise')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

% Analysis with Dithering %
figure(2)
P1_dB_dith = 20*log(h1.*P1_dith);
subplot(4,1,1)
plot(f1(2:end),P1_dB_dith(2:end))
title('Freq. response of filtered Quantization Noise')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

Py1_dB_dith = 20*log(h1.*Py1_dith);
subplot(4,1,2)
plot(f1(1:end),Py1_dB_dith(1:end))
%ylim([-100 inf])
title('Freq. response of filtered signal')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

Pyq1_dB_dith = 20*log(h1.*Pyq1_dith);
subplot(4,1,3)
plot(f1(2:end),Pyq1_dB_dith(2:end))
%ylim([-100 inf])
title('Freq. response of filtered: signal + noise')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid

SNR_dB_dith = Py1_dB_dith - P1_dB_dith;
subplot(4,1,4)
plot(f1(1:end),2*(SNR_dB_dith(1:end)))
%ylim([-60 inf])
title('SNR - Signal / Quantiz. Noise')
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
grid
