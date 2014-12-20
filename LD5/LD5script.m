% Sign�li un sist�mas 5. laboratorijas darbs
% == Kvazioptim�ls 1 pola Batervorta filtrs ==
% Sign�ls - pusvi��a sinuso�da
clear all
% Simul�cijas parametri
samples = 2^10;
T    = 5;
t    = linspace(0, T, samples);
sampTime = T/samples;
sampRate = 1/sampTime;
% Analiz�jamais sign�ls
x0 = [ones(1, samples/2), zeros(1, samples/2)];%.*sin(2*pi*t);
E0 = sum(x0.^2)*sampTime; %% Sign�la ener�ija
SNR = 1; %% Sign�ls/Troksnis [dB]. Psign = 0 dBW
sigma_x = 10^(-SNR/20);
% Datu sagataves
nw = 15; % nogrie�anas frekven�u skaits
nn = 100; % simul�ciju skaits
wc = linspace(0.001, 5, nw);
Ai = zeros(nn, nw);
sigma_y = Ai;
% Troksnis
for n = 1:nn
nx = awgn(zeros(1, length(t)), SNR); % pien�ko�ais troksnis
x1 = x0+nx;
for i = 1:nw
% Batervorta filtrs (1 pols)
h = wc(i)*exp(-t.*wc(i)); 
% Izejas sign�ls
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
 title('Sign�la maksim�l�s v�rt�bas attiec�ba pret trok��a efekt�vo v�rt�bu izej�')
 xlabel('\omega_c'), ylabel('A')
% Optim�ls filtrs
G0 = sigma_x^2*sampTime*2;  %Pareizi
Aopt = sqrt(2*E0/G0);
sprintf('��ds kvazioptim�ls filtrs sniedz %.2f %% no t�, \n ko var�tu ieg�t ar optim�lu filtru', Amax/Aopt*100)
