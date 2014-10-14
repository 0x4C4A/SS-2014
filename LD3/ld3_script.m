% 3. laboratorijas darbs
% == Taisnstûra loga ietekme uz spektra analîzes precizitâti ==

% Simulâcijas laika parametri
samples = 128;
t_norm = linspace(0, 2, samples);
sample_time = max(t_norm)/samples;
sample_rate = 1/sample_time;

% Diskretizçta sinusoîda
d_sin = sin(2*pi*t_norm);

for width = max(t_norm)*sample_rate:-1:1
% Sinusoidas vçrtîbas skatoties caur logu
sinWin = d_sin(1,1:width);
% Diskrçts spektrs
S  = fft(sinWin)/length(sinWin);
fx = 0:1/(width*sample_time):sample_rate-1/(width*sample_time);

% Grafiki
subplot(2, 1, 1)
plot(t_norm(1,1:1:width), sinWin, '.k'), grid on, hold on
plot([t_norm(width),t_norm(width)], [-1, 1], '-r'), hold off
tit = sprintf('Loga platums: %0.1f %%', width*sample_time*100);
title(tit), xlabel('Normçts laiks [t/T]'), ylabel('Amplitûda')
axis([0, max(t_norm), -1, 1])
subplot(2, 1, 2)
plot(fx, abs(S), '.k'), grid on
title('Loga funkcijas ietekme uz signâla spektru')
xlabel('Normçta frekvence f/f_{sign}'), ylabel('|S(f)|')
axis([0, 10, 0, 0.8])
pause(0.05)
end
