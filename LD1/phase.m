d  = 0.01;
x1 = 0:d:1;
x2 = 1+d:d:2;
y1 = sin(pi*x1);
y2 = zeros([1, length(x2)]);
x  = [x1, x2];
y  = [y1, y2];

plot(angle(fft(y)))
