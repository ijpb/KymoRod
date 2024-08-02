function [ Enorm1 Enorm2]= displnorm(E2,E1)
%Enorm= displnorm(E2,Phh)
Enorm1=E1;
Enorm2=E2;
step=E2{1}(1,1)-E1{1}(1,1);
for k=1:length(E2)
    
    I=find(E2{k}(:,1)-step>0,1,'first');
    if isempty(I)==1
        I=1;
    end
    if I>10 && I<length(E2{k})-10
        Enorm1{k}(:,2)=E2{k}(:,2)-mean(E2{k}(I-10:I+10,2));
    else
        Enorm1{k}(:,2)=E2{k}(:,2)-E2{k}(I,2);
    end
    Enorm2{k}(:,2)=Enorm1{k}(:,2);
end

