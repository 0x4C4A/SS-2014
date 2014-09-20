function [Wk] = wal( k, x )
%Volða sakârtojums
%   Funkcija wal(k, x)  ìenerç <k> kârtas Volða sakârtojuma vçrtîbas
%   atbilstoði normçtâ laika vektoram <x> = [t/T] 
n  = round(log2(k))+1;     % Rademahera funkcijas kârta
r = [];                    % Matrica Rademahera funkciju saglabâðanai
for i  = 1:n;
    r (i, :) = sign(sin(2^i*pi*x));
end

Wk = prod(r);
end

