% script created by Richard Balson 19/03/2013

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

tic

filepath = 'J:\JLJ\20130211{67E4360B-DF57-41A9-89BD-AB24922620C9}.eeg'; % filepath = 'J:\rbalson\Control\20120713{B56C5115-06CC-4264-A141-DB040570DCD0}.eeg';

addpath(genpath('ExtractPFEEG4Data'));

addpath(genpath('Filter Files'));

threshold =3;

thresholdAmp = 1.5;
  
Padding = 10;

Channel_number =0; % Initialise counting of channels
Channel_number_base =0;

tic

window_length =5;

frequency_bands = 0:25;

Decimate =1;

highcutoff = 2.5;

lowcutoff = 40;

notch = 50;
% Check =[]; Check1=[];Check2=[];Check3=[];
% save Datatest Check Check1 Check2 Check3

interleave =1; % Specify whether feutures analysis should be interleaved

interval_duration = 250; % Specify data segment lengths to analyse

% Algorithm 
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

[fs, TotalChs,~,~,~,StartDateTime,StudyLength,ChannelName] = CMConnect_ProFusionEEG4(filepath);


[ChannelLength, Number_of_animals]  = CheckChannels(ChannelName); % Determine the number of channels per animal

Number_of_windows = floor(StudyLength/interval_duration);

% [low_coeff,high_coeff,notch_coeff] = filtercoeff(lowcutoff,highcutoff,notch,fs);

band_coeff = filtercoeff(lowcutoff,highcutoff,fs);

Animal=struct('SeizureStartT',{{'0'}},'SeizureEndT',{{'0'}});



% Seizure_time = ReadEEGExcel(filepathExcel,ExcelSheet,Number_of_animals);% Extract times that seizures occur for each animal

for k= 1:1%Number_of_animals %Loop through number of animals
    
    if ChannelLength(k) ==0
        continue
    end
    
    Seizure_init =0;
    save Seizure Seizure_init
    Excel_pos = [0 0];
    save Current_Excel_pos Excel_pos
    Line_mean = zeros(round(ChannelLength(k)),Number_of_animals);
    Mean_number =0;
    Amp_mean =zeros(round(ChannelLength(k)),Number_of_animals);
    save Features Line_mean Amp_mean Mean_number
    clear Seizure_init Excel_pos Previous_mean Amp_mean
     
    if k>1
        Channel_number_base = Channel_number_base+ChannelLength(k-1); % Specify new channel numbers to look at for each animal
    end
    
    for j = 1:Number_of_windows
        
        StartTime = (j-1)*interval_duration+1;
        
        Duration = interval_duration;
        
        clear All_Channel_Data
        
%         if (Seizure_time(j,1,k) ==0)
%             continue
%         end
        
        Channel_number= Channel_number_base; % Return channel number to original base for each new seizure for one animal
        
        for m = 1:round(ChannelLength(k)) % Loop through number of channels for each animal
            
            clear Data_out dataIn
            
            Channel_number = Channel_number+1;
            
            %   Number_of_windows = 20;
            
            
            [Data_out, dataIn] = Profusion_Ext_Filt_Detect(StartTime, Duration,Decimate, band_coeff,Channel_number);
            
            
%             figure
%             plot(Data_out/1000)
%             hold on
%             plot(dataIn,'r')
            
            
%             Analyse_data_plot(Data_out,window_length,frequency_bands,fs,Channel_number,Channel_number_base,k,j,interleave)%
%             Plot each channel for all animals individually
            if m ==1
            
            All_Channel_Data = zeros(length(Data_out),ChannelLength(k));
            
            end
            if ~isempty(Data_out)
            All_Channel_Data(:,m) = Data_out;
            end
        end
        
        if (exist('All_Channel_Data','var'))
        [Seizure_start, Seizure_end] = Seizure_Detector1(All_Channel_Data,window_length,fs,j,StartDateTime,interval_duration,threshold,k,thresholdAmp);
        
        if (~isempty(Seizure_start))
        Animal(k).SeizureStartT(end+1*(j>1):end+1*(j>1)+length(Seizure_start)-1) = num2cell(Seizure_start');
        end
        if (~isempty(Seizure_end))
        Animal(k).SeizureEndT(end+1*(j>1):end+1*(j>1)+length(Seizure_end)-1) = num2cell(Seizure_end');
        end
        end
        toc
        
    end
    
end

toc

