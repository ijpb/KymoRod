function [X, Y]= smoothAndFilterDisplacement(E, LX, LY, dx)

% number of expected points ?
nx = (max(E(:,1)) - min(E(:,1))) / dx;

% define new x axis
X = 0:E(end,1)/nx:E(end,1);

% compute D
D = zeros(size(E,1), 1);
for k = 1:length(E)
   D(k) = sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)).*exp(-((E(:,2)-E(k,2)).^2)./(2.*LY.^2)))./sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)));   
end

% remove "outliers"
E2 = E(D>.6, :);

% ?
Y = zeros(size(E2,1), 1);
for k = 1:length(X)  
    Y(k) = sum(E2(:,2).*exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)))./sum(exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)));   
end
 

