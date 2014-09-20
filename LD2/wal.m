function [Wk] = wal( k, x )
%Vol�a sak�rtojums
%   Funkcija wal(k, x)  �ener� <k> k�rtas Vol�a sak�rtojuma v�rt�bas
%   atbilsto�i norm�t� laika vektoram <x> = [t/T] 
n  = round(log2(k))+1;     % Rademahera funkcijas k�rta
r = [];                    % Matrica Rademahera funkciju saglab��anai
for i  = 1:n;
    r (i, :) = sign(sin(2^i*pi*x));
end

Wk = prod(r);
end

