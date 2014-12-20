% Signâli un sistçmas 5. laboratorijas darbs
% == Kvazioptimâls 1 pola Batervorta filtrs ==
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
h = waitbar(0, sprintf('Simulâcijas progresss 0/%d', (n0*length(wc))));
for n = 1:n0
    seed = randseed;
for i = 1:length(wc)
    DenomStr = sprintf('%g', wc(i));
    set_param('simul/Analog Filter Design', 'Wlo', DenomStr);
    set_param('simul/Analog Filter Design1', 'Wlo', DenomStr);
    sim('simul');
    A(n, i) = Asim;
    waitbar((i+length(wc)*(n-1))/(n0*length(wc)), h,...
        sprintf('Simulâcijas progresss %d/%d', (i+length(wc)*(n-1)), (n0*length(wc))));
end
end
G0 = sigma2x*2*dt;
Aopt = sqrt(2*E0/G0)
close(h)
plot(wc*tau, mean(A, 1)/Aopt), grid on
 title('Signâla maksimâlâs vçrtîbas attiecîba pret trokðòa efektîvo vçrtîbu izejâ')
 xlabel('x = \tau\times \omega_c'), ylabel('A/A_{opt}')
 