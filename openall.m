function col=openall(color)


N=dir(strcat(color,'*'));
col=cell(length(N),1);

parfor i=1:length(N)
    col{i}=imread(N(i).name);
end
 