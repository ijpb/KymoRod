function [SK diam ordre]=branche(V,V_F,F,dist,jp,j,m,pere)
%[SK diam ordre]=branche(V,V_F,F,dist,jp,j,m,pere)

persistent N SQ4 diam2 ordre2;

hold on;
if pere==0 && m==0
    N = 1;
    SQ4=[];
    diam2=[];
    ordre2=[];
end


i=1;
SK1(i,1)=V(j,1);
SK1(i,2)=V(j,2);
diam1(i)=dist(j);

if V_F(j)<3
    jind=find(F{j}~=jp);
    jp=j;
    j=F{j}(jind);
    V_F(j)=V_F(j)-1;
    while V_F(j)==1
        i=i+1;
        SK1(i,1)=V(j,1);
        SK1(i,2)=V(j,2);
        diam1(i)=dist(j);

        jind=find(F{j}~=jp);
        jp=j;
        j=F{j}(jind);
        V_F(j)=V_F(j)-1; 
    end
end

SQ4{N}=SK1;
diam2{N}=diam1;
    %ordre2
if N==1
    ordre2{N}=1;
else
    ordre2{N}=[ordre2{pere} N];
end
pere=N;
if V_F(j)>1
    
    jind=find(F{j}~=jp);
    j2=F{j}(jind);
    N=N+1;
    branche(V,V_F,F,dist,j,j2(1),1,pere);
    N=N+1;    
    branche(V,V_F,F,dist,j,j2(2),2,pere);    
end

SK=SQ4;
diam=diam2;
ordre=ordre2;