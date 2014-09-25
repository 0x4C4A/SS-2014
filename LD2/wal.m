function [walshMatrix] = wal( N )
%Vol�a sak�rtojuma matrica
%   Funkcija wal( N ), kur N = 2^i, �ener� <N> k�rtas kvadr�tisku  
%   Vol�a sak�rtojuma matricu, ar dimensij�m NxN.
walshMatrix = fwht(eye(N)).*N;
end
