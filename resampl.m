function [Ax]=resampl(nx,A,S)
%RESAMPL resample the functions [S A] with nx elements
% [Ax]=resampl(nx,A,S)
%
% nx : Number of points on which resample
% A : the radius
% S : the curvilinear abscissa 
%
% Ax is the new curvilinear abscissa who is resample by linear interpolation
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
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
