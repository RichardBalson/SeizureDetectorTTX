% function created by Richard Balson 05/02/2013

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

function Analyse_data_plot(data,window_length,frequency_bands,sampling_frequency,Channel,Channel_number_base,Animal_number,j,interleave)

[Crossings Crossing_time] = ZeroCrossingDetector(data,window_length,sampling_frequency,interleave);

[EEG, chs] = size(data); % Determine how many EEG samples and channels there are

EEG_time = EEG/sampling_frequency; % Determine the the total time of EEG for the data

window_samples = round(window_length*sampling_frequency); % Determine number of samples in each window

splits = floor(EEG_time/window_length); % Determine number of data splits reuqired given the total 
                                        % EEG time and wondow length. Note that if 
                                        % mod(EEG_time/window_length) ~=0 then the last segment of data is augmented
                                        
data_split = zeros(window_samples,chs,splits); % Initialse split data matrix  
frequency_output =zeros(length(frequency_bands)-1,chs,splits);

for k = 1:splits
data_split(:,:,k) = data(((k-1)*window_samples+1):(k*window_samples),:);
frequency_output(:,:,k) = freq_band_power_modified(data_split(:,:,k),sampling_frequency,frequency_bands);
end

if (round(splits*window_length) < EEG_time)
    data_augment = data((round(splits*window_length)+1):length(data));
    frequency_output_augmented =  freq_band_power_modified(data_augment,sampling_frequency,frequency_bands);
else
    frequency_output_augmented =[];
end
t = linspace(0,size(data,1)/sampling_frequency,size(data,1));
plot_spectral_analysis_characterise(window_length, splits, frequency_bands, frequency_output(:,1,:),Crossings,Crossing_time,data,t,Channel,Channel_number_base,Animal_number,j);


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



function [Crossings,time] = ZeroCrossingDetector(data,windowlength,sample_rate,varargin)

error(nargchk(3,5,nargin,'struct'));

if (nargin ==4)
    interleave = varargin{1};
    interleave_duration = windowlength/5;
elseif (nargin ==5)
    interleave_duration =  varargin{end};
else interleave =0;
    interleave_duration =0;
end

data = data;

periods = [windowlength interleave_duration];

interleave_index = interleave +1;

WindowSamples = [round(sample_rate*windowlength) round(sample_rate*interleave_duration)];

Number_of_windows = floor(length(data)/WindowSamples(interleave_index));

Crossings = zeros(1,Number_of_windows);

Window_adjuster = [0 windowlength/interleave_duration];

time = 0:periods(interleave_index):(Number_of_windows-1)*periods(interleave_index);

for k = 1:Number_of_windows-Window_adjuster(interleave_index)
    for j =1:WindowSamples(1)-1
        if (((data((k-1)*WindowSamples(interleave_index)+j) >0) && (data((k-1)*WindowSamples(interleave_index)+j+1)<0)) ...
         || ((data((k-1)*WindowSamples(interleave_index)+j) <0) && (data((k-1)*WindowSamples(interleave_index)+j+1)>0)))
            Crossings(k) = Crossings(k) +1;
        end
    end
end

% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

function plot_spectral_analysis_characterise(window_length, splits, bands, frequency_analysis,Crossings,Crossing_time,data,t,Channel,Channel_number_base,k,j)

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
figure
subplot(3,1,1),plot(t,data(:,1))
hold on
% plot(t,1000*dataIn(1:length(data)),'r')
title(['Animal ',int2str(k),', Seizure ',int2str(j),', Channel ',int2str(Channel-Channel_number_base)]);
subplot(3,1,2),plot(Crossing_time,Crossings);
subplot(3,1,3),surf(x,y,(plot_frequency)) %imagesc(x,y,10*log10(plot_frequency))
axis tight
view(0,90);
% bar(x,f_meas_output','stacked')
% surfc(x,y,f_meas_output)
% spectogram

    