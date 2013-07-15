function [Filtered_data dataIn] = Profusion_Ext_Filt_GUI(StartTime, Duration, Decimate, band_coeff,j,Time_adjustment)
% script created by Richard Balson 06/02/2013

% description
% ~~~~~~~~~~~
% This script filters and extracts profusion EEG4 data. It specifies the
% start time for extraction, relative to the beginning of the study, the
% duration of data to extract is specified by the Duration input. Further
% the deciamtion of data is specified by Decimate, this effectively reduces
% the frequency of the recordings observed. ie. If decimate is 2 and the
% sampling frequency for the study is 2048 then the number of samples per
% second in the output is 2048/2. The input band_coeff specifies the filter
% coefficients and lastly j specifies the channel the data should be
% extracted from. The two outputs contain the original data extracted by
% profusion (dataIn), as well as the filter data (Filtered_data). Note that
% all observations are multiplied by 1000 resulting in recrdings tht are
% specified in mV.
DurationT = Duration;
for k = 1:10;
 if Duration>150
     DurationT(k) = 150;
     Duration = Duration-150;
 else DurationT(k) =Duration;
     break
 end
end
dataIn=[];
for periods = 1:length(DurationT)
    if periods>1
        StartTime = StartTime+DurationT(periods-1);
    end
try
    [~, DataChDec, ~] = Get_Data_ProFusionEEG4(j,StartTime-Time_adjustment,DurationT(periods),Decimate,0); % Extract data from profusion
catch
    [~, DataChDec, ~] = Get_Data_ProFusionEEG4A(j,StartTime-Time_adjustment,Duration,Decimate,0); % Extract data from profusion
end

dataIn = cat(1,dataIn,DataChDec(k:length(DataChDec),1)); % Speicfy unfiltered data output

end

multiplier = 1000; % Change recordings to mV

% tic

% Filtered_data = Profusion_filter(dataIn*multiplier,band_coeff);

Filtered_data = filtfilt1(band_coeff,1,(dataIn*multiplier)')';

% filter_time = toc


% function filter_data_output = Profusion_filter(data,band_coeff)
% 
% filter_data = filtfilt1(band_coeff,1,data');
% 
% filter_data_output = filter_data';