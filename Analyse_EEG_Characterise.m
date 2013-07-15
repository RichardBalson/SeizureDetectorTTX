% script created by Richard Balson 06/02/2013

% description
% ~~~~~~~~~~~
% This script filters the profusion data to the sepcified range

% last edit
% ~~~~~~~~~


% next edit
% ~~~~~~~~~

% Beginning of script
% ~~~~~~~~~~~~~~~~~~~~~

% Clear workspace
% ~~~~~~~~~~~
clear
close all
clc

filepath = 'J:\JLJ\20130119{BF4C39F5-12B7-4A5C-8557-9DE64590E7C2}.eeg'; % filepath = 'E:\JLJ\20130119{BF4C39F5-12B7-4A5C-8557-9DE64590E7C2}.eeg';

filepathExcel = '..\EEG Annotations\EEG Matlab Sorting.xlsx';

ExcelSheet = 'Matlab';

addpath(genpath('ExtractPFEEG4Data'));

addpath(genpath('Filter Files'));

Padding = 10;

Channel_number =0; % Initialise counting of channels
Channel_number_base =0;


window_length =2;

frequency_bands = 0:25;

Decimate =1;

highcutoff = 2.5;

lowcutoff = 40;

notch = 50;

interleave =1;

% Algorithm 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[fs, TotalChs,~,~,~,StartDateTime,StudyLength,ChannelName] = CMConnect_ProFusionEEG4(filepath);

[ChannelLength, Number_of_animals]  = CheckChannels(ChannelName); % Determine the number of channels per animal

band_coeff = filtercoeff(lowcutoff,highcutoff,fs);

Seizure_time = ReadEEGExcel(filepathExcel,ExcelSheet,Number_of_animals);% Extract times that seizures occur for each animal

for k= 1:Number_of_animals % Loop through number of animals
    
    if ChannelLength(k) ==0
        continue
    end
    
    if k>1
        Channel_number_base = Channel_number_base+ChannelLength(k-1); % Specify new channel numbers to look at for each animal
    end
    
    Seizures = Seizure_time(Seizure_time(:,1,k)~=0);
    
    for j = 1:size(Seizures,1) % Loop through all seizures for all the channels on each animal
        
        clear All_Channel_Data
        
        if (Seizure_time(j,1,k) ==0)
            continue
        end
        
        Channel_number= Channel_number_base; % Return channel number to original base for each new seizure for one animal
        
        for m = 1:round(ChannelLength(k)) % Loop through number of channels for each animal
            
            clear Data_out dataIn
            
            Channel_number = Channel_number+1;
            
            %   Number_of_windows = 20;
            
            StartTime = Seizure_time(j,1,k)-Padding;
            
            Duration = round(Seizure_time(j,2,k)-StartTime+2*Padding);
            
            
            [Data_out dataIn] = Profusion_Ext_Filt(StartTime, Duration,Decimate, band_coeff,Channel_number,StartDateTime);
            
            if m ==1
            
            All_Channel_Data = zeros(length(Data_out),ChannelLength(k));
            
            end
            
%             Analyse_data_plot(Data_out,window_length,frequency_bands,fs,Channel_number,Channel_number_base,k,j,interleave)%
%             Plot each channel for all animals individually
            
            All_Channel_Data(:,m) = Data_out;
        end
        
%         Analyse_data_plot_multiple_background(All_Channel_Data,window_length,frequency_bands,fs,k,j,interleave,StartDateTime); % Plot all channels and the corrsepnding features for one animal on a single plot
            Analyse_data_characterise(All_Channel_Data,window_length,frequency_bands,fs,k,j,StartDateTime)

    end
    
end

