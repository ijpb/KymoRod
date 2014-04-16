function [ElgR anis]=elongrad(Elg,S,s0,R,t0)
%[ElgR anis]=elongrad(Elg,S,s0,R,t0)

t0=t0*60;
step=10;%length(R)-length(Elg);
ElgR=Elg;
anis=ElgR;
steps=5;
parfor k=1:length(R)-step
    IE0=find(Elg{k}(:,1)>s0,1,'first');
    ElgR{k}(:,1)=Elg{k}(:,1);
    anis{k}(:,1)=Elg{k}(:,1);
    for j=1:length(Elg{k})
        IE1=find(Elg{k}(:,1)>Elg{k}(j,1),1,'first');
        IR1=find(S{k}(:,1)>Elg{k}(j,1),1,'first');
        IR2=find(S{k+step}(:,1)>Elg{k}(j,1),1,'first');

        if isempty(IR1)==1            
            IR1=length(R{k});
        end
        if isempty(IR2)==1            
            IR2=length(R{k+step}); 
        end
        
        v=integrate(Elg{k},IE0,IE1);
        stepsmax=min([IR1+steps length(R{k})]);
        stepsmin=max([IR1-steps 1]);
        gradR=(R{k}(stepsmax,1)-R{k}(stepsmin,1))./(S{k}(stepsmax,1)-S{k}(stepsmin,1));
        ElgR{k}(j,2)=v.*gradR+(R{k+step}(IR2,1)-R{k}(IR1,1))./(step.*t0.*R{k}(IR1,1));        
    end
    anis{k}(:,2)=ElgR{k}(:,2)./Elg{k}(:,2);
end