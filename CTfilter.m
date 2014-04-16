function CTf=CTfilter(CT,a,sym)

N=size(CT,1);
N2=floor(N/2);
if 2*N2==N
    un=0;
else
    un=-1;
end
w = (-N+1:N);  % centered frequency vector

H1=a./(a+1i.*w); %exp(-w.^2/a.^2);%     % centered version of H
H2=a./(a+1i.*w);
Hshift = [fftshift(H1)' fftshift(H2)']; 

switch sym
    case 'droit'
        CTsym(:,1)=[flipud(CT(1:N2,1));CT(:,1);flipud(CT(N2+1:end,1))];
        CTsym(:,2)=[2*CT(1,2)-flipud(CT(1:N2,2));CT(:,2);2*CT(end,2)-flipud(CT(N2+1:end,2))];
        H(:,2) = a ./ (a + 1i.*w);
        dim=2;
    case 'droit2'
        A1=angle3(CT(1,:),[1 0],CT(20,:));
        %A2=angle3(CT(end,:),[1 0],CT(end-20,:));
        A2=A1;
        x1=CT(1,1)-(N2:-1:1).*abs(CT(1,1)-CT(2,1));
        x2=CT(end,1)-(1:N-N2).*abs(CT(1,1)-CT(2,1));
        
        y1=CT(1,2)+(x1-CT(1,1))*tan(A1);
        y2=CT(end,2)+(x2-CT(end,1))*tan(A2);
        
        CTsym(:,1)=[x1';CT(:,1);x2'];
        CTsym(:,2)=[y1';CT(:,2);y2'];
       
        dim=2;
    case 'boucle'
        CTsym(:,1)=[CT(N2+1:end,1);CT(:,1);CT(1:N2,1)];
        CTsym(:,2)=[(CT(N2+1:end,2));CT(:,2);(CT(1:N2,2))];
        H(:,2) = a ./ (a + 1i.*w);
        dim=2;        
    case 'penche'   
        CTsym(:,1)=[2*CT(1,1)-flipud(CT(1:N2,1));CT(:,1);2*CT(1,1)-flipud(CT(N2+1:end,1))];
        CTsym(:,2)=[flipud(CT(1:N2,2));CT(:,2);flipud(CT(N2+1:end,2))];
        dim=2;
    case 'penche2'
        CTsym(:,1)=[2*CT(1,1)-(CT(N2+1:end,1));CT(:,1);2*CT(1,1)-(CT(1:N2,1))];
        CTsym(:,2)=[CT(1,2)+CT(end,2)-(CT(N2+1:end,2));CT(:,2);CT(end,2)+CT(1,2)-(CT(1:N2,2))];
        dim=2;       
    case 'dep'
        CTsym(:,1)=[-flipud(CT(1:N2,1));CT(:,1);CT(end,1)+flipud(CT(N2+1:end,1))];
        CTsym(:,2)=[-flipud(CT(1:N2,2));CT(:,2);flipud(CT(N2+1:end,2))];
        Hshift(:,1)=ones(size(Hshift(:,1)));
        dim=2;
    case 'rien'
        CTsym=CT;
        dim=2;
    otherwise
        disp('fais gaffe mec tu t''es gourre');
        dim=0;
end
for k=1:dim
    
    X(:,k) = fft(CTsym(:,k));
    X(:,k)=X(:,k).* Hshift(:,k);
    x(:,k)=real(ifft(X(:,k)));
    CTf(:,k)=x(N2+1:end-N2+un,k);
    CTf(:,k)=moving_average(CTf(:,k),10);
end

