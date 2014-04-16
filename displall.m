function E=displall(SK,S,pic,scale,shift,ws,we,step)
%E=displall(SK,S,pic,scale,shift,ws,we,step)

E=cell(length(SK)-step,1);
parfor_progress(length(SK));

parfor i=1:length(SK)-step
   

    if length(SK{i})>2.*80 && length(SK{i+step})>2.*80
        E{i}=elong5(SK{i},SK{i+step},S{i},S{i+step},pic{i},pic{i+step},scale,shift{i},shift{i+step},ws,we); 
        if size(E{i},1)==1
            E{i}=[1 0;1 1];
        end
            
    else
        E{i}=[1 0;1 1];
        
    end
    parfor_progress;

end
parfor_progress(0);
