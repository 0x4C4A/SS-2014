w = 0:0.01:10;
s = 1i*w;
H = 1./(1.4142*s+s.^2+1);
% Amplitûdas aizture
plot(w(1:end-1), -diff(angle(H)))
title('Amplitûdas aizture'), xlabel('\omega'), grid on
% Fâzes aizture
figure(2)
plot(w, -angle(H)./w), title('Fâzes aizture'), xlabel('\omega')
grid on