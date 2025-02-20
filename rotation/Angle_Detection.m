clear,
close all,

load 'F:\Analisi ROT\Paolo\10_PWR1E\Tracking_PWR1E\Prova_4\Cell_1.mat'

% Tracking 
Traj1 = [];
XX = [];
YY = [];
[a, b, c] = size(Cellula1);
raggio2 = RadiusCells-10;
Cellula2 = zeros(2*raggio2+1,2*raggio2+1,c);
Maschera2 = zeros(2*raggio2+1,2*raggio2+1,c);
cp = cellpose(Model="cyto2");
k=0;
for r1=1:length(Cellula1)
    r1,
    IMAGE = Cellula1(:,:,r1);
    labels = segmentCells2D(cp,IMAGE);
    s = regionprops(labels,IMAGE,'WeightedCentroid');
    if(isempty(s)==1)
        k=k+1;
    else
        Centri = cat(1,s.WeightedCentroid);
        Centri = round(Centri);
        XX = Centri(1);
        YY = Centri(2);
    end
    Cellula2(:,:,r1)=Cellula1(YY-raggio2:YY+raggio2, XX-raggio2:XX+raggio2, r1);
    Maschera2(:,:,r1)=labels(YY-raggio2:YY+raggio2, XX-raggio2:XX+raggio2);
end


% Creazione Maschera Circolare
[N1,N2] = meshgrid(-floor(size(Cellula2(:,:,1),1)/2):floor(size(Cellula2(:,:,1),1)/2),-floor(size(Cellula2(:,:,1),2)/2):floor(size(Cellula2(:,:,1),2)/2));
Raggio = floor(size(Cellula2(:,:,1),1)/2.5);%così è il raggio massimo, si può ridurre
Cerchio = double((N1.^2 +N2.^2)<(RadiusCells/1.8).^2);
% Cerchio = double((N1.^2 +N2.^2)<Raggio.^2);
IM = Cellula2(:,:,1).*Cerchio;
imagesc(IM); axis image; axis off; colormap gray;

% Ispezione Frequenze
for t=1:6
    for i=(((t-1)*frame_per_frequency_2))+2+((t-1)*delay):1:t*frame_per_frequency_2+(t-1)*delay
        IM = C_500_1000(:,:, i).*Cerchio;
        imagesc(IM); axis image; axis off; colormap gray;
        pause(0.01);
    end
    pause(1);
end


% Da 30 a 400 kHz
t=11;
C_30_400 = Cellula2(:,:,1:t*frame_per_frequency+(t-1)*delay+delay);
C_500_1000 = Cellula2(:,:,t*frame_per_frequency+(t-1)*delay+delay:end);
delay = 47;
frame_per_frequency_1 = 230;
frame_per_frequency_2 = 460;
TW_1 = 80;
TW_2 = 160;
Angle_FULL = [];
Angle_1 = [];
Angle_2 = [];
for t=1:11
    for i=(((t-1)*frame_per_frequency_1))+2+((t-1)*delay)+TW_1:5:t*frame_per_frequency_1+(t-1)*delay-TW_1
        AngoloEst = fminbnd(@(Angolo) mse(C_30_400(:,:,i-1).*Cerchio, imrotate(C_30_400(:,:,i).*Cerchio,Angolo,'bicubic','crop')),0,30);
        Angle_FULL = [Angle_FULL; AngoloEst];
    end
    Angle_1 = [Angle_1 filloutliers(Angle_FULL, 'nearest')];
    Angle_FULL = [];
end

for t=1:6
    for i=(((t-1)*frame_per_frequency_2))+2+((t-1)*delay)+TW_2:5:t*frame_per_frequency_2+(t-1)*delay-TW_2
        AngoloEst = fminbnd(@(Angolo) mse(C_500_1000(:,:,i-1).*Cerchio, imrotate(C_500_1000(:,:,i).*Cerchio,Angolo,'bicubic','crop')),0,20);
        Angle_FULL = [Angle_FULL; AngoloEst];
    end
    Angle_2 = [Angle_2 filloutliers(Angle_FULL, 'nearest')];
    Angle_FULL = [];
end


angles_1 = mean(Angle_1);
angles_2 = mean(Angle_2);
angles = [angles_1, angles_2];
rad = deg2rad(angles);
rad_per_second = rad*59;

frequency=[];
f1=30:10:100;
f2=200:100:1000;
frequency=[f1 f2].*10^3;

semilogx(frequency(1:length(rad_per_second)), rad_per_second)




%% PC3 OK DA FAR VEDERE
clear,
load 'F:\Analisi ROT\Paolo\9_PC3\Tracking_PC3\Prova_6\Cell_1.mat'

% Ispezione Rotazione
for i = 1:2000
    imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
    pause(0.01);
end

[N1,N2] = meshgrid(-floor(size(Cellula1(:,:,1),1)/2):floor(size(Cellula1(:,:,1),1)/2),-floor(size(Cellula1(:,:,1),2)/2):floor(size(Cellula1(:,:,1),2)/2));
Raggio = floor(size(Cellula1(:,:,1),1)/2.5);%così è il raggio massimo, si può ridurre
Cerchio = double((N1.^2 +N2.^2)<(RadiusCells/1.4).^2);
% Cerchio = double((N1.^2 +N2.^2)<Raggio.^2);
IM = Cellula1(:,:,1).*Cerchio;
imagesc(IM); axis image; axis off; colormap gray;


frame_per_frequency_1 = 230;
frame_per_frequency_2 = 460;
delay = 47;
t=11;
C_30_400 = Cellula1(:,:,1:t*frame_per_frequency_1+(t-1)*delay+delay);
C_500_1000 = Cellula1(:,:,t*frame_per_frequency_1+(t-1)*delay+delay:end);
TW_1 = 80;
TW_2 = 160;

% Ispezione Frequenze
for t=4:5
    for i=(((t-1)*frame_per_frequency_1))+2+((t-1)*delay):1:t*frame_per_frequency_1+(t-1)*delay
        IM = C_30_400(:,:, i).*Cerchio;
        imagesc(IM); axis image; axis off; colormap gray;
        pause(0.01);
    end
    pause(1);
end

Angle_FULL = [];
Angle_1 = [];
Angle_2 = [];
for t=1:11
    for i=(((t-1)*frame_per_frequency_1))+2+((t-1)*delay)+TW_1:1:t*frame_per_frequency_1+(t-1)*delay-TW_1
        AngoloEst = fminbnd(@(Angolo) mse(C_30_400(:,:,i-1).*Cerchio, imrotate(C_30_400(:,:,i).*Cerchio,Angolo,'bicubic','crop')),0,5);
        if (AngoloEst <1e-3)
            AngoloEst = 10;
        end
        Angle_FULL = [Angle_FULL; AngoloEst];
    end
    Angle_1 = [Angle_1 filloutliers(Angle_FULL, 'nearest')];
    Angle_FULL = [];
end
plot(Angle_1(:,6))

angles = mean(Angle_1);
rad = deg2rad(angles);
rad_per_second = rad*(VideoP.FrameRate);

frequency=[];
f1=30:10:100;
f2=200:100:1000;
frequency=[f1 f2].*10^3;

semilogx(frequency(1:length(rad_per_second)), -rad_per_second)

% T=4 e 5 passa qualcosa sotto e si nota nello spettro
% Le velocità risaltano molto più basse





%% LnCAP 24 Luglio
clear,
load 'F:\Analisi ROT\Paolo\4_LnCap_Luglio_24\Tracking_LnCap_24_Luglio\Prova_8\Cell_2.mat'

for i = 1:2000
    imagesc(Cellula1(:,:,i)); axis image;axis off;colormap gray;
    pause(0.01);
end

[N1,N2] = meshgrid(-floor(size(Cellula1(:,:,1),1)/2):floor(size(Cellula1(:,:,1),1)/2),-floor(size(Cellula1(:,:,1),2)/2):floor(size(Cellula1(:,:,1),2)/2));
Raggio = floor(size(Cellula1(:,:,1),1)/2.5);%così è il raggio massimo, si può ridurre
Cerchio = double((N1.^2 +N2.^2)<(RadiusCells/1.4).^2);
% Cerchio = double((N1.^2 +N2.^2)<Raggio.^2);
IM = Cellula1(:,:,1).*Cerchio;
imagesc(IM); axis image; axis off; colormap gray;


frame_per_frequency_1 = 230;
frame_per_frequency_2 = 460;
delay = 47;
t=11;
C_30_400 = Cellula1(:,:,1:t*frame_per_frequency_1+(t-1)*delay+delay);
C_500_1000 = Cellula1(:,:,t*frame_per_frequency_1+(t-1)*delay+delay:end);
TW_1 = 50;
TW_2 = 100;

% % Ispezione Frequenze
% for t=1:3
%     for i=(((t-1)*frame_per_frequency_2))+2+((t-1)*delay):1:t*frame_per_frequency_2+(t-1)*delay
%         IM = C_500_1000(:,:, i).*Cerchio;
%         imagesc(IM); axis image; axis off; colormap gray;
%         pause(0.01);
%     end
%     pause(1);
% end

Angle_FULL = [];
Angle_1 = [];
Angle_2 = [];
for t=1:11
    for i=(((t-1)*frame_per_frequency_1))+2+((t-1)*delay)+TW_1:1:t*frame_per_frequency_1+(t-1)*delay-TW_1
        AngoloEst = fminbnd(@(Angolo) mse(C_30_400(:,:,i-1).*Cerchio, imrotate(C_30_400(:,:,i).*Cerchio,Angolo,'bicubic','crop')),0,10);
        if (AngoloEst <1e-3)
            AngoloEst = 10;
        end
        Angle_FULL = [Angle_FULL; AngoloEst];
    end
    Angle_1 = [Angle_1 filloutliers(Angle_FULL, 'nearest')];
    Angle_FULL = [];
end

for t=1:6
    for i=(((t-1)*frame_per_frequency_2))+2+((t-1)*delay)+TW_2:1:t*frame_per_frequency_2+(t-1)*delay-TW_2
        AngoloEst = fminbnd(@(Angolo) mse(C_500_1000(:,:,i-1).*Cerchio, imrotate(C_500_1000(:,:,i).*Cerchio,Angolo,'bicubic','crop')),0,10);
        Angle_FULL = [Angle_FULL; AngoloEst];
    end
    Angle_2 = [Angle_2 filloutliers(Angle_FULL, 'nearest')];
    Angle_FULL = [];
end

angles_1 = mean(Angle_1);
angles_2 = mean(Angle_2);
angles = [angles_1, angles_2];
rad = deg2rad(angles);
rad_per_second = rad*(VideoP.FrameRate);

frequency=[];
f1=30:10:100;
f2=200:100:1000;
frequency=[f1 f2].*10^3;

semilogx(frequency(1:length(rad_per_second)), rad_per_second)