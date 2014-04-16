function S_n=cleandouble(S)
%Enleve les points du contour en double

d_S=abs(S-circshift(S,1));
d_S=sum(d_S')'==0;
d_S=d_S-circshift(d_S,1);
f_pos=find(d_S==1);
f_neg=find(d_S==-1);
s_f=length(f_pos);
S_n=S;
for i=1:s_f
  S_n(f_pos(i):f_neg(i)-1,:)=0;
end
S_n=S_n(S_n(:,1)>0,:);


    