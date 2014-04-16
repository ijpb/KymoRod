function [Ax]=resampl(nx,A,S)
%[Ax]=resampl(nx,A,S)
%resample the functions [S A] with nx elements 

Smin=S(1);
Smax=S(end);

L=max(Smax);
DL=L./nx;
Ax=zeros(length(1+round(Smin./DL):round(Smax./DL)),1);
   parfor j=1+round(Smin./DL):round(Smax./DL)
       X=j.*DL;
      posmin=find(S<X,1,'last');
      posmax=find(S>X,1,'first');
      if isempty(posmin)
          posmin=1;
      end
      if isempty(posmax)
          posmax=length(S);
      end
      Ax(j,1)=...
          (A(posmax).*(X-S(posmax))-A(posmin).*(X-S(posmin)))...
          ./(S(posmax)-S(posmin));
      
   end
