%% definition of the intial parameters 
    %time between two pictures (min)
        t0=10;
    %scale pixels/mm
        scale=253./1; 
    %filter direction
        direction='boucle'; 
        dirbegin='bottom';
    %Pictures opening

        red=openall('r');
        %red=openall('g');
    %length of the smoothing
        iw=10; 
    %thresholding 
        parfor k=1:length(red)
            red{k}=red{k}(1:2500,:,1);
            %red{k}(1:1700,1:350)=red{k}(1:1700,1:350).*0;
            %red{k}(:,1460:end)=red{k}(:,1460:end).*0;
            red{k}=[red{k}(:,1).*0 red{k} red{k}(:,1).*0];
            red{k}=[red{k}(1,:).*0;red{k};red{k}(1,:).*0];
            %red{k}=red{k}';
            thres(k)=165;%85;%26;% adaptthres(red{k});
            %thres(k)=adaptthres(red{k});
        end
    %   
        nx=500; 
%% Skeletonization
    disp('Skeletonisation');
    [SK CT shift R CTVerif SKVerif]=skelall(red,thres,scale,direction,dirbegin);

%% Curvature
    disp('Curvature');
    [S A C]=curvall(SK,iw);
%% alignment of all the results
    disp('Aligncurv');
    Sa=aligncurv(S,R);



%% Initial Parameters for displacement measurement
    %size of the correalting window
        ws=15;
    %step between two measurements of displacement
        step=2; 
    %
        we=1;
    %
        ws2=30;
        
%% Displacement
    disp('Displacement');
    E=displall(SK,Sa,red,scale,shift,ws,we,step);
%% Elongation
    disp('Elongation');
    [Elg E2]=elgall(E,t0,step,ws2);

%%  Space-time mapping
% Subsampling size

    
    ElgE1=reconstruct_Elg2(nx,Elg);     
    %ElgE3=reconstruct_Elg2(nx,Elg4);

    CE1=reconstruct_Elg2(nx,C,Sa);
    %CE3=reconstruct_Elg2(nx,C4);
    AE1=reconstruct_Elg2(nx,A,Sa);
    %AE3=reconstruct_Elg2(nx,A4);   
    RE1=reconstruct_Elg2(nx,R,Sa);
    
  