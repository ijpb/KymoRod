function FF=ffts3(sig2,t)

%t=sig2(2,1)/60;

m=size(sig2,1);
fs=1/t;

f = (0:m-1)*(fs/m);

%y = fft(sig2(:,2),m);
g = fft2(sig2);
y=g';
FF(:,1)=f(1:ceil(end/2));
FF(:,2)=abs(y(1:ceil(end/2)));