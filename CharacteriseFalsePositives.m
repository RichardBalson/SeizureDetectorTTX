function CharacteriseFalsePositives(FalsePositiveTimes,EEGFilepath,Channel,band_coeff)
% Created by Richard Balson 10/10/2013

Start.Padding =10;
DetectorSettings.ZCDThreshold = 6;
DetectorSettings.PlotFeatures =0;
DetectorSettings.FP =1;
window_length =1;
[Animals, Days] = size(FalsePositiveTimes);
AddedDuration = (0:(Days-1))*24*60*60;
try
    [fs, ~,~,~,~,StartDateTime,StudyLength,~] = CMConnect_ProFusionEEG4(EEGFilepath); % Determine study frequency (fs), the time and date the study started (StartDateTime), its length (StudyLength) and the names of channels (ChennelName)
catch
    [fs, ~,~,~,~,StartDateTime,StudyLength,~] = CMConnect_ProFusionEEG41(EEGFilepath);
end
[Start.Year,Start.Month,Start.Day,Start.Hours,Start.Minutes,Start.Seconds] = datevec(StartDateTime, 'dd/mm/yyyy HH:MM:SS');
Start.AMPM = StartDateTime(end-1:end);
Start.StudyLength = StudyLength;
for k =1:Animals
    for j = 1:Days
        Start.CurrentDay = Start.Day+j-1;
        if ~isempty(FalsePositiveTimes{k,j})
            FalsePositiveTimes{k,j} = FalsePositiveTimes{k,j}+ AddedDuration(j);
            ChannelS = sum(Channel(1:k))-Channel(k)+1;
            ChannelL = ChannelS:(ChannelS+Channel(k)-1);
            for FP = 1:size(FalsePositiveTimes{k,j},1)
                clear All_Channel_Data
                Times = FalsePositiveTimes{k,j}(FP,:);
                Times(1) = Times(1) -Start.Padding;
                Duration = Times(2) - Times(1) +Start.Padding;
                Count =0;
                for m = ChannelL
                    Count = Count+1;
                    [Data_out,~] = Profusion_Ext_Filt_GUI(Times(1), Duration,1, band_coeff,m,0);
                    if m ==1 % Check if currently looking at first channel
                        All_Channel_Data = zeros(length(Data_out),Channel(k)); % Intialise variable to store all channels for the particular animal considered
                    end
                    All_Channel_Data(:,Count) = Data_out;
                end
                Analyse_data_characterise(All_Channel_Data,window_length,0,fs,k,FP,Start,DetectorSettings,0) % Analyse data, results are sent to spreadsheets
            end
        end
    end
end
end


