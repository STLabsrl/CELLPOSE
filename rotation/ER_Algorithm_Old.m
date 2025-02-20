clear;
clc;
close all;

addpath 'C:\Users\samue\OneDrive - Università degli Studi di Catania\Università\Automation Engineering and Control of Complex Systems (Magistrale, 2020)\Tesi\6_Signal_Processing_Program'

% Tuning
path_save = 'C:\Users\samue\OneDrive - Università degli Studi di Catania\Dottorato\02-Paper\2024\J-IEEE_CAS\7_Experimental Campain\ER_Analysis\3_OPM2\Prova_14\';
VideoP = VideoReader('C:\Users\samue\Desktop\Esperimenti_del_10_07\3_Glut_C\Prova_4.avi');
Thrs = 90; % DA OTTIMIZZARE PER OGNI CELLULA
FrameIni_1 = 700; 
RadiusCells = 14;

Corr_Analysis = {};
PxI_Analysis = {};
Angle_det={};
Angle_norm={};

frequency=[];
f1=20:10:100;
f2=200:100:1000;
f4=10000:10000:100000;
f5=110000:10000:150000;
frequency=[f1 f2 f4 f5];

TT=[];
for j=1:length(frequency)
    if frequency(j) <= 200
        TT(j)=5.3;
    elseif (frequency(j) > 200) && (frequency(j) <= 1000)
        TT(j)=8.3;
    elseif (frequency(j) > 1000) && (frequency(j) <= 30000)
        TT(j)=12.3;
    elseif (frequency(j) > 30000) && (frequency(j) <= 100000)
        TT(j)=10.3;
    else
        TT(j)=15.3;
    end
end
TT(j+1)=15.3;

FrameSizeX = VideoP.Width;
FrameSizeY = VideoP.Height;
PixelIniY = 1;
PixelIniX = 1;
FPS = round(VideoP.FrameRate);
FRAMES = [];
FRAMES(1) = FrameIni_1;
% for j=2:length(TT)
%     FRAMES(j) = FRAMES(j-1)+round((TT(j)*FPS)+(0.86*FPS));
% end

for j=1:length(TT)
    FRAMES(j+1) = FRAMES(j)+round((TT(j)*FPS)+(0.86*FPS));
end


% Cells selection
NumCells = 1;

se = strel('disk',5);

Im = read(VideoP,FrameIni_1);
FrameVideo(:,:,1) = double(rgb2gray(Im(PixelIniY:PixelIniY-1+FrameSizeY,PixelIniX:PixelIniX-1+FrameSizeX,:)));
imagesc(FrameVideo(:,:,1));colormap gray;axis image;axis off;
[XX,YY] = ginput(NumCells); % select starting point for tracking
close all;
XX = round(XX);
YY = round(YY);
for iter=1:length(frequency)

    FrameIni = FRAMES(iter); 
    NumSeconds = TT(iter+1);
    
    NumFrameEx = floor(NumSeconds*VideoP.FrameRate);
    FrameVideo = zeros(FrameSizeY,FrameSizeX,NumFrameEx);
    Mask = FrameVideo;

    MaskIni = imfill(double(FrameVideo(:,:,1)>Thrs));
    MaskIni = (imerode(imfill(imdilate(MaskIni,se)),se));
    MMM = bwlabel(MaskIni);
    MMMnew = zeros(size(MMM));
    for r1=1:NumCells
        MMMnew(MMM == MMM(YY,XX))=1;
    end
    MMMnew = imdilate(MMMnew,se);
    s = regionprops(bwlabel(MMMnew),'MajorAxisLength');
    MaxAx = round(cat(1,s.MajorAxisLength));
    
    % inizializzazione ROI per cellula
    Cellula1 = zeros(2*RadiusCells(1)+1,2*RadiusCells(1)+1,NumFrameEx);
    
    %% tracking
    tic;
    frequency(iter),
    for r1=FrameIni:FrameIni-1+NumFrameEx
        Im = read(VideoP,r1);
        FrameVideo(:,:,r1-FrameIni+1) = double(rgb2gray(Im(PixelIniY:PixelIniY-1+FrameSizeY,PixelIniX:PixelIniX-1+FrameSizeX,:)));
       
        Mask(:,:,r1-FrameIni+1) = imfill(double(FrameVideo(:,:,r1-FrameIni+1)>Thrs));
        Mask(:,:,r1-FrameIni+1) = (imerode(imfill(imdilate(Mask(:,:,r1-FrameIni+1),se)),se));
        MMM = bwlabel(Mask(:,:,r1-FrameIni+1));
        
        s = regionprops(MMM,FrameVideo(:,:,r1-FrameIni+1),'WeightedCentroid');
        Centri = cat(1,s.WeightedCentroid);
        Centri = round(Centri);
    
        %CALCOLO DELLA TRAIETTORIA 
        Dist1 = zeros(1,size(Centri,1));
        
        for nn1=1:size(Centri,1)
            Dist1(nn1)=sqrt((Centri(nn1,1)-XX(1)).^2+(Centri(nn1,2)-YY(1)).^2);
        end
        [A1,B1]=min(Dist1);
        
        XX = Centri(B1,1);
        YY = Centri(B1,2);
        Traj1(r1-FrameIni+1,:) = [YY(1),XX(1)-1];
        
        MMMnew = zeros(size(MMM));
        MMMnew(MMM==B1)=1;
        
        Mask(:,:,r1-FrameIni+1) = imdilate(MMMnew,se);
        
        % ESTRAZIONE DELLA ROI contenente la cellula trackata
        Pippo = FrameVideo(Traj1(r1-FrameIni+1,1)-RadiusCells(1):Traj1(r1-FrameIni+1,1)+RadiusCells(1),Traj1(r1-FrameIni+1,2)-RadiusCells(1):Traj1(r1-FrameIni+1,2)+RadiusCells(1),r1-FrameIni+1);
%         Pippo = FrameVideo(Traj1(r1-FrameIni+1,1)-RadiusCells(1):Traj1(r1-FrameIni+1,1)+RadiusCells(1),Traj1(r1-FrameIni+1,2)-RadiusCells(1):Traj1(r1-FrameIni+1,2)+RadiusCells(1),r1-FrameIni+1);
        
        [pi1, pi2]=size(Pippo);
        pi2=round(pi1/2)-1;
        [pi3, pi4]=meshgrid(-pi2:pi2, -pi2:pi2);
        Cerchio = double((pi3.^2+pi4.^2)<(pi2)^2);
        Pippo2=Pippo.*Cerchio;
        Cellula1(:,:,r1-FrameIni+1)=Pippo2;
        
    end
    Tempo = toc;
    TempoProcessingSec = Tempo/NumSeconds;
    
    % VISUALIZZAZIONE
%     for i=1:size(Cellula1,3)
%         imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
%         pause(0.00000001);
%     end
    
    close all,
    
    % Corr Algorithm
    for tt = 2:size(Cellula1,3)
        CC1 = corrcoef(Cellula1(:,:,1),Cellula1(:,:,tt));
        ValCC1(tt)=CC1(1,2);
    end
    sign_1 = ValCC1;

    % Corr Algorithm (un quadrante)
    aa=size(Cellula1);
    for tt = 2:size(Cellula1,3)
        CC2 = corrcoef(Cellula1(1:round(aa(1)/2), 1:round(aa(1)/2), 1),Cellula1(1:round(aa(1)/2), 1:round(aa(1)/2), tt));
        ValCC2(tt)=CC2(1,2);
    end
    sign_5 = ValCC2;
    

    % PxI a quattro quadranti
    aa=size(Cellula1);
    yy=mean(squeeze(Cellula1(1:round(aa(1)/2), 1:round(aa(1)/2), :)), [1 2]);
    yyy=reshape(yy,1, length(yy));
    signal_A=filter(Lowpass_filter(FPS,10,8), yyy);
    signal_B=signal_A(10:end);
    sign_2 = normalize(signal_B,"range");


    Corr_Analysis{iter,1} = sign_1;
    Corr_Analysis_1{iter,1} = sign_5;
    PxI_Analysis{iter,1} = sign_2;
%     PxI_Analysis_Spectrum{iter,1} = A_1;
%     PxI_Analysis_Spectrum{iter,2} = F_1;
%     Angle_det{iter,1} = sign_3;
%     Angle_norm{iter,1} = sign_4;

    YY = Traj1(end,1);
    XX = Traj1(end,2);
end

