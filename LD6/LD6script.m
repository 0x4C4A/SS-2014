% Sign�li un sist�mas 6. laboratorijas darbs
% == Autom�tiskas frekven�u pieska�o�anas p�t��ana ==
dt = 1e-3;  % Laika solis
n  = 2;     % Filtra k�rta
wn = 3;     % Filtra nogri�anas frekvence
dw_s =2;    % Ieejas sign�la frekvences izmai�a (s�kuma nosac�jums)
ASg  = 6;   % Pastiprin�jums A*S_g
% Simul�cija
load_system('simul6');
sim('simul6');
% Datu att�lo�ana
dpsi(1) = dw_s;   % Punkts ar s�kuma nosac�jumu
figure(1)
subplot(211)
plot(psi, dpsi, '-k'), grid on,
title('F�zu trajektorija'), xlabel('\psi, rad'), ylabel('\psi\prime, rad/s')
subplot(212)
plot(ScopeData(:,1), ScopeData(:,2), '-k'), grid on,
title('�eneratora frekvences laika diegramma'), xlabel('t, s'), ylabel('\omega_g, rad/s')

