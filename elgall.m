function [Elg E2]=elgall(E,t0,step,ws)
%[Elg E2]=elgall(E,t0,step)

E2=E;
parfor_progress(length(E));

parfor i=1:length(E)
   
    if length(E{i})>20
        E2{i}=aberrant3(E{i});
        Elg{i}=displelg(E2{i},t0,step,ws);        
    else
        Elg{i}=[0 0;1 0];
    end
    parfor_progress;

end
parfor_progress(0);
