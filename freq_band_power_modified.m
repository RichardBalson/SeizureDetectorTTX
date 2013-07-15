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

function f_meas_output = freq_band_power_modified(data,Fs,bands)

% 'data' has the dimension of calculation window by the number of channels.
% e.g. Fs = 3051 and 2 second calc. window, so 6102 points by 16 channels.

% 1. Apply window to time domain samples
[L,Chs] = size(data);
whan = 0.5*(ones(L,1)-cos(2*pi*(0:L-1)'/(L-1)));
whan = whan(:, ones(Chs,1));
data_w = data.*whan;
% 2. Zero pad windowed signal
p = 2^nextpow2(L); % for faster FFT calculations
% 3. apply FFT algorithm and scale
Y = fft(data_w,p); % p does the padding within the fft function.
% If data_w is a matrix, fft returns the Fourier transform of each column of the matrix.
% The frequency resolution is Fs/p.
PSD = Y.*conj(Y);  % Power Spectral Density

% figure
% f = Fs/2*linspace(0,1,p/2);
% plot(f,PSD(1:p/2))

% bands = [0 4; 4 8; 8 12; 12 30; 30 80; 80 250; 250 500]; % Zelmann, Zijlmans, Jacobs, Chatillon, Gotman, Clinical Neurophysiology (2009)
% bands = [0 4; 4 8; 8 12; 12 30; 30 100; 100 250; 250 400];
% bands = [0 4; 4 8; 8 12; 12 30; 30 48; 52 98; 102 148; 152 198; 202 248;
%     252 298; 302 348; 352 398]; % Bands with 50Hz and its harmonics omitted.

% Bring band scale from Hz to the FFT points in the vectors
bl = floor(bands(:)/Fs*p)+1;
% br = floor(bands(:,2)/Fs*p);

% chkbox_f_values has 7 values
% chkbox_f_values(1) == 1 -> Delta band (0-4 Hz) ON
% chkbox_f_values(2) == 1 -> Theta band (4-8 Hz) ON
% chkbox_f_values(3) == 1 -> Alpha band (8-12 Hz) ON
% chkbox_f_values(4) == 1 -> Beta band (12-30 Hz) ON
% chkbox_f_values(5) == 1 -> Gamma band (30-80 Hz) ON
% chkbox_f_values(6) == 1 -> Ripples band (80-250 Hz) ON
% chkbox_f_values(7) == 1 -> Fast Ripples band (250-500 Hz) ON

% Frequency band power matrices - size of 1 row by number of channels for
% columns
Chs = size(data,2);
f_meas_output = zeros(length(bands)-1,Chs);

if Fs< 2*bands(length(bands))
    exit;
end
TP_mat = sum(PSD(bl(1):bl(length(bands)),:)); % Total Effective Power
for k = 1:length(bands)-1
        f_meas_output(k,:) = sum(PSD(bl(k):bl(k+1),:));
        f_meas_output(k,:) = f_meas_output(k,:)./TP_mat;
end