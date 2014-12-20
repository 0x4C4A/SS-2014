% Signâli un sistçmas 5. laboratorijas darbs
% == Kvazioptimâls 1 pola Batervorta filtrs ==
% Signâls - pusviïòa sinusoîda
clear all
% Simulâcijas parametri
samples = 2^10;
T    = 5;
t    = linspace(0, T, samples);
sampTime = T/samples;
sampRate = 1/sampTime;
% Analizçjamais signâls
x0 = [ones(1, samples/2), zeros(1, samples/2)];%.*sin(2*pi*t);
E0 = sum(x0.^2)*sampTime; %% Signâla enerìija
SNR = 1; %% Signâls/Troksnis [dB]. Psign = 0 dBW
sigma_x = 10^(-SNR/20);
% Datu sagataves
nw = 15; % nogrieðanas frekvenèu skaits
nn = 100; % simulâciju skaits
wc = linspace(0.001, 5, nw);
Ai = zeros(nn, nw);
sigma_y = Ai;
% Troksnis
for n = 1:nn
nx = awgn(zeros(1, length(t)), SNR); % pienâkoðais troksnis
x1 = x0+nx;
for i = 1:nw
% Batervorta filtrs (1 pols)
h = wc(i)*exp(-t.*wc(i)); 
% Izejas signâls
y0 = conv(x0, h).*sampTime;
y1 = conv(x1, h).*sampTime;
ny = conv(nx, h).*sampTime;%y1(1:samples)-y0(1:samples);
sigma_y = rms(ny(1:samples));
maxy = abs(max(y0));
Ai(n, i) = maxy/sigma_y;
end
end
A = mean(Ai, 1);
[Amax, imax] = max(mean(A, 1));
plot(wc, A), grid on
 title('Signâla maksimâlâs vçrtîbas attiecîba pret trokðòa efektîvo vçrtîbu izejâ')
 xlabel('\omega_c'), ylabel('A')
% Optimâls filtrs
G0 = sigma_x^2*sampTime*2;  %Pareizi
Aopt = sqrt(2*E0/G0);
sprintf('Ðâds kvazioptimâls filtrs sniedz %.2f %% no tâ, \n ko varçtu iegût ar optimâlu filtru', Amax/Aopt*100)
