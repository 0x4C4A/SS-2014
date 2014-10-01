w = 0:0.01:10;
s = 1i*w;
H = 1./(1.4142*s+s.^2+1);
% Amplit�das aizture
plot(w(1:end-1), -diff(angle(H)))
title('Amplit�das aizture'), xlabel('\omega'), grid on
% F�zes aizture
figure(2)
plot(w, -angle(H)./w), title('F�zes aizture'), xlabel('\omega')
grid on