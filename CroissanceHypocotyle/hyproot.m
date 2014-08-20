function [P]=hyproot(R,S,Smax)
%[P]=hyproot(R,S,Smax)

P=zeros(length(S),1);
I=find(R{end}==max(R{end}(S{end}<Smax)));

%F=ezfit(S{end}(I-3:I+3)-S{end}(I), R{end}(I-3:I+3),'-a*(x-b)^2+c;log',[1/0.01 0 1]);
P(end,1)=S{end}(I);%+F.m(2);

for k=fliplr(1:length(R)-1)

    I1=find(S{k}<S{k+1}(I),30,'last');
    I2=find(S{k}>S{k+1}(I),30,'first');

    %plot([I1;I2],diam{k}([I1;I2]));drawnow;
    I=find(R{k}==max(R{k}([I1;I2])));

    %F=ezfit(S{k}(I-3:I+3)-S{k}(I), R{k}(I-3:I+3),'-a*(x-b)^2+c;log',[1/0.01 0 1]);
    P(k,1)=S{k}(I);%+F.m(2);
    
    
end