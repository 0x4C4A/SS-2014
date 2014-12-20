% Sign�li un sist�mas 5. laboratorijas darbs
% == Kvazioptim�ls 1 pola Batervorta filtrs ==
%      ---SIMMULINK---
samples = 2^12;
T = 30;
dt = T/samples;
tau = 1;
wc = linspace(0.01, 5, 20);
sigma2x = 10^(-1/10);
n0 = 10;
A = zeros(n0, length(wc));
load_system('simul')
h = waitbar(0, sprintf('Simul�cijas progresss 0/%d', (n0*length(wc))));
for n = 1:n0
    seed = randseed;
for i = 1:length(wc)
    DenomStr = sprintf('%g', wc(i));
    set_param('simul/Analog Filter Design', 'Wlo', DenomStr);
    set_param('simul/Analog Filter Design1', 'Wlo', DenomStr);
    sim('simul');
    A(n, i) = Asim;
    waitbar((i+length(wc)*(n-1))/(n0*length(wc)), h,...
        sprintf('Simul�cijas progresss %d/%d', (i+length(wc)*(n-1)), (n0*length(wc))));
end
end
G0 = sigma2x*2*dt;
Aopt = sqrt(2*E0/G0)
close(h)
plot(wc*tau, mean(A, 1)/Aopt), grid on
 title('Sign�la maksim�l�s v�rt�bas attiec�ba pret trok��a efekt�vo v�rt�bu izej�')
 xlabel('x = \tau\times \omega_c'), ylabel('A/A_{opt}')
 