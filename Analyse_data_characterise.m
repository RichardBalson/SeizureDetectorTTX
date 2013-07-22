function Analyse_data_characterise(data,window_length,frequency_bands,sampling_frequency,Animal_number,j,Start,PlotFeatures)
% function created by Richard Balson 26/03/2013

% description
% ~~~~~~~~~~~
% This script characterises the data over the specified periods, this is
% for use of seizure that have been anotated in excel with times specified
% in seconds. This function has no output as feature variables become
% exceedingly large, all data is saved into an excel file specified by the
% animal number and the date of the study.

% Beginning of function
% ~~~~~~~~~~~~~~~~~~~~~

nfeatures = [0 1 1 1]; % Specify features to plot nfeatures(1-4) correspond to Zero crossings, freqeuncy, amplitude and line length respectively

Split_length =0.5; % Specify feature window length over which features are averaged

window_samples = round(window_length*sampling_frequency); % Determine number of samples in each window

% EEG time and wondow length. Note that if
% mod(EEG_time/window_length) ~=0 then the last segment of data
% is ignored

t = linspace(0,size(data,1)/sampling_frequency,size(data,1));

for m = 1:size(data,2) % Loop through channels
    
    [EEG_length, chs] = size(data(:,m)); % Determine how many EEG samples and channels there are
    
    EEG_time = EEG_length/sampling_frequency; % Determine the the total time of EEG for the data
    
    splits = floor(EEG_time/window_length); % Determine number of data splits reuqired given the total
    
    [Zero_crossings Amplitude Line_length Line_time] = FeatureExtraction(data(:,m),window_length,sampling_frequency,Split_length); % Extract features from data
    
    if PlotFeatures % Check if features need to be plotted
        data_split = zeros(window_samples,chs,splits); % Initialse split data matrix
        frequency_output =zeros(length(frequency_bands)-1,chs,splits); % Initiliase frequency output
        
        for k = 1:splits % Loop through feature subwindows
            data_split(:,:,k) = data(((k-1)*window_samples+1):(k*window_samples),m); % Determine data in each split
            frequency_output(:,:,k) = freq_band_power_modified(data_split(:,:,k),sampling_frequency,frequency_bands); % Analyse data for each split
        end
%         
%         if (round(splits*window_length) < EEG_time) % Check if a segment of data needs to be augmented
%             data_augment = data((round(splits*window_length)+1):length(data),m); % Obtain augmented data
%             frequency_output_augmented =  freq_band_power_modified(data_augment,sampling_frequency,frequency_bands);
%         else % No augmented data required
%             frequency_output_augmented =[];  % Empty augmented output matrix
%         end
        
        % Plot data and features for all channels
        
        plot_features(window_length, splits, frequency_bands, frequency_output(:,1,:),Zero_crossings,Line_time,data,t,Animal_number,j,m, Amplitude,Line_length,nfeatures); % Plot features on a single graph
    end
    
    WriteExcel(data(:,m),Amplitude, Zero_crossings,Line_time,Line_length,Animal_number,j,m,Start,t); % Write features for the corresponing data to excel
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Sub Functions

function plot_features(window_length, splits, bands, frequency_analysis,Crossings,Crossing_time,data,t,k,j,m,Amplitude,Line_length,nfeatures)
% Plot features for the specified data segment


Channels = size(data,2); % Determine the number of channels in the specified data
total_time = window_length*(splits-1); % Determine the total length of the data that will be plotted
y = bands(2:length(bands)); % Specify frequency bands for plotting
x= 0:window_length:total_time; % Specify time for all features
plot_frequency(:,:) = frequency_analysis(:,1,:); % Determine frequency to plot
if m==1 % Check if initial channel for the data is specified
    figure % Create a figure
end
subplot(sum(nfeatures)+1,Channels,m),plot(t,data(:,m)) % Plot original data
if m ==1 % Set title
    ylabel('Voltage (mV)')
end
% plot(t,1000*dataIn(1:length(data)),'r')
title(['Channel ',int2str(m)]);
if (nfeatures(1)==1) % Check if zero crossing feature needs to be plotted
    subplot(sum(nfeatures)+1,Channels,m+Channels),plot(Crossing_time,Crossings); % Plot zero crossings
    if m ==1 % Generate axis labels for zero crossings feature
        ylabel('Zero Crossings')
    elseif m==2
        xlabel(['Animal ',int2str(k),', Seizure ',int2str(j)])
    end
end
if (nfeatures(2)==1) % Check if frequency spectrum needs to be plotted
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:2))*Channels),surf(x,y,(plot_frequency)) % Plot frequency spectrum imagesc(x,y,10*log10(plot_frequency))
    if m ==1 % Sepcify axis label
        ylabel('Power Spectral Density (dB)')
    end
    axis tight
    view(0,90);
end
if (nfeatures(3)==1) % Check if Amplitude needs to be plotted
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:3))*Channels),plot(Crossing_time,Amplitude); % Plot amplitude
    if m ==1 % Specify axis label
        ylabel('Average Amplitude')
    end
end
if (nfeatures(4)==1) % Check if line length needs to be plotted
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:4))*Channels),plot(Crossing_time,Line_length);
    if m ==1 % Specify axis label
        ylabel('Line Length')
    elseif m==2
        xlabel('Time (s)')
    end
end
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [Zero_crossings Amplitude Line_length Line_time] = FeatureExtraction(data,windowlength,sample_rate,Split_length)
% This function determines features over the specified windows

WindowSamples = windowlength*sample_rate; % Determine the number of window samples
Number_of_windows = floor(length(data)/WindowSamples); % Determine the number of windows required
Splits_per_window = floor(windowlength/Split_length); % Determine the number of feature windows per window
SplitSamples = Split_length*sample_rate; % Determine the number of samples per feature window
Line_time = 0:Split_length:(windowlength*Number_of_windows-Split_length); % Specify time increments for feature windows
Line_length = zeros(Splits_per_window*Number_of_windows,1); % Intilaise line length feature
Amplitude = zeros(Splits_per_window*Number_of_windows,1); % Initilaise amplitude feature
Zero_crossings = zeros(Splits_per_window*Number_of_windows,1); % Initialise zero crossing feature

for k = 1:Number_of_windows % Loop through number of windows
    for m = 1:Splits_per_window % Loop through number of feture windows
        index = (k-1)*WindowSamples+(m-1)*SplitSamples+1; % Index for first sample in window
        index1 = (k-1)*WindowSamples+(m)*SplitSamples; % Index for last sample in window
        Amplitude((k-1)*Splits_per_window+m) = sum(abs(data(index:index1,:)))/(WindowSamples); % Sum the absoltue value of all amplitude in the current window and divide by number of samples
        Line_length((k-1)*Splits_per_window+m) = sum(abs(data(index+1:index1,:)-data(index:index1-1,:)))*sample_rate/(WindowSamples-1); % Sum the absolute value of all line length samples in the current window
        % to get the mean of each feature over the current feature window
       signum = sign(data(index:index1)); % Determine sign of each data segment
       Zero_crossings((k-1)*Splits_per_window+m) = sum(diff(signum~=0)); % Determine number of changes in sign in data
%         Crossings_count=0;
%         for j = 1:SplitSamples-1
%             if (((data((k-1)*WindowSamples+(m-1)*SplitSamples+j) >0) && (data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1)<0)) ...
%                     || ((data((k-1)*WindowSamples+(m-1)*SplitSamples+j) <0) && (data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1)>0)))
%                 Crossings_count = Crossings_count +1;
%             end
%             Sum_Amplitude = Sum_Amplitude + abs(data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:));
%             Sum_line = Sum_line + abs((data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:)-data((k-1)*WindowSamples+(m-1)*SplitSamples+j,:)))*sample_rate;
%         end
%         Zero_crossings((k-1)*Splits_per_window+m) = Crossings_count;
%         Amplitude((k-1)*Splits_per_window+m) = Sum_Amplitude/(WindowSamples-1);
%         Line_length((k-1)*Splits_per_window+m) = Sum_line/(WindowSamples-1);
    end
end



function WriteExcel(data,Amplitude, Crossings,Crossing_time,Line_length,k,j,m,Start,t)
% This function writes all data to excel

Spreadsheet_number ='.xls'; % Initalise spreadsheet
for mcheck = 1:10 % Loop through dummy varaible
    if (j >20*mcheck) % Check if the number of data segments analyses is greater than twenty
        Spreadsheet_number = ['(',int2str(mcheck),').xls']; % Create a new spreadsheet due to excel limits
    else
        break; % Break loop
    end
end
Spreadsheet_Name = ['AnimalNumber ',int2str(k),'_Pad_',int2str(Start.Padding),' SD',int2str(Start.Day),'CD',int2str(Start.CurrentDay),'_',int2str(Start.Month),'_',int2str(Start.Year),Spreadsheet_number]; % Initilaise spreadsheet name
Sheet_name = ['Seizure',int2str(j)]; % Initilaise sheet name
column = [char((m-1)*6+65),'2']; % Specify initialse starting point in excel for Feature names
columnN = [char((m-1)*6+65),'1']; % Specify initial statrting point for channel details
columnD = [char((m-1)*6+65),'3']; % Specify initial starting point for data
Excel_dataN = {['Channel ',int2str(m)]}; % Specify channel details
% EEG_data = [data,t']; 
Excel_dataT = {'Maximum Amplitude','Zero Crossings', 'Line Length', 'Time (s)','EEG Data (mV)', 'Time (s)'}; % Specify names for EEG feature data
Excel_dataD = [Amplitude,Crossings,Line_length,Crossing_time']; % Specify features to write to excel

% Write data to excel
xlswrite(Spreadsheet_Name,Excel_dataN,Sheet_name,columnN);
xlswrite(Spreadsheet_Name,Excel_dataT,Sheet_name,column);
% xlswrite(Spreadsheet_Name,EEG_data,Sheet_name,columnE);
xlswrite(Spreadsheet_Name,Excel_dataD,Sheet_name,columnD);