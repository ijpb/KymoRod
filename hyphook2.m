function [P]=hyphook2(R)
%[P]=hyphook2(R)

R{end}(:,2)=abs(R{end}(:,2));
P=zeros(length(R),1);
I=find(R{end}(:,2)==max(R{end}(end-150:end,2)));
P(end,1)=R{end}(I,1);

for k=fliplr(1:length(R)-1)
    if isempty(R{k})==0 

    R{k}(:,2)=abs(R{k}(:,2));
    I1=find(R{k}(:,1)<R{k+1}(I,1),30,'last');
    I2=find(R{k}(:,1)>R{k+1}(I,1),30,'first');

    %plot([I1;I2],diam{k}([I1;I2]));drawnow;
    I=find(R{k}(:,2)==max(R{k}([I1;I2],2)));

    
    P(k,1)=R{k}(I,1);
    
    else
        R{k}=R{k-1};
       P(k,1)=P(k+1,1);
    end
end