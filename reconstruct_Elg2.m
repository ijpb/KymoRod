function [Ax]=reconstruct_Elg2(nx,varargin)
%[Ax]=reconstruct_Elg2(nx,varargin)

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

Ax=nan.*zeros(T,nx);
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
      
      Ax(k,j)=...
          -(A{k}(posmax).*(X-S{k}(posmax))-A{k}(posmin).*(X-S{k}(posmin)))...
          ./(S{k}(posmax)-S{k}(posmin));
      
   end
    end
end
