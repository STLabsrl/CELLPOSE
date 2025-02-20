clear,
load Cell_1.mat

Inviluppo = 0;
Based_on = 1; % 0 for Corr and 1 for PxI
pause_plot=5;


Grado_inviluppo = 1;
Soglia_1 = 0.01; 
%     tolleranza_secondi_picchi = 0.3; % Percentuale diviso 100
%     Errore_picchi_uguali = 0.3;
tolleranza = 0.05;
minpeakdistance = 0; % Espressa in secondi
%     minpeakdistance_tolerance = 0.2;


Soglia_2 = 0;
Spectrum_Corr = [];
for j=1:length(Corr_Analysis)
    if (Inviluppo == 1)
        if(Based_on==0)
            [envHigh, envLow] = envelope(Corr_Analysis{j,1}(2:end),Grado_inviluppo,'peak');
            A=envHigh;
%             A=(envHigh+envLow)/2;
        else
            [envHigh, envLow] = envelope(PxI_Analysis{j,1}(15:end),Grado_inviluppo,'peak');
            A=envHigh;
        end
    else
        if(Based_on==0)
            A=Corr_Analysis{j,1}(2:end);
        else
            A=PxI_Analysis{j,1}(15:end);
        end
    end

    time_peaks_corr = [];
    t=0:1/FPS:(length(A)-1)*(1/FPS);
    if (Inviluppo == 1)
        if(Based_on==0)
            plot(t,Corr_Analysis{j,1}(2:end)), hold on,
        else
            plot(t,PxI_Analysis{j,1}(15:end)), hold on,
        end
    end

    [pks_corr,locs_corr,widths,proms] = findpeaks(A,t,'MinPeakProminence', Soglia_1,'MinPeakDistance', minpeakdistance,'Annotate','extents');
    if(length(proms)==0)
        Soglia_2 = 0.05;
    elseif (length(proms)==1)
        Soglia_2 = proms-0.01*proms;
    else
        Soglia_2=rms(proms, "all")-tolleranza*rms(proms, "all");
%         error = rms(proms-mean(proms));
%         if (error < Errore_picchi_uguali)
%             Soglia_2 = mean(proms)-Errore_picchi_uguali*mean(proms);
%         else
%             Soglia_2 = mean(proms)+tolleranza_secondi_picchi*mean(proms);
%         end
    end
    findpeaks(A,t,'MinPeakProminence',Soglia_2,'MinPeakDistance', minpeakdistance,'Annotate','extents');
    title(strcat('Frequenza:',num2str(j)));
    pause(pause_plot);
    close all,
    [pks_corr,locs_corr] = findpeaks(A,t,'MinPeakProminence',Soglia_2,'MinPeakDistance', minpeakdistance,'Annotate','extents');
    if(length(locs_corr)==0)
        time_peaks_corr = NaN;
    elseif (length(locs_corr)==1)
        time_peaks_corr = locs_corr;
    else
        for i=1:length(locs_corr)-1
            time_peaks_corr = [time_peaks_corr; locs_corr(i+1)-locs_corr(i)];
        end
    end
%         if j==14
%             dbstop
%         end
    Mean_Corr = mean(time_peaks_corr);
%     if(j>6)
%         minpeakdistance = Mean_Corr-minpeakdistance_tolerance*Mean_Corr;
%     end
    Spectrum_Corr = [Spectrum_Corr; (1/Mean_Corr)];
end



f1=30:10:100;
f2=200:100:1000;
frequency = [f1 f2]*(10^3);
Spectrum_Corr=-(Spectrum_Corr)*2*pi;
semilogx(frequency(1:length(Spectrum_Corr)),Spectrum_Corr);
