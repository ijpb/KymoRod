function I=integrate(A,s0,s1)
%I=integrate(A,s0,s1)

if s0>s1
    a0=s1;
    a1=s0;
    sgn=-1;
else
    a0=s0;
    a1=s1;
    sgn=+1;
end
if a0==1
    a0=2;
end
A(isnan(A(:,2)),2)=0;
I=sgn.*sum(A(a0:a1,2).*(A(a0:a1,1)-A(a0-1:a1-1,1)));