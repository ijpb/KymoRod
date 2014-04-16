function [A C]=curvature(SK,S,ws)

%Computation of the curvature C and the orientation A of a line SK with the
%the curvilinear abscissa S along SK
n=length(S);


A=zeros(n,1);
C=zeros(n,1);

%Computation of the angle A according to the vertical
A=CTangle2(SK,ws);

%The derivation of the angle A along the curvilinear abscissa S gives the 
%curvature C 
 
A(1:ws)=A(ws+1);            %� virer pour retrouver les anciens r�sultats ne pas oublier de corriger l'intervalle de calcul de courbure
A(n-ws:end)=A(end-ws-1);    %avec ca
A=moving_average(A,ceil(ws/2));     %et ca


for i=ws+1:n-ws
    C(i)=(A(i+ws)-A(i-ws))/(S(i+ws)-S(i-ws));
end

C(1:ws)=(1:ws).*C(ws+1)/ws; %ca de meme pour avoir les points sur laquelle on a pas de courbure
C(n-ws:end)=(ws-(1:ws+1)).*C(end-ws-1)/ws; %et ca pour etre tranquille

C=moving_average(C,ceil(ws/2)); % et puis on d�gagera ca aussi


