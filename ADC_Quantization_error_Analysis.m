% SCRIPT - ADC Quantization error analysis
% v1.0

% COMMENTS IN USAGE %
% The representation of the spectrum of the discrete quantization error can
% be improved by sampling more than the 2 periods that i choose for this
% example. I chose 2 only to visualize better the quantized signal and its
% associated quantizion error.

% ----------Config ADC---------- % 
Nbits = 12;
Vref = 3.3;
LSB = Vref/(2^Nbits);

% ----------Signals to be sampled---------- %
f1 = 50*10^3 ;  % Signal freq of 50kHz
Vcc1 = 1.65;  
A1 = 0.1;   % Sin amplitude
y1 = @(t) Vcc1 + A1*sin(2*pi*f1*t) ;    % Sinusoidal signal example with Vcc value !=0

% ----------Sampling interval---------- %
fs = 1.99*10^6 ; % Sampling freq of 1MHz
t1 = 0 ;
Np = 10 ;
t2 = Np/f1 ;  % Sampling Np periods of y1
Ts = 1/fs ;
t = [t1:Ts:t2];

% ----------Sampled signal---------- %
Y = y1(t);

% ----------Quantized signal---------- %
partition = 0+LSB/2:LSB/2:Vref;     % Under this intervals, the signal is quantized
codebook = 0:LSB/2:Vref;            % rounding down (floor)
[ind,qY] = quantiz(Y,partition,codebook);  % Obtention of quantized signal (qY)

% ----------Quantization error sequence---------- %
EqY = Y - qY;  % Discrete sequence: quantiz. error

% ---------- Auto-correlation quantization error seq. ---------- %
R_EqY_EqY = ifft(fft(EqY.*conj(fft(EqY))));

% ----------Circular Cross-correlation of input signal(Y) and Quantiz. err. sequence (EqY) ---------- %
C_Y_EqY = ifft(fft(Y.*conj(fft(EqY))));

% ----------Single-Sided Amplitude Spectrum of EqY---------- %
L = length(EqY);             % Length of signal
Eq1f = fft(EqY);
P2 = abs(Eq1f/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(L/2))/L;

% ----------Plotting---------- %
figure(1)
subplot(2,1,1)
plot(t, Y,'x')
hold on;

plot(t,qY,'o')
title('Sampled and quantized signal')
xlabel('Time (t)')
ylabel('Amplitude')
legend('Original sampled signal','Quantized signal');
xlim([0 t2])
grid

subplot(2,1,2)
plot(t,EqY,'o')
title('Quantization error amplitude')
xlabel('Time (t)')
ylabel('EqY(t)')
axis([0 t2 min(EqY) max(EqY)])
grid

figure(2)
subplot(3,1,1)
plot(t(1:end),R_EqY_EqY(1:end),'o')
title('Auto-correlation of Quantiz. err. seq (EqY)')
xlabel('Time (t)')
ylabel('R_EqY_EqY (t)')
grid

subplot(3,1,2)
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of e[n]')
xlabel('f (Hz)')
ylabel('P1(f)')
grid

subplot(3,1,3)
plot(f,20*log(P1)) 
title('Single-Sided Amplitude Spectrum of e[n]')
xlabel('f (Hz)')
ylabel('P1(f)[dB]')
grid