function CT=cont(pic,thres)
%CONT Compute the contour CT on an image pîc with the threshold defined by thres
%CT=cont(pic,thres)
% pic : directory of pictures (give by openall())
% thres : the tres, need to manually set
%
% Return the Contour, an array of double n by 2 whith all the coordinates
% of top polygones
% 
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file
[s1 s2]=size(pic);
Sm=max(size(pic));
if thres<Sm
	pic=double(pic)+Sm;
	thres=thres+Sm;
end

% All the contours C are computed
C = contour(pic,[thres thres]);
u=find(C(1,:)==thres);
    
%The biggest contour is taken 
Cmin=0;Cmax=0;lmax=0;
for j=2:length(u)
	lt=u(j)-u(j-1);
	if (lt>lmax )

        Cmin=u(j-1);
        Cmax=u(j);
        lmax=lt;
	end
end
if length(u)>1
	lt=length(C)-u(j);
else
	lt=length(C)-u(1);
	j=1;
end
if (lt>lmax )
    Cmin=u(j);
	Cmax=length(C);
	lmax=lt;
end
nu=[C(1,Cmin+1:Cmax-1);C(2,Cmin+1:Cmax-1)];
% The double points of the contour are cleaned
CT=cleandouble(nu');
 
%If the contour to compute is over the lower and upper border of the image
if (min(CT(:,2))<2 && max(CT(:,2)>s1-2))
	L=(1:s2).*0;
	pic=[L;pic;L];
	Sm=max(size(pic));
	if thres<Sm
        pic=double(pic)+Sm;
        thres=thres+Sm;
	end
    % All the contours C are computed
	C = contour(pic,[thres thres]);

 
	u=find(C(1,:)==thres);
    
	%The biggest contour is taken
	Cmin=0;Cmax=0;lmax=0;
	for j=2:length(u)
        lt=u(j)-u(j-1);
        if (lt>lmax )

            Cmin=u(j-1);
            Cmax=u(j);
            lmax=lt;
        end
	end
    if length(u)>1
        lt=length(C)-u(j);
    else
        lt=length(C)-u(1);
        j=1;
    end
    if (lt>lmax )
        Cmin=u(j);
        Cmax=length(C);
        lmax=lt;
    end
    nu=[C(1,Cmin+1:Cmax-1);C(2,Cmin+1:Cmax-1)];
    % The double points of the contour are cleaned
    CT=cleandouble(nu');
    CT(:,2)=CT(:,2)-1;
end
