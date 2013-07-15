% script created by Richard Balson 22/01/2013

% description
% ~~~~~~~~~~~
% This script plots a spectrogram of the frequency bands specified

% last edit
% ~~~~~~~~~


% next edit
% ~~~~~~~~~

% Beginning of script
% ~~~~~~~~~~~~~~~~~~~~~


function plot_spectral_analysis(window_length, splits, bands, frequency_analysis)

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
surf(x,y,(plot_frequency)) %imagesc(x,y,10*log10(plot_frequency))
axis tight
view(0,90);
% bar(x,f_meas_output','stacked')
% surfc(x,y,f_meas_output)
% spectogram