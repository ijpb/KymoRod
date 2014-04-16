function A=CTangle2(CT,ws)

n=length(CT);

A=zeros(n,1);
T=zeros(n,1);
m=zeros(n,1);
i=ws+1;
T(i)=(CT(i+ws,1)-CT(i-ws,1))/(CT(i+ws,2)-CT(i-ws,2));
A(i)=atan(T(i));


%on calcule l'angle A de la courbe avec la verticale
for i=ws+2:n-ws
    T(i)=(CT(i+ws,1)-CT(i-ws,1))/(CT(i+ws,2)-CT(i-ws,2));
    A(i)=atan(T(i));   
    
    if CT(i+ws,2)-CT(i-ws,2)<0
        A(i)=A(i);
        if A(i)>0
            A(i)=A(i)-pi;
        else
            A(i)=A(i)+pi;
        end
    end
    

end



if(length(A(ws+1:n-ws))>2*ws)
    A(ws+1:n-ws)=moving_average(A(ws+1:n-ws),ws);
end

