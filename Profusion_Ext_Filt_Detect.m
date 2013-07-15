function [Filtered_data dataIn] = Profusion_Ext_Filt_Detect(StartTime, Duration, Decimate, band_coeff,j,Time_adjustment)
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

% Filtered_data = Profusion_filter(dataIn*multiplier,band_coeff); % Filter
% data extracted from profusion

Filtered_data = filtfilt1(band_coeff,1,(dataIn*multiplier)')'; % Filter data using the filter coefficients specified

% function filter_data_output = Profusion_filter(data,band_coeff)
% % This script filters the data specified by data, with the filter
% % coefficients band_coeff, and outputs the resulting filtered data, note
% % filtfilt is used so that the data is in an identical format to the
% % origianl data, and is not shifted in time
% 
% filter_data = filtfilt1(band_coeff,1,data'); % Filter data, filtfilt filters data twice once forward second time backwards
% 
% filter_data_output = filter_data'; % Tranpose data