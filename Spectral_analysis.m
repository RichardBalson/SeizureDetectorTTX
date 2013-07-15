% function created by Richard Balson 05/02/2013

% description
% ~~~~~~~~~~~
% This script determines the power spectral density over specified window
% length and within specific frequency ranges

% last edit
% ~~~~~~~~~


% next edit
% ~~~~~~~~~

% Beginning of function
% ~~~~~~~~~~~~~~~~~~~~~

function Spectral_analysis(data,window_length,frequency_bands,sampling_frequency)

[EEG, chs] = size(data); % Determine how many EEG samples and channels there are

EEG_time = EEG/sampling_frequency; % Determine the the total time of EEG for the data

window_samples = window_length*sampling_frequency; % Determine number of samples in each window

splits = floor(EEG_time/window_length); % Determine number of data splits reuqired given the total 
                                        % EEG time and wondow length. Note that if 
                                        % mod(EEG_time/window_length) ~=0 then the last segment of data is augmented
                                        
data_split = zeros(window_samples,chs,splits); % Initialse split data matrix  
frequency_output =zeros(length(frequency_bands)-1,chs,splits);

for k = 1:splits
data_split(:,:,k) = data(((k-1)*window_samples+1):(k*window_samples),:);
frequency_output(:,:,k) = freq_band_power_modified(data_split(:,:,k),sampling_frequency,frequency_bands);
end

if (splits*window_length < EEG_time)
    data_augment = data((splits*window_length+1):length(data));
    frequency_output_augmented =  freq_band_power_modified(data_augment,sampling_frequency,frequency_bands);
else
    frequency_output_augmented =[];
end

for j = 1:chs
    plot_spectral_analysis(window_length, splits, frequency_bands, [frequency_output(:,j,:)]);
end

    