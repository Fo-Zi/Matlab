% SCRIPT - IIR filtering analysis %
% v1.0

% BRIEFING %
% This script analyzes the frequency response of "Exponential Moving Average"(EMA) IIR filters.  %
% With that purpose, the approach is to work with its corresponding Z transform expressions, and %
% to analyze the N-th order implementation using cascaded 1st order EMA's, as it's one of the    %
% most common implementations in embedded systems, bc it presents an efficient implementation,   %
% in terms of memory usage, execution performance and frequency response.                        %


% -------------------- Reference constants -------------------- %
fs = 1*10^6;            % Sampling frequency
ALPHAd = 0.997;        % Filter parameter
ALPHA = single(ALPHAd);   
n=50000;

% Stable filters:
% 1st order - 0.9999 - 500Hz/-30dB
% 2nd order - 0.9997 - 500Hz/-40dB
% 2nd order - 0.9995 - 500Hz/-32dB
% 2nd order - 0.9990 - 500Hz/-20dB

% The obtention of cascaded transforms is obtained by polynomial expressions/products %
% -------------------- 1st order IIR filter -------------------- %
a = [1 -ALPHA];    
a_d = [1 -ALPHAd];

% ---------- 2nd order IIR filter -> 2 cascaded single pole IIR ---------- %
b1 = [1 -ALPHA];
b2 = [1 -ALPHA];
b = conv(b1,b2);

b1_d = [1 -ALPHAd];
b2_d = [1 -ALPHAd];
b_d = conv(b1_d,b2_d);

% ---------- 3rd order IIR filter -> 3 cascaded single pole IIR ---------- %
c1 = [1 -ALPHA];
c2 = [1 -ALPHA];
c3 = [1 -ALPHA]; 
c = conv(c3,conv(c1,c2));

c1_d = [1 -ALPHAd];
c2_d = [1 -ALPHAd];
c3_d = [1 -ALPHAd]; 
c_d = conv(c3_d,conv(c1_d,c2_d));

% ---------- N-th order IIR filter -> N cascaded single pole IIR ---------- %
N1=6;
d = [1];
for i = 1:N1
    aux = [1 -ALPHA];
    d = conv(d,aux);
end

d_d = [1];
for i = 1:N1
    aux = [1 -ALPHAd];
    d_d = conv(d_d,aux);
end

% ---------------- Freq. response of the filters ---------------- %

%---------- Float implementation: ---------- %
[h1,f] = freqz(1-ALPHA,a,n,fs);
[h2,f] = freqz((1-ALPHA)^2,b,n,fs);
[h3,f] = freqz((1-ALPHA)^3,c,n,fs);
[hN,f] = freqz((1-ALPHA)^N1,d,n,fs);

h1_dB = 20*log10(abs(h1));
h2_dB = 20*log10(abs(h2));
h3_dB = 20*log10(abs(h3));
hN_dB = 20*log10(abs(hN));

%---------- Double implementation: ---------- %
[h1_d,f] = freqz(1-ALPHAd,a_d,n,fs);
[h2_d,f] = freqz((1-ALPHAd)^2,b_d,n,fs);
[h3_d,f] = freqz((1-ALPHAd)^3,c_d,n,fs);
[hN_d,f] = freqz((1-ALPHAd)^N1,d_d,n,fs);

h1_dB_d = 20*log10(abs(h1_d));
h2_dB_d = 20*log10(abs(h2_d));
h3_dB_d = 20*log10(abs(h3_d));
hN_dB_d = 20*log10(abs(hN_d));

% -------------------- Cutoff frequencies -------------------- %
% If you able this section you can obtain the -3dB frequencies %
%{
[c1 ind1] = min(abs(20*log10(abs(h1))+3));
[c2 ind2] = min(abs(20*log10(abs(h2))+3)); 
[c3 ind3] = min(abs(20*log10(abs(h3))+3));
%}

% -------------------- Step-function response -------------------- %
%---------- Float implementation: ---------- %
[sr1,t1] = stepz((1-ALPHA),a,n,fs);
[sr2,t2] = stepz((1-ALPHA)^2,b,n,fs);
[sr3,t3] = stepz((1-ALPHA)^3,c,n,fs);
[srN,tN] = stepz((1-ALPHA)^N1,d,n,fs);

%---------- Double implementation: ---------- %
[sr1_d,t1_d] = stepz((1-ALPHAd),a_d,n,fs);
[sr2_d,t2_d] = stepz((1-ALPHAd)^2,b_d,n,fs);
[sr3_d,t3_d] = stepz((1-ALPHAd)^3,c_d,n,fs);
[srN_d,tN_d] = stepz((1-ALPHAd)^N1,d_d,n,fs);

% ---------------------------- Plotting ---------------------------- %
% ---------- Fig.1 ---------- %
f1 = figure;
p1 = uipanel('Parent',f1,'BorderType','none'); 
p1.Title = 'Frequency response - IIR filters'; 
p1.TitlePosition = 'centertop'; 
p1.FontSize = 12;
p1.FontWeight = 'bold';

figure(1)

subplot(2,2,1,'Parent',p1)
plot(f,h1_dB)
title('Single implementation:')
hold on
plot(f,h2_dB)
hold on
plot(f,h3_dB)
hold on
plot(f,hN_dB)

xlim([0 50000])
xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
legend('1st order filter','2nd order filter','3rd order filter','N-th order filter');
grid

subplot(2,2,3,'Parent',p1)
plot(f,angle(h1))
hold on
plot(f,angle(h2))
hold on
plot(f,angle(h3))
hold on
plot(f,angle(hN))
xlim([0 50000])

xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
legend('1st order filter','2nd order filter','3rd order filter','N-th order filter');
grid

subplot(2,2,2,'Parent',p1)
plot(f,h1_dB_d)
title('Double implementation:')
hold on
plot(f,h2_dB_d)
hold on
plot(f,h3_dB_d)
hold on
plot(f,hN_dB_d)
xlim([0 50000])

xlabel('Frequency [Hz]')
ylabel('Magnitude [dB]')
legend('1st order filter','2nd order filter','3rd order filter','N-th order filter');
grid

subplot(2,2,4,'Parent',p1)
plot(f,angle(h1_d))
hold on
plot(f,angle(h2_d))
hold on
plot(f,angle(h3_d))
hold on
plot(f,angle(hN_d))
xlim([0 5000])

xlabel('Frequency [Hz]')
ylabel('Phase [deg]')
legend('1st order filter','2nd order filter','3rd order filter','N-th order filter');
grid

% ---------- Fig.2 ---------- %
f2 = figure;
p2 = uipanel('Parent',f2,'BorderType','none'); 
p2.Title = 'Unit-step response of IIR filters'; 
p2.TitlePosition = 'centertop'; 
p2.FontSize = 12;
p2.FontWeight = 'bold';

figure(2)

subplot(4,2,1,'Parent',p2)
plot(t1,sr1)
title('Single implementation:')
xlabel('Time [t]')
ylabel('Amplitude')
legend('1st order IIR');
grid

subplot(4,2,3,'Parent',p2)
plot(t2,sr2)
xlabel('Time [t]')
ylabel('Amplitude')
legend('2nd order IIR');
grid

subplot(4,2,5,'Parent',p2)
plot(t3,sr3)
xlabel('Time [t]')
ylabel('Amplitude')
legend('3rd order IIR');
grid

subplot(4,2,7,'Parent',p2)
plot(tN,srN)
xlabel('Time [t]')
ylabel('Amplitude')
legend('Nth order IIR');
grid

subplot(4,2,2,'Parent',p2)
plot(t1_d,sr1_d)
title('Double implementation:')
xlabel('Time [t]')
ylabel('Amplitude')
legend('1st order IIR');
grid

subplot(4,2,4,'Parent',p2)
plot(t2_d,sr2_d)
xlabel('Time [t]')
ylabel('Amplitude')
legend('2nd order IIR');
grid

subplot(4,2,6,'Parent',p2)
plot(t3_d,sr3_d)
xlabel('Time [t]')
ylabel('Amplitude')
legend('3rd order IIR');
grid

subplot(4,2,8,'Parent',p2)
plot(tN_d,srN_d)
xlabel('Time [t]')
ylabel('Amplitude')
legend('Nth order IIR');
grid
