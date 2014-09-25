function [walshMatrix] = wal( N )
%Volða sakârtojuma matrica
%   Funkcija wal( N ), kur N = 2^i, ìenerç <N> kârtas kvadrâtisku  
%   Volða sakârtojuma matricu, ar dimensijâm NxN.
walshMatrix = fwht(eye(N)).*N;
end
