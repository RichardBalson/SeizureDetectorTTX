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

function Analyse_data_characterise_bkg(data,window_length,sampling_frequency,Animal_number,Window_number,Date,interleave,interval_duration)

for m = 1:size(data,2)
    
    % Determine zero crossing for specified window length
    %     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    Split_length =0.5;
    
    [Zero_crossings, Amplitude Line_length Line_time] = FeatureExtraction(data(:,m),window_length,sampling_frequency,Split_length);
    
    [Year,Month,Day,Hours,Minutes,Seconds] = datevec(Date, 'dd/mm/yyyy HH:MM:SS');
    
    AMPM = Date(end-1:end);
    
    if (((strcmp(AMPM,'AM')) && (Hours~=12)))
        Hours = Hours +12;
    end
    Window_start_time = (Window_number-1)*interval_duration;
    Window_time = (Hours*60+Minutes)*60+Seconds + Window_start_time;
    
        Hours_end = Window_time/3600;
        Minutes_end = (Hours_end-floor(Hours_end))*60;
        Seconds_end = (Minutes_end-floor(Minutes_end))*60;
        if (Hours_end >24)
            Hours_end = Hours_end-24;
        end
        Window = [int2str(floor(Hours_end)),':',int2str(floor(Minutes_end)),':',int2str(floor(Seconds_end))];
   
    WriteExcel(Amplitude, Zero_crossings,Line_time,Line_length,Animal_number,Window_number,m,Date,Window)
    
end


% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
function [Zero_crossings Amplitude Line_length Line_time] = FeatureExtraction(data,windowlength,sample_rate,Split_length)

    
WindowSamples = windowlength*sample_rate;

Number_of_windows = floor(length(data)/WindowSamples);

Splits_per_window = floor(windowlength/Split_length);

Seizure = zeros(Number_of_windows*Splits_per_window);

SplitSamples = Split_length*sample_rate;

Line_time = 0:Split_length:(windowlength*Number_of_windows-Split_length);

Line_length = zeros(Splits_per_window*Number_of_windows,1);

Amplitude = zeros(Splits_per_window*Number_of_windows,1);

for k = 1:Number_of_windows
    for m = 1:Splits_per_window
    Sum_line = 0;
    Sum_Amplitude =0;
    Crossings_count=0;
        for j = 1:SplitSamples-1
             if (((data((k-1)*WindowSamples+(m-1)*SplitSamples+j) >0) && (data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1)<0)) ...
                || ((data((k-1)*WindowSamples+(m-1)*SplitSamples+j) <0) && (data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1)>0)))
                Crossings_count = Crossings_count +1;
             end
            Sum_Amplitude = Sum_Amplitude + abs(data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:));
            Sum_line = Sum_line + abs((data((k-1)*WindowSamples+(m-1)*SplitSamples+j+1,:)-data((k-1)*WindowSamples+(m-1)*SplitSamples+j,:)))*sample_rate;
        end
        Zero_crossings((k-1)*Splits_per_window+m) = Crossings_count;
        Amplitude((k-1)*Splits_per_window+m) = Sum_Amplitude/(WindowSamples-1);
        Line_length((k-1)*Splits_per_window+m) = Sum_line/(WindowSamples-1);
    end
end   


function WriteExcel(Amplitude, Crossings,Crossing_time,Line_length,Animal_number,j,m,Date,Window_Time)

[Year,Month,Day,Hours,Minutes,Seconds] = datevec(Date, 'dd/mm/yyyy HH:MM:SS');

Spreadsheet_Name = ['Animal_Background_',int2str(Animal_number),' D ',int2str(Day),'_',int2str(Month),'_',int2str(Year),'.xls'];
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
