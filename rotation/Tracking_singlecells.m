clear;
clc;
close all;

% Setting
PROVA = 'Prova_10';
VideoPath = strcat('F:\Analisi ROT\Paolo\10_PWR1E\',PROVA,'.avi');
SavePath = strcat('F:\Analisi ROT\Paolo\10_PWR1E\Tracking_PWR1E\',PROVA,'\');
VideoP = VideoReader(VideoPath);
Cell_number = 'Cell_4';

% Cells selection
NumCells = 1;


se = strel('disk',5);
Thrs = 140; % DA OTTIMIZZARE PER OGNI CELLULA

% settare in funzione delle necessità
FrameIni = 218;     % round(12*VideoP.FrameRate);% trovare di volta in volta il frame di partenza 
NumSeconds = 12;
FrameSizeY = 480;
FrameSizeX = 640;
PixelIniY = 1;
PixelIniX = 1;


NumFrameEx = VideoP.NumFrames;% fino alla fine del video
% floor(NumSeconds*VideoP.FrameRate);% fino al numero di secondi
% FrameVideo = zeros(FrameSizeY,FrameSizeX,NumFrameEx);
% Mask = FrameVideo;


Im = read(VideoP,FrameIni);
    FrameVideo = double(rgb2gray(Im(PixelIniY:PixelIniY-1+FrameSizeY,PixelIniX:PixelIniX-1+FrameSizeX,:)));
    imagesc(FrameVideo);colormap gray;axis image;axis off;
    [XX,YY] = ginput(NumCells); % select starting point for tracking
    close all;
XX = round(XX);
YY = round(YY);

MaskIni = imfill(double(FrameVideo>Thrs));
MaskIni = (imerode(imfill(imdilate(MaskIni,se)),se));
MMM = bwlabel(MaskIni);
MMMnew = zeros(size(MMM));
for r1=1:NumCells
    MMMnew(MMM == MMM(YY(r1),XX(r1)))=1;
end
MMMnew = imdilate(MMMnew,se);
s = regionprops(bwlabel(MMMnew),'MajorAxisLength');
MaxAx = round(cat(1,s.MajorAxisLength));

RadiusCells = round(MaxAx/2+10);

% inizializzazione ROI per cellula
Cellula1 = zeros(2*RadiusCells(1)+1,2*RadiusCells(1)+1,NumFrameEx-FrameIni+1);

%% tracking
tic;
for r1=FrameIni:FrameIni-2+NumFrameEx
    r1
    Im = read(VideoP,r1);
    FrameVideo = double(rgb2gray(Im(PixelIniY:PixelIniY-1+FrameSizeY,PixelIniX:PixelIniX-1+FrameSizeX,:)));
   
    Mask = imfill(double(FrameVideo>Thrs));
    Mask = (imerode(imfill(imdilate(Mask,se)),se));
    MMM = bwlabel(Mask);
    
    s = regionprops(MMM,FrameVideo,'WeightedCentroid');
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
    
    Mask = imdilate(MMMnew,se);
    
    % ESTRAZIONE DELLA ROI contenente la cellula trackata
    Cellula1(:,:,r1-FrameIni+1)=FrameVideo(Traj1(r1-FrameIni+1,1)-RadiusCells(1):Traj1(r1-FrameIni+1,1)+RadiusCells(1),Traj1(r1-FrameIni+1,2)-RadiusCells(1):Traj1(r1-FrameIni+1,2)+RadiusCells(1));
%     imagesc(Cellula1(:,:,r1-FrameIni+1)); axis image;axis off;colormap gray;
%     pause(0.0000000000000000000000000000000001);
end

% Tempo = toc;
% TempoProcessingSec = Tempo/NumSeconds;


%% Visualizzazione per verifica
for i=1500-FrameIni:2000
    imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
    pause(0.000000000000001);
end

for i=r1-500-FrameIni:r1-1-FrameIni
    imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
    pause(0.000000000000001);
end

for i=1:500
    imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
    pause(0.000000000000001);
end

save(strcat(SavePath, Cell_number,'.mat'));


