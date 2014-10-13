function MATfunc=Func2Pic(pic,func,scale,shift,S)
%FUNC2PIC Associates the curvilinear abscissa of the curve angle at each pixel of the skeleton
%MATfunc=Func2Pic(pic,func,scale,shift,S)
%
%pic  : directory of pictures (gave by openall())
%scale : the scale, define in parstart
%shift : Coordinates of the origin of the skeleton, bottom left
%Func : the skeleton
%S : curvilinear abscissa
%
%
% Return MATfunc, an image who say for each points who is the curvilinear abscissa
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
func(:,1)=(func(:,1)+shift(1,1))*scale;
func(:,2)=(-func(:,2)+shift(1,2))*scale;


MATfunc=zeros(size(pic));

avg=ones(size(pic));

for i=1:length(func(:,1))
    if MATfunc(round(func(i,2)),round(func(i,1)))>0
        avg(round(func(i,2)),round(func(i,1)))=1+avg(round(func(i,2)),round(func(i,1)));
    end
    MATfunc(round(func(i,2)),round(func(i,1)))=S(i)+MATfunc(round(func(i,2)),round(func(i,1)));
    
end

MATfunc=MATfunc./avg;
    
    
        
        
