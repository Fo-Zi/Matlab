% SCRIPT - 2nd Ziegler-Nichols method - %
% To apply the 2nd method we need a system that can present %
% a pure oscillatory output by only changing its gain.       %

% System to be compensated %
s = tf('s');
G = 0.5*(s+3)/((s+1)*(s+0.2)*(s+0.01));
T1 = feedback(G/100,1) 

% Transfer function for: K=Kcrit -> Pure oscillation %
Kc = margin(G);
Tosc = feedback(G*Kc,1)

% Obtention of the period of the output signal %
t = 0:0.1:100;
yosc = step(Tosc,t);
[p,peaks] = findpeaks(yosc);
Tc = mean(diff(t(peaks)))
%Tc = 11.21;  

% PID parameters %
Kp = 0.6 * Kc;
Ti = 0.5 * Tc ;
Td = 0.125 * Tc;
Gpid = Kp * ( Ti*Td*(s^2) + Ti*s + 1 ) / (Ti*s) 

% Transfer function of the compensated system %
Tcomp = feedback(G*Gpid,1)
%ycomp = step(Tcomp,t);
%[q,peaks] = findpeaks(ycomp);

% Root locus of the uncompensated system %
figure(1)
rlocus(G)
title('R-Locus of System Transfer function')
grid

% Unit step response of the closed-loop system %
figure(2)
step(T1,100)
title('Unit step response of the closed-loop system')
grid

% Oscillatory response of the system %
figure(3)
step(Tosc,100)
title('Closed loop oscillatory step response')
grid

% Compensated system response %
figure(4)
step(Tcomp,100)
title('Rta temporal de la planta compensada')
grid