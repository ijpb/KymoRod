function [X, Y] = avgd(E, LX, LY, dx)

nx = (max(E(:,1))-min(E(:,1)))/dx;

X = 0:E(end,1)/nx:E(end,1);

D = zeros(length(E), 1);
for k = 1:length(E)
    D(k)=sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)).*exp(-((E(:,2)-E(k,2)).^2)./(2.*LY.^2)))./sum(exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2)));

%    kernel = exp(-((E(:,1)-E(k,1)).^2)./(2.*LX.^2));
%    D(k)=sum( kernel .*  exp(-((E(:,2)-E(k,2)).^2)./(2.*LY.^2)) ) / sum(kernel);

end

E2 = E(D>.6,:);

Y = zeros(length(X), 1);
for k = 1:length(X)
    Y(k)=sum(E2(:,2).*exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)))./sum(exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2)));
    
    kernel = exp(-((E2(:,1)-X(k)).^2)./(2.*LX.^2));
    Y(k) = sum( E2(:,2) .* kernel) / sum(kernel);
end
 

