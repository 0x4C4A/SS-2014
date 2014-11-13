% 4. LD sign�li un sist�mas. Frekvences modul�ta sign�la krop�ojumi LC
% filtr�
%% Laika parametri
samples = 1024*8;
t   = linspace(0, 2e-1, samples);
sampTime = max(t)/samples;
sampRate = 1/sampTime;
w  = 2*pi*(0:1/max(t):sampRate-1/max(t));

%% Ieejas sign�ls
f0 = 1e3; w0 = 2*pi*f0;      % Nes�jfrekvence
dw = 2*pi*200;  %Devi�cija
w1 = w0-dw/2;
w2 = w0+dw/2;  
FMin = [sin(w1*t(1:round(samples/2))), sin(w2*t(round(samples/2+1):end))];
%% Apr��ini
%Sagataves datiem par aiztures laiku
steps = 200;
delay = zeros(1, steps);
B  = zeros(1, steps);
ns = 1;
for R = linspace(0.01, 300, steps);
    %Filtra elementi
    L = 1e-3;  % Pa��mu t�du spoli
    C = 1/(w0^2*L);
    Q = sqrt(L/C)*R/(R+sqrt(L/C));
    %P�rvades raksturl�kne (Paral�lais kont�rs)
    K = abs(1i*w./((1i*w).^2*R*C+1i.*w+R/L));
    %Impulsa reakcija
    b = [0 1];
    a = [R*C 1 R/L];
    [r, p, k] = residue(b, a);
    h = r(1)*exp(p(1)*t)+r(2)*exp(p(2)*t);
    %Izejas sign�ls
    FMout = conv(FMin, h);
    freqOut = fmdemod(FMout, f0, sampRate, dw/2/pi);
    %Aiztures laika noteik�ana
    tresh = 0.8*0.5; % Slieksnis
    for i = samples/2:samples
        if freqOut(i)>=tresh
            break
        end
    end
    delay(ns) = t(i)-t(samples/2);
    B(ns)     = dw*Q/w0;
    ns = ns+1;
    % Dinamisks izejas sign�la frekvences grafiks
     plot(t, freqOut(1:samples), '-b',...
        [min(t), max(t)], [tresh tresh], '--r',...
        t(samples/2), tresh, '.r', ...
        t(i), freqOut(i), '.r', 'MarkerSize', 20), grid on, ylim([-1 1])
    pause(0.01)
end
% Aiztures atkar�b� no filtra un sign�la devi�cijas
 figure(2)
 semilogx(1./B, delay*1e3), grid on
 xlabel('{\Delta}w/w_{dev}'), ylabel('t_{aiztures} [ms]')
 title('Aiztures atkar�b� no filtra caurlaides joslasa un sign�la devi�cijas')
 
