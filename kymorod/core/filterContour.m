function CTf = filterContour(CT, a, sym)
% FILTERCONTOUR Smooth the contour depending on its global shape
%
% CTF = filterContour(CT, WS, TYPE)
%   (Rewritten from CTfilter function)
%
% CT: 	contour n-by-2 array of double
% WS: 	length of smoothing window
% TYPE:	the type of contour, as a string
%
% CTF: 	result of the smoothing, as a N-by-2 array of vertex coordinates.
% 
%
% ------
% Author: Renaud Bastien
% e-mail: rbastien@seas.harvard.edu
% Created: 2012-03-03,    using Matlab 7.9.0.529 (R2009b)
% Copyright 2012 INRA - Cepia Software Platform.

%   HISTORY
%   2014-04-16 : Add comments about the file

% number of vertices in contour
N = size(CT, 1);

N2 = floor(N / 2);

% determine if vertex number is even or odd
if 2 * N2 == N
    un = 0;
else
    un = -1;
end

% centered frequency vector
w = (-N+1:N);  

% compute filtering signal in frequency domain
%exp(-w.^2/a.^2);%     % centered version of H
H1 = a ./ (a + 1i.*w); 
H2 = a ./ (a + 1i.*w);
Hshift = [fftshift(H1)' fftshift(H2)']; 

% pad contour values with appropriate number of of points 
switch sym
    case 'droit'
        CTsym(:,1) = [flipud(CT(1:N2,1)) ; CT(:,1) ; flipud(CT(N2+1:end,1))];
        CTsym(:,2) = [2*CT(1,2)-flipud(CT(1:N2,2));CT(:,2);2*CT(end,2)-flipud(CT(N2+1:end,2))];
        %H(:,2) = a ./ (a + 1i.*w);
    	
    case 'droit2'
        A1 = angle3(CT(1,:), [1 0], CT(20,:));
        %A2=angle3(CT(end,:),[1 0],CT(end-20,:));
        A2 = A1;
        x1 = CT(1,1)-(N2:-1:1).*abs(CT(1,1)-CT(2,1));
        x2 = CT(end,1)-(1:N-N2).*abs(CT(1,1)-CT(2,1));
        
        y1 = CT(1,2)+(x1-CT(1,1))*tan(A1);
        y2 = CT(end,2)+(x2-CT(end,1))*tan(A2);
        
        CTsym(:,1) = [x1';CT(:,1);x2'];
        CTsym(:,2) = [y1';CT(:,2);y2'];
    
    case 'boucle'
        CTsym(:,1) = [CT(N2+1:end,1);CT(:,1);CT(1:N2,1)];
        CTsym(:,2) = [(CT(N2+1:end,2));CT(:,2);(CT(1:N2,2))];
        % H(:,2) = a ./ (a + 1i.*w);
    
    case 'penche'   
        CTsym(:,1) = [2*CT(1,1)-flipud(CT(1:N2,1));CT(:,1);2*CT(1,1)-flipud(CT(N2+1:end,1))];
        CTsym(:,2) = [flipud(CT(1:N2,2));CT(:,2);flipud(CT(N2+1:end,2))];
    
    case 'penche2'
        CTsym(:,1) = [2*CT(1,1)-(CT(N2+1:end,1));CT(:,1);2*CT(1,1)-(CT(1:N2,1))];
        CTsym(:,2) = [CT(1,2)+CT(end,2)-(CT(N2+1:end,2));CT(:,2);CT(end,2)+CT(1,2)-(CT(1:N2,2))];

	case 'dep'
        CTsym(:,1) = [-flipud(CT(1:N2,1));CT(:,1);CT(end,1)+flipud(CT(N2+1:end,1))];
        CTsym(:,2) = [-flipud(CT(1:N2,2));CT(:,2);flipud(CT(N2+1:end,2))];
        Hshift(:,1) = ones(size(Hshift(:,1)));
        
    case 'rien'
        CTsym = CT;
        
    otherwise
        error(['Unprocessed type of contour: ' sym]);

end

% additional filtering
CTf = zeros(size(CT));
for k = 1:2
	% filtering in the frequency domain
    X = zeros(size(CTsym));
    X(:,k) = fft(CTsym(:,k));
    X(:,k) = X(:,k).* Hshift(:,k);
    xk = real(ifft(X(:,k)));

	% additional filtering
    CTf(:,k) = xk(N2+1:end-N2+un);
    CTf(:,k) = moving_average(CTf(:,k), 10);
end

