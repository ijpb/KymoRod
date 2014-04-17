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
            red{k}=red{k}(1:3000,:,1);
            %red{k}(1:1700,1:350)=red{k}(1:1700,1:350).*0;
            %red{k}(:,1460:end)=red{k}(:,1460:end).*0;
            red{k}=[red{k}(:,1).*0 red{k} red{k}(:,1).*0];
            red{k}=[red{k}(1,:).*0;red{k};red{k}(1,:).*0];
            %red{k}=red{k}';
            thres(k)=105;%85;%26;% adaptthres(red{k});
            %thres(k)=adaptthres(red{k});
        end
    %   
        nx=500; 
%% Skeletonization
    disp('Skeletonisation');
    [SK CT shift R]=skelall(red,thres,scale,direction,dirbegin);

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
    
    %% Detection of the transition between root and hypoctyl
    %
    Smax=4;
    
    %Detection of point between hypoctyl and root
    %Maximum of radius 
    Phr=hyproot(R,Sa,Smax);
    
    %decay of the functions
    [Sa1 Sa2]=deccurv(Sa,Phr);
    [E21 E22]=deccurv(E2,Phr);
    [Elg1 Elg2]=deccurv(Elg,Phr);
    [Enorm1 Enorm2]=displnorm(E22,E21);
    
    %Phh=hyphook(C,Sa1);
    %[Elg3 Elg4]=deccurv2(Phh,Elg1);
    %[R3 R4]=deccurv2(Phh,Sa1,R);
    %[A3 A4]=deccurv2(Phh,Sa1,A);    
    %[C3 C4]=deccurv2(Phh,Sa1,C); 
%% Separate hypocotyl and Root
    
    %[tdecr tdech Elgr Elgh]=hyprootdec(Elg1,SK,shift,scale,red);
    
    %Separation of hypoctyl and roots
    [Elgr Elgh tdecr tdech]=hyprootdec2(SK,shift,scale,red,Elg1);
    [Er Eh tdecr tdech]=hyprootdec2(SK,shift,scale,red,Enorm1);
    [Cr Ch]=hyprootdec2(SK,shift,scale,red,Sa1,C);
    
    %Detection of the top of the hook (maxima of curvature)
    Phh=hyphook2(Ch);      
    
    %Hypocotyl: From the apex to the base
    [Elgh1 Elgh2]=deccurv2(Phh,Elgh);
    [Eh1 Eh2]=deccurv2(Phh,Eh);    
    %Measurement
    %Ltot total length of the organ
    %Lgz length of the growth zone
    %Emoy averaged elongation in the growth zone
    
    [Ltotr Lgzr Emoyr]=growthlength(Elgr);
    [Ltoth Lgzh Emoyh]=growthlength(Elgh1);


%% radial Elongation
    [ElgR anis]=elongrad(Elg2,Sa2,Elg2{end}(1,1)-Elg1{end}(1,1),R,t0);
    %[ElgR anis]=elongrad(Elg,Sa,0,R,t0);


%%  Space-time mapping
% Subsampling size

    
    ElgE1=reconstruct_Elg2(nx,Elg);     
    ElgE2=reconstruct_Elg2(nx,Elg2);    
    %ElgE3=reconstruct_Elg2(nx,Elg4);

    CE1=reconstruct_Elg2(nx,C,Sa);
    CE2=reconstruct_Elg2(nx,C,Sa2);
    %CE3=reconstruct_Elg2(nx,C4);
    AE1=reconstruct_Elg2(nx,A,Sa);
    AE2=reconstruct_Elg2(nx,A,Sa2);
    %AE3=reconstruct_Elg2(nx,A4);   
    RE1=reconstruct_Elg2(nx,R,Sa);
    RE2=reconstruct_Elg2(nx,R,Sa2);
    %RE3=reconstruct_Elg2(nx,R4);
    EnormE=reconstruct_Elg2(nx,Enorm2);

    ElgEh=reconstruct_Elg2(nx,Elgh2);
    ElgEr=reconstruct_Elg2(nx,Elgr);
    EEh=reconstruct_Elg2(nx,Eh2);
    EEr=reconstruct_Elg2(nx,Er);    
    ElgRE=reconstruct_Elg2(nx,ElgR);
    anisE=reconstruct_Elg2(nx,anis);
    
    

        