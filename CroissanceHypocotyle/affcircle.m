function affcircle(varargin)
i=1;
hold on;
colormap(lines);
cmap=colormap;



if iscell(varargin{1})==1
    A=varargin{1};
    if length(varargin)>1
        B=varargin{2};
    end        
    for k=1:length(A)
        if size(A{k},2)>1
            plot(A{k}(:,1),A{k}(:,2),'color',cmap(mod(k,63)+1,:));
        elseif length(varargin)>1
            plot(A{k},B{k},'color',cmap(mod(k,63)+1,:));
        else
            plot(A{k},'color',cmap(mod(k,63)+1,:));
        end
    end
else
    while i<(nargin)+0.1
        
        if size(varargin{i},2)>1
            A=varargin{i};
            plot(A(:,1),A(:,2),'color',cmap(mod(i,63)+1,:));
            i=i+1;
        else
            A=varargin{i};
            B=varargin{i+1};
            i=i+2;
            plot(real(A),imag(A),'color',cmap(mod(i,63)+1,:));
        end

    end
end
