function [Ax]=reconstruct_Elg2(nx,varargin)
%RECONSTRUCT_ELG2 Construct kymograph
%[Ax]=reconstruct_Elg2(nx,varargin)
%
% nx : number of points on which we resample the skeleton
% varargin{1} : data who become a kymograph
% if the data is a vector at two dimensions use only two arguments
% Else if it's just a vector at on dimensions, you must use a third argument, the curvilinear abscissa 
%
%
%
% Return : the image of kymograph (opening with imagesc())
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file


if length(varargin)==2
   S=varargin{2};
   A=varargin{1};
end

for k=1:length(varargin{1});
    
    if length(varargin)==1
          S{k}=varargin{1}{k}(:,1);
          A{k}=varargin{1}{k}(:,2);       
    end
    if isempty(S{k})==1 
        S{k}=0;
        A{k}=0;
    end
    Smin(k,1)=S{k}(1);
	Smax(k,1)=S{k}(end);
    
end
T=length(S);
L=max(Smax);
DL=L./nx;

Ax=nan.*zeros(nx,T);
for k=1:T
    
    if length(A{k})>10
        
   for j=1+round(Smin(k)./DL):round(Smax(k)./DL)
       
       X=j.*DL;
      posmin=find(S{k}<X,1,'last');
      posmax=find(S{k}>X,1,'first');
      if isempty(posmin)
          posmin=1;
      end
      if isempty(posmax)
          posmax=length(S{k});
      end
      
      Ax(j,k)=...
          -(A{k}(posmax).*(X-S{k}(posmax))-A{k}(posmin).*(X-S{k}(posmin)))...
          ./(S{k}(posmax)-S{k}(posmin));
      
   end
    end
end
