function a=nm(A,i)

if (i<10)
    a=[A '00' int2str(i)] ;      
elseif(i<100)
    a=[A '0' int2str(i)];
else
    a=[A  int2str(i)];
end