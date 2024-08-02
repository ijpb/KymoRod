function [F V_F dist2] = neighboorContour(c1,C,in,V_F,V,v1)

for i=1:c1
    
    h=length(C{i});
    for k=1:h
        
        B_k=in(C{i}(k));
        if(B_k==1)
            j1=k-1;
            j2=k+1;
            if k==1
                j1=h;
            end
            if k==h
                j2=1;
            end
            
            
            B_j=in(C{i}(j1));
            %on ne s'occupe que des points interieur-interieur nombre
            %de voisin et positions dans la chaine
            if (B_j==1)
                V_F(C{i}(k))=V_F(C{i}(k))+1;
                F{C{i}(k)}(V_F(C{i}(k)))=C{i}(j1);
            end
            
            B_j=in(C{i}(j2));
            
            if (B_j==1)
                V_F(C{i}(k))=V_F(C{i}(k))+1;
                F{C{i}(k)}(V_F(C{i}(k)))=C{i}(j2);
            end
            
            
            if (V_F(C{i}(k))>0)
                %on �vite les redites
                F{C{i}(k)}=unique(F{C{i}(k)});
                V_F(C{i}(k))=length(F{C{i}(k)}');
                
            end
        end
    end
end

% on obtient F et VF


% ?
for i=1:v1
    if V_F(i)==0
        dist2(i)=1e4;
    else
        dist2(i)=norm(V(i,:)-V(F{i}(1),:));
    end
end