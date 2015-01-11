% Signâli un sistçmas 6. laboratorijas darbs
% == Automâtiskas frekvenèu pieskaòoðanas pçtîðana ==
dt = 1e-3;  % Laika solis
n  = 2;     % Filtra kârta
wn = 3;     % Filtra nogriðanas frekvence
dw_s =2;    % Ieejas signâla frekvences izmaiòa (sâkuma nosacîjums)
ASg  = 6;   % Pastiprinâjums A*S_g
% Simulâcija
load_system('simul6');
sim('simul6');
% Datu attçloðana
dpsi(1) = dw_s;   % Punkts ar sâkuma nosacîjumu
figure(1)
subplot(211)
plot(psi, dpsi, '-k'), grid on,
title('Fâzu trajektorija'), xlabel('\psi, rad'), ylabel('\psi\prime, rad/s')
subplot(212)
plot(ScopeData(:,1), ScopeData(:,2), '-k'), grid on,
title('Ìeneratora frekvences laika diegramma'), xlabel('t, s'), ylabel('\omega_g, rad/s')

