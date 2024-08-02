function F = hmax( A )
% F = hmax( A )
%Trace la fondtion des maximas verticaux de A

[s1 s2]=size(A);

for k=1:s2
    F(k,1)=find(A(:,k)==max(A(:,k)));
end

