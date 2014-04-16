function S=curvilin(SK)
%S=curvilin(SK)
%Compute the curvilinear abscissa S of a line SK

S=zeros(length(SK),1);
for i=2:length(SK)-1
    S(i)=((((SK(i+1,1)-SK(i-1,1)).^2)+((SK(i+1,2)-SK(i-1,2)).^2)).^(1/2))./(2)+S(i-1);
end

S(end)=2*S(end-1)-S(end-2);