function S_n=cleandouble(S)
%CLEANDOUBLE Removes the contour points in double
%
% S : the initial contour

% Return S_n : contour whitout points in double
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

d_S=abs(S-circshift(S,1));
d_S=sum(d_S')'==0;
d_S=d_S-circshift(d_S,1);
f_pos=find(d_S==1);
f_neg=find(d_S==-1);
s_f=length(f_pos);
S_n=S;
for i=1:s_f
  S_n(f_pos(i):f_neg(i)-1,:)=0;
end
S_n=S_n(S_n(:,1)>0,:);


    
