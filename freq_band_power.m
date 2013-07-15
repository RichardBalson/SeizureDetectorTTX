function f_meas_output = freq_band_power(chkbox_f_values,data,Fs)

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

bands = [0 4; 4 8; 8 12; 12 30; 30 80; 80 250; 250 500]; % Zelmann, Zijlmans, Jacobs, Chatillon, Gotman, Clinical Neurophysiology (2009)
% bands = [0 4; 4 8; 8 12; 12 30; 30 100; 100 250; 250 400];
% bands = [0 4; 4 8; 8 12; 12 30; 30 48; 52 98; 102 148; 152 198; 202 248;
%     252 298; 302 348; 352 398]; % Bands with 50Hz and its harmonics omitted.

% Bring band scale from Hz to the FFT points in the vectors
bl = floor(bands(:,1)/Fs*p)+1;
br = floor(bands(:,2)/Fs*p);

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
nFeatures = sum(chkbox_f_values);
n = nFeatures + 1;
f_meas_output = zeros(nFeatures,Chs);

if Fs >= 1250 % CutOff = 0.8*(Fs/2)/DecFactor; For a CutOff of 500 Hz, FsDec should be at least 1250 Hz.
    TP_mat = sum(PSD(bl(1):br(7),:)); % Total Effective Power
    if chkbox_f_values(7) == 1 % Fast Ripples Band (250-500 Hz) ON
        f_meas_output(7,:) = sum(PSD(bl(7):br(7),:));
        f_meas_output(7,:) = f_meas_output(7,:)./TP_mat;
    end
    if chkbox_f_values(6) == 1 % Ripples Band (80-250 Hz) ON
        f_meas_output(6,:) = sum(PSD(bl(6):br(6),:));
        f_meas_output(6,:) = f_meas_output(6,:)./TP_mat;
    end
elseif Fs >= 625 && Fs < 1250
    TP_mat = sum(PSD(bl(1):br(6),:)); % Total Effective Power
    if chkbox_f_values(6) == 1 % Ripples Band (80-250 Hz) ON
        f_meas_output(6,:) = sum(PSD(bl(6):br(6),:));
        f_meas_output(6,:) = f_meas_output(6,:)./TP_mat;
    end
elseif Fs < 625 % CutOff = 0.8*(Fs/2)/DecFactor; For a CutOff of 250 Hz, FsDec should be at least 625 Hz.
    TP_mat = sum(PSD(bl(1):br(5),:)); % Total Effective Power
end
if chkbox_f_values(5) == 1 % Gamma Band (30-80 Hz) ON
    f_meas_output(5,:) = sum(PSD(bl(5):br(5),:));
    f_meas_output(5,:) = f_meas_output(5,:)./TP_mat;
end
if chkbox_f_values(4) == 1 % Beta Band (12-30 Hz) ON
    f_meas_output(4,:) = sum(PSD(bl(4):br(4),:));
    f_meas_output(4,:) = f_meas_output(4,:)./TP_mat;
end
if chkbox_f_values(3) == 1 % Alpha Band (8-12 Hz) ON
    f_meas_output(3,:) = sum(PSD(bl(3):br(3),:));
    f_meas_output(3,:) = f_meas_output(3,:)./TP_mat;
end
if chkbox_f_values(2) == 1 % Theta Band (4-8 Hz) ON
    f_meas_output(2,:) = sum(PSD(bl(2):br(2),:));
    f_meas_output(2,:) = f_meas_output(2,:)./TP_mat;
end
if chkbox_f_values(1) == 1 % Delta Band (0-4 Hz) ON
    f_meas_output(1,:) = sum(PSD(bl(1):br(1),:));
    f_meas_output(1,:) = f_meas_output(1,:)./TP_mat;
end
end