function [Seizure_start, Seizure_end] = Seizure_Detector1(data,window_length,sampling_frequency,Window_number,Date,interval_duration,threshold,Animal_number,thresholdAmp)
% function created by Richard Balson 26/03/2013

% description
% ~~~~~~~~~~~
% This script detects seizures over a data segment (data), by looking at a
% window of length (window_length) with a given sampling frequency
% (sampling_frequency). Seizures are detected when the median of a feature
% over a window_length is greater than the feature mean for all previous
% data multiplied by a threshold. Here two features are used, Line length
% and amplitude, and their thresholds are specified by threshold and
% thresholdAmp respectively. Note that a seizure is only detected when both
% condition are met. Further Window_number provides a relative measure for
% the data so that the current time window that is being analysed can be
% determined. The start date and time of the study are specified by Date,
% and the data duration by interval_duration. Lastly the specific animal
% being analysed is speicifed by Animal_number. The output of this function
% is two cells of strings that specify the date and times of seizure start
% and end in the specific data set analysed.

% Beginning of function
% ~~~~~~~~~~~~~~~~~~~~~


[~,~,~,Hours,Minutes,Seconds] = datevec(Date, 'dd/mm/yyyy HH:MM:SS'); % Get information about the start date and time of the study

AMPM = Date(end-1:end); % Get AMPM data

if (((strcmp(AMPM,'AM')) && (Hours~=12))) % Check if time is in AM or at 12PM
    Hours = Hours +12;
end

Window_start_time = (Window_number-1)*interval_duration; % Determine the start time of the current window relative to the starttime of the profusion EEG study

[Seizure, Seizure_time] = WindowLineDetector(data,window_length,sampling_frequency,Window_start_time,threshold,Window_number,Animal_number,thresholdAmp); % Detect Seizures

load Seizure Seizure_init % Load information about seizures from the previous window analysed


if (((~isempty(find(Seizure ==1,1))) || (Seizure_init == 1)) && ((~isempty(find(Seizure==0,1)) || (Seizure_init == 0)))) % Determine if a change has occured in the detected seizure status, ie a change from 1 to zero accross windows or any change in variable seizure in current window   
    [Seizure_start, Seizure_end]= Start_end_time(Seizure,Seizure_time,sampling_frequency,Hours,Minutes,Seconds,Window_start_time); % Create a time string for the detected seizure starts and ends
else % No seizures detected
    Seizure_start=[];
    Seizure_end=[]; % Empty strings for both fields
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% Extra functions


function [Seizure, Seizure_time] = WindowLineDetector(data,windowlength,sample_rate,Window_start_time,threshold,Window_number,Animal_number,thresholdAmp)
% this function detects seizure given the input parameters and outputs the
% binary seizure matrix and seizure times which indicates the time
% discritsation of the binary seizure matrix

load Features Line_mean Mean_number Amp_mean % Load mean value of features

WindowSamples = windowlength*sample_rate; % Determine how many samples there are in a specified window

Number_of_windows = floor(length(data)/WindowSamples); % Determine how many windows are in the current data set

Split_length = 0.5; % Specify the length of windows overwhich to analyse features

Splits_per_window = floor(windowlength/Split_length); % Determine how many feature windows there are in a window

Seizure = zeros(Number_of_windows,1); % Assign a binary seizure vector for each window

SplitSamples = Split_length*sample_rate;% Determine the number of samples per split

Seizure_time = 0:windowlength:windowlength*Number_of_windows; % Specify time for features

channels = size(data,2); % Determine the number of channels in the data

for k = 1:Number_of_windows % Loop through all windows in the data
    Line_length = zeros(Splits_per_window,channels); % Create a zero vector for both features
    Amplitude = zeros(Splits_per_window,channels);
    for m = 1:Splits_per_window % Loop through the number feature windows in each window
%         Sum_line = zeros(1,size(Line_mean,1)); % Set current summation of line length to zero
%         Sum_Amplitude =zeros(1,size(Amp_mean,1)); % Amplitude sum to value of first sample in each window
%         for j = 1:SplitSamples-1
%             Sum_Amplitude = Sum_Amplitude + abs(data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:));
            index = (k-1)*WindowSamples+(m-1)*SplitSamples+1; % Index for first sample in window
            index1 = (k-1)*WindowSamples+(m)*SplitSamples; % Index for last sample in window
            Amplitude(m,:) = sum(abs(data(index:index1,:)))/(WindowSamples); % Sum the absoltue value of all amplitude in the current window and divide by number of samples 
                                                                             % to get the mean of each feature over the current feature window
%             Sum_line = Sum_line + abs((data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:)-data((k-1)*WindowSamples+(m-1)*SplitSamples+j,:)))*sample_rate;
            Line_length(m,:) = sum(abs(data(index+1:index1,:)-data(index:index1-1,:)))*sample_rate/(WindowSamples-1); % Sum the absolute value of all line length samples in the current window
%         end
%         Amplitude(m,:) = Sum_Amplitude/(WindowSamples); % Determine mean of each feature by averaging its sum over the number of samples used
%         Line_length(m,:) = Sum_line/(WindowSamples-1);
    end
    if (Window_start_time +(k-1)*windowlength >=60) % Check if more than one minute of data has been used to obtain the data mean
%         Above_threshold=0;
%         for n =1:channels
              Above_threshold = sum((median(Line_length(:,:)) >= Line_mean(:,Animal_number)'*threshold) &(median(Amplitude(:,:)) >= Amp_mean(:,Animal_number)'*thresholdAmp)); % Determine how many channels are above their thresholds
%             Above_threshold = Above_threshold + sum((median(Line_length(:,n)) >= Line_mean(n,Animal_number)*threshold) &&(median(Amplitude(:,n)) >= Amp_mean(n,Animal_number)*thresholdAmp)) ;
%         end
            Seizure(k,1)=(Above_threshold>=ceil(channels/2)); % Check if more than half of the channels meet the specified requirements
    end
    Line_mean(:,Animal_number) = (Line_mean(:,Animal_number).*Mean_number+mean(Line_length)')./(Mean_number+1); % Update the Line length mean with the current window features values
    Amp_mean(:,Animal_number) = (Amp_mean(:,Animal_number).*Mean_number+mean(Amplitude)')./(Mean_number+1); % Update the amplitude mean with the current window features values
    Mean_number = Mean_number +1; % Update the number of mean samples used to the current point
end
save Features Line_mean Mean_number Amp_mean % Save all feature means for future data sets






function [Seizure_start, Seizure_end]= Start_end_time(Seizure,Seizure_time,~,Hours,minutes,seconds,Window_start_time)
% This function deermines when seizures have occured in a date time format
% given the study starttime and the binary seizure matrix and its
% corresponding times

Seizure_start ={0}; % Initialise a zero matrix
Seizure_end ={0};

Window_time = (Hours*60+minutes)*60+seconds + Window_start_time; % Determine the time that the current data starts at
load Seizure Seizure_init % load previous information about seizures in the last analysed data window
n=0; % Set te number of seizure ends to zero
m=0; % Set the number of seizure starts to zero
if ((Seizure(1) ~= Seizure_init)) % Determine if the seizure status has changed between windows
    if (Seizure(1)) % Check if a seizure has started at the start of the curent window
        n= n+1; % Increment the number of seizure starts
        Seizure_start_time_sec(n) = Window_time; % Specify start of seizure at beginning of window
    else % Check if seizure ended during data window transition
        m= m+1; % Increment number of seizure ends
        Seizure_end_time_sec(m) = Window_time; % Specify end of seizure at beginning of window
    end
end
for k = 1:length(Seizure)-1 % Loop through binary seizure matrix
    if (Seizure(k+1) ~= Seizure(k)) % Check if seizure status has changed between windows
        if (Seizure(k+1)) % Check if seizure started 
            n= n+1;% Increment the number of seizure starts
            Seizure_start_time_sec(n) = Window_time+Seizure_time(k);% Specify start of seizure at beginning of window plus the time of the transition
        else % Check if seizure ended
            m= m+1;% Increment the number of seizure ends
            Seizure_end_time_sec(m) = Window_time+Seizure_time(k);% Specify end of seizure at beginning of window plus the time of the transition
        end
    end
end

if m >0 % Check if a seizure end was detected
    for p =1:m % Loop through number of seizure ends
        Hours_end = Seizure_end_time_sec(p)/3600; % Determine the hour time for the seizure end
        Minutes_end = (Hours_end-floor(Hours_end))*60; % Determine the minute time for each seizure end
        Seconds_end = (Minutes_end-floor(Minutes_end))*60; % Determine the seconds time for each seizure end
        if (Hours_end >24) % Check if time is greater than 24 hour clock
            Hours_end = Hours_end-24; % Adjust time accordingly
        end
        Seizure_end{:,p} = [int2str(floor(Hours_end)),':',int2str(floor(Minutes_end)),':',int2str(floor(Seconds_end))]; % Create time string for seizure end
    end
end

if n >0 % Check if a seizure start was detected
    for p =1:n % Loop through number of seizure starts
        Hours_end = Seizure_start_time_sec(p)/3600;% Determine the hour time for the seizure start
        Minutes_end = (Hours_end-floor(Hours_end))*60;% Determine the minute time for each seizure start
        Seconds_end = (Minutes_end-floor(Minutes_end))*60;% Determine the seconds time for each seizure start
        if (Hours_end >24)% Check if time is greater than 24 hour clock
            Hours_end = Hours_end-24;% Adjust time accordingly
        end
        Seizure_start{:,p} = [int2str(floor(Hours_end)),':',int2str(floor(Minutes_end)),':',int2str(floor(Seconds_end))];% Create time string for seizure start
    end
end

Seizure_init = Seizure(end); % Specify last seizure status as intial seizure status for next data window
save Seizure Seizure_init % save Seizure_init for future use