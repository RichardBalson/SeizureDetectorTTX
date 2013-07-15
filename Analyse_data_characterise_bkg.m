% function created by Richard Balson 26/03/2013

% description
% ~~~~~~~~~~~
% This script determines the power spectral density over specified window
% length and within specific frequency ranges, Modification of
% plot_spectral_analysis_characterise to include zero crossing detector

% last edit
% ~~~~~~~~~


% next edit
% ~~~~~~~~~

% Beginning of function
% ~~~~~~~~~~~~~~~~~~~~~

function Analyse_data_plot_multiple_background(data,window_length,sampling_frequency,Animal_number,Window_number,Start,interleave,interval_duration)

for m = 1:size(data,2)
    
    % Determine zero crossing for specified window length
    %     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    [Crossings Crossing_time] = ZeroCrossingDetectorN(data(:,m),window_length,sampling_frequency,interleave);
    [Amplitude Amplitude_time] = WindowAmplitude(data(:,m),window_length,sampling_frequency,interleave);
    [Line_length LL_time] = WindowLineLength(data(:,m),window_length,sampling_frequency,interleave);
    
    if (((strcmp(Start.AMPM,'AM')) && (Start.Hours~=12)))
        Hours = Hours +12;
    end
    Window_start_time = (Window_number-1)*interval_duration;
    Window_time = (Start.Hours*60+Start.Minutes)*60+Start.Seconds + Window_start_time;
    
    Hours_end = Window_time/3600;
    Minutes_end = (Hours_end-floor(Hours_end))*60;
    Seconds_end = (Minutes_end-floor(Minutes_end))*60;
    if (Hours_end >24)
        Hours_end = Hours_end-24;
    end
    Window = [int2str(floor(Hours_end)),':',int2str(floor(Minutes_end)),':',int2str(floor(Seconds_end))];
    
    
    %     nfeatures = [1 1 1 1];
    %     % Determine PSD of output
    %     %     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    %
    %     [EEG, chs] = size(data(:,m)); % Determine how many EEG samples and channels there are
    %
    %     EEG_time = EEG/sampling_frequency; % Determine the the total time of EEG for the data
    %
    %     window_samples = round(window_length*sampling_frequency); % Determine number of samples in each window
    %
    %     splits = floor(EEG_time/window_length); % Determine number of data splits reuqired given the total
    %     % EEG time and wondow length. Note that if
    %     % mod(EEG_time/window_length) ~=0 then the last segment of data is augmented
    %
    %     data_split = zeros(window_samples,chs,splits); % Initialse split data matrix
    %     frequency_output =zeros(length(frequency_bands)-1,chs,splits);
    %
    %     for k = 1:splits
    %         data_split(:,:,k) = data(((k-1)*window_samples+1):(k*window_samples),m);
    %         frequency_output(:,:,k) = freq_band_power_modified(data_split(:,:,k),sampling_frequency,frequency_bands);
    %     end
    %
    %     if (round(splits*window_length) < EEG_time)
    %         data_augment = data((round(splits*window_length)+1):length(data),m);
    %         frequency_output_augmented =  freq_band_power_modified(data_augment,sampling_frequency,frequency_bands);
    %     else
    %         frequency_output_augmented =[];
    %     end
    
    % Plot data and features for all channels
    
    %     t = linspace(0,size(data,1)/sampling_frequency,size(data,1));
    %     plot_spectral_analysis_characteriseN(window_length, splits, frequency_bands, frequency_output(:,1,:),Crossings,Crossing_time,data,t,Animal_number,j,m, Amplitude,Line_length,nfeatures);
    WriteExcel(Amplitude, Crossings,Crossing_time,Line_length,Animal_number,Window_number,m,Start,Window)
    
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function plot_spectral_analysis_characteriseN(window_length, splits, bands, frequency_analysis,Crossings,Crossing_time,data,t,k,j,m,Amplitude,Line_length,nfeatures)


Channels = size(data,2);
% for k = 1:40
% new = output8(round(length(output8)/40)*(k-1)+1:round(length(output8)/40)*k);
% f_meas_output(:,k) = freq_band_power_modified(new,Fs,bands)*2;
% end

% y= {'0-4'; '4-8';'8-12';'12-30';'30-80';'80-250';'250-500'};
% y = [0,250];
total_time = window_length*(splits-1);
y = bands(2:length(bands));
x= 0:window_length:total_time;
plot_frequency(:,:) = frequency_analysis(:,1,:);
if m==1
    figure
end
subplot(sum(nfeatures)+1,Channels,m),plot(t,data(:,m))
if m ==1
    ylabel('EEG')
end
% plot(t,1000*dataIn(1:length(data)),'r')
title(['Channel ',int2str(m)]);
if (nfeatures(1)==1)
    subplot(sum(nfeatures)+1,Channels,m+Channels),plot(Crossing_time,Crossings);
    if m ==1
        ylabel('ZeroCrossings')
    elseif m==2
        xlabel(['Animal ',int2str(k),', Seizure ',int2str(j)])
    end
end
if (nfeatures(2)==1)
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:2))*Channels),surf(x,y,(plot_frequency)) %imagesc(x,y,10*log10(plot_frequency))
    if m ==1
        ylabel('PSD')
    end
    axis tight
    view(0,90);
end
if (nfeatures(3)==1)
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:3))*Channels),plot(Crossing_time,Amplitude);
    if m ==1
        ylabel('Maximum Amplitude')
    end
    hold on
end
if (nfeatures(4)==1)
    subplot(sum(nfeatures)+1,Channels,m+sum(nfeatures(1:4))*Channels),plot(Crossing_time,Line_length);
    if m ==1
        ylabel('Line Length')
    elseif m==2
        xlabel('Time (s)')
    end
end
%
% bar(x,f_meas_output','stacked')
% surfc(x,y,f_meas_output)
% spectogram

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [Crossings,time] = ZeroCrossingDetectorN(data,windowlength,sample_rate,varargin)

error(nargchk(3,5,nargin,'struct'));

if (nargin ==4)
    interleave = varargin{1};
    interleave_duration = windowlength/5;
elseif (nargin ==5)
    interleave_duration =  varargin{end};
else interleave =0;
    interleave_duration =0;
end

periods = [windowlength interleave_duration];

interleave_index = interleave +1;

WindowSamples = [round(sample_rate*windowlength) round(sample_rate*interleave_duration)];

Number_of_windows = floor(length(data)/WindowSamples(interleave_index));

Window_adjuster = [0 windowlength/interleave_duration];

Crossings = zeros(1,Number_of_windows-Window_adjuster(interleave_index));

time = 0:periods(interleave_index):(Number_of_windows-1-Window_adjuster(interleave_index))*periods(interleave_index);

for k = 1:Number_of_windows-Window_adjuster(interleave_index)
    for j =1:WindowSamples(1)-1
        if (((data((k-1)*WindowSamples(interleave_index)+j) >0) && (data((k-1)*WindowSamples(interleave_index)+j+1)<0)) ...
                || ((data((k-1)*WindowSamples(interleave_index)+j) <0) && (data((k-1)*WindowSamples(interleave_index)+j+1)>0)))
            Crossings(k) = Crossings(k) +1;
        end
    end
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function [Amplitude, time] = WindowAmplitude(data,windowlength,sample_rate,varargin)

error(nargchk(3,5,nargin,'struct'));

if (nargin ==4)
    interleave = varargin{1};
    interleave_duration = windowlength/5;
elseif (nargin ==5)
    interleave_duration =  varargin{end};
else interleave =0;
    interleave_duration =0;
end

periods = [windowlength interleave_duration];

interleave_index = interleave +1;

WindowSamples = [round(sample_rate*windowlength) round(sample_rate*interleave_duration)];

Number_of_windows = floor(length(data)/WindowSamples(interleave_index));

Window_adjuster = [0 windowlength/interleave_duration];

Amplitude = zeros(1,Number_of_windows-Window_adjuster(interleave_index));

time = 0:periods(interleave_index):(Number_of_windows-1-Window_adjuster(interleave_index))*periods(interleave_index);

for k = 1:Number_of_windows-Window_adjuster(interleave_index)
    Amplitude(k) = max(data((k-1)*WindowSamples(interleave_index)+1:(k-1)*WindowSamples(interleave_index)+WindowSamples(1)));
end

for k = 1:Number_of_windows-Window_adjuster(interleave_index)
    Sum_line = 0;
    for j =1:WindowSamples(1)-1
        Sum_amplitude = Sum_line + abs(data((k-1)*WindowSamples(interleave_index)+j));
    end
    Amplitude(k) = Sum_amplitude/WindowSamples(1);
end

function [Line_length LL_time] = WindowLineLength(data,windowlength,sample_rate,varargin)

error(nargchk(3,5,nargin,'struct'));

if (nargin ==4)
    interleave = varargin{1};
    interleave_duration = windowlength/5;
elseif (nargin ==5)
    interleave_duration =  varargin{end};
else interleave =0;
    interleave_duration =0;
end

periods = [windowlength interleave_duration];

interleave_index = interleave +1;

WindowSamples = [round(sample_rate*windowlength) round(sample_rate*interleave_duration)];

Number_of_windows = floor(length(data)/WindowSamples(interleave_index));

Window_adjuster = [0 windowlength/interleave_duration];

Amplitude = zeros(1,Number_of_windows-Window_adjuster(interleave_index));

LL_time = 0:periods(interleave_index):(Number_of_windows-1-Window_adjuster(interleave_index))*periods(interleave_index);

for k = 1:Number_of_windows-Window_adjuster(interleave_index)
    Sum_line = 0;
    for j =1:WindowSamples(1)-1
        Sum_line = Sum_line + abs((data((k-1)*WindowSamples(interleave_index)+j+1)-data((k-1)*WindowSamples(interleave_index)+j)))*sample_rate;
    end
    Line_length(k) = Sum_line/WindowSamples(1);
end


function WriteExcel(Amplitude, Crossings,Crossing_time,Line_length,Animal_number,j,m,Start,Window_Time)

Spreadsheet_Name = ['Animal_Background_',int2str(Animal_number),' D ',int2str(Start.CurrentDay),'_',int2str(Start.Month),'_',int2str(Start.Year),'.xls'];
Sheet_name = ['Window',int2str(j)];

columnN = [char((m-1)*6+65),'1'];
Excel_dataN = {['Channel ',int2str(m)]};
xlswrite(Spreadsheet_Name,Excel_dataN,Sheet_name,columnN);

column = [char((m-1)*6+65),'3'];
Excel_dataT = {'Maximum Amplitude','Zero Crossings', 'Line Length', 'Time (s)','EEG Data (mV)', 'Time (s)'};
xlswrite(Spreadsheet_Name,Excel_dataT,Sheet_name,column);

columnW = [char((m-1)*6+65),'2'];
WindowD = {'Window Start Time', Window_Time};
xlswrite(Spreadsheet_Name,WindowD,Sheet_name,columnW);

columnD = [char((m-1)*6+65),'4'];
Excel_dataD = [Amplitude',Crossings',Line_length',Crossing_time'];
xlswrite(Spreadsheet_Name,Excel_dataD,Sheet_name,columnD);

% xlswrite(Spreadsheet_Name,EEG_data,Sheet_name,columnE);
