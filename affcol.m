function affcol(X,Y,Z,clim,c)


l=length(c);
st=1;
for j=1:st:length(X)
    
    if isnan(Z(j))==0
    v=round(l*(Z(j)-clim(1))/(clim(2)-clim(1)));
    if v<1
        v=1;
    elseif v>l
        v=l;
    end
    
    hold on;
    plot(X(j),Y(j),'o','MarkerFaceColor',c(v,:));
    end
end