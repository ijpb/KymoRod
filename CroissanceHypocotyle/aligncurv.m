function [S dec]=aligncurv(S,A)
%ALIGNCURV align the curves
%[S dec]=aligncurv(S,A)
%
% S : the curvilinear abscissa 
% A : the radius
%
% Return the new curvilinear abscissa  S, an array of cell
% dec : shift between the two curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
nx=2000;
dec=zeros(length(S),1);

for k=1:length(S)
   S{k}=S{k}-S{k}(1); 
end
%parfor_progress(length(S));

for k=2:length(S)
    
    clearvars Corr C B S0;
    L0=S{k-1}(end)-S{k-1}(1);
    L1=S{k}(end);
    DL=L1./L0;
    
    if DL>1
        C=resampl(nx,A{k-1},S{k-1}-S{k-1}(1));
        B=resampl(nx.*DL,A{k},S{k});
        DL2=round(nx.*(DL-1));
        DS=-(S{k-1}(end)-S{k-1}(1))./nx;
    else
        DL=1./DL;
        B=resampl(nx.*DL,A{k-1},S{k-1}-S{k-1}(1));
        C=resampl(nx,A{k},S{k});
        DL2=round(nx.*(DL-1));
        DS=S{k}(end)./nx;
    end
    for j=1:DL2-1
        Corr(j,1)=DS*j;
        Corr(j,2)=corr2(B(j:end-DL2+j-1),C);
    end

    if DL2<2
        dec(k-1)=0;
    else
        I=find(Corr(:,2)==max(Corr(:,2)));
        if isempty(I)==0
            dec(k-1)=Corr(I,1);
        else
            dec(k-1)=0;
        end
    end
 
    S{k}=S{k}+dec(k-1)+S{k-1}(1);
    Smin(k)=S{k}(1);
       % parfor_progress;
end
%parfor_progress(0);
Sm=min(Smin);

for k=1:length(S)
   S{k}=S{k}-Sm; 
end
