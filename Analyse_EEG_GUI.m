function Analyse_EEG_GUI(DetectorSettings,ProgramType)
% function created by Richard Balson 23/04/2013
% This script uses the output of DetectorGUI to determine what should be
% done with the data from profusion, and displays the results. All results
% are output to excel files, that are named according to the specifications
% set in the function input detector settings. DetectorSettings is a
% structure of the form DetectorSettings =
% struct('EEGFilepath',{{0}},'ExcelFilepath',{{0}},'PlotFeatures',0,'LLThres',0,'AmpThres',0)
% and ProgramType is a 1x3 vector where each element is a binary value.


% Add path for profusion connection and data extraction files

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Extract Data from profusion
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Day_duration = 24*60*60;
try
    [fs, ~,~,~,~,StartDateTime,StudyLength,ChannelName] = CMConnect_ProFusionEEG4(DetectorSettings.EEGFilepath); % Determine study frequency (fs), the time and date the study started (StartDateTime), its length (StudyLength) and the names of channels (ChennelName)
catch
    [fs, ~,~,~,~,StartDateTime,StudyLength,ChannelName] = CMConnect_ProFusionEEG41(DetectorSettings.EEGFilepath);
end
% fs and StudyLength are integers, StartDateTime is a date vector in string
% format and channelname is a cell of strings
Days=1; % Check how many days the study consists of
for k =1:10
    if (StudyLength>Day_duration*k)
        Days = k+1;
    else
        break
    end
end

[Start.Year,Start.Month,Start.Day,Start.Hours,Start.Minutes,Start.Seconds] = datevec(StartDateTime, 'dd/mm/yyyy HH:MM:SS');
Start.AMPM = StartDateTime(end-1:end);


[ChannelLength, Number_of_animals]  = CheckChannels(ChannelName); % Determine the number of channels per animal

if ~strcmp(DetectorSettings.Channels,'all')
    for k =1:ceil(length(DetectorSettings.Channels)/2)
        ChannelT(k) = str2double(DetectorSettings.Channels(1+2*(k-1)));
    end
else
    ChannelT= ChannelLength; 
end


if ~strcmp(DetectorSettings.Animals,'all')
    for k =1:ceil(length(DetectorSettings.Animals)/2)
        AnimalT(k) = str2double(DetectorSettings.Animals(1+2*(k-1)));
    end
else
    AnimalT=1:Number_of_animals;
end
AnimalN =[];
for k = 1:length(AnimalT)
    if ChannelLength(AnimalT(k)) ~=0;
        AnimalN =cat(2,AnimalN,AnimalT(k));
    end
end
% ChannelLength is a Number_of_animalsx1 vector where each element
% indicates the number of channels for each animal. Number_of_animals
% specifies the last cage number used in the study for example if there are
% four animals in cages 1,3,5 and 7 each with four channels than
% Number_of_animals = 7 and ChannelLength is 7x1 vector [4,0,4,0,4,0,4]'

if any(ProgramType)
    
    % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Set initial settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Specify prgram specific settings
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    window_length =1; % Units of seconds, specify the length of windows used for analysis, this setting is generally used for seizure detection
    if ProgramType(1) ==1 % Seizure Detection is specified
        Start.minSeizureD = str2num(DetectorSettings.MinSeizure);
        LLthreshold =str2num(DetectorSettings.LLThres); % Get Line length threshold
        Ampthreshold =str2num(DetectorSettings.AmpThres); % Get amplitude threshold
        window_length =5; % Units of seconds, specify the length of windows used for analysis, this setting is generally used for seizure detection
        if DetectorSettings.CompareSeizures
            Seizure_Compare = ReadEEGExcel(DetectorSettings.ExcelFilepath,'Matlab',Number_of_animals,Start.Day,0);
        end
    end
    if ((strcmp(Start.AMPM,'AM')) || ((Start.Hours == 12) && (strcmp(Start.AMPM,'PM')))) % This script filters and extracts profusion data. The startime is the
        % starttime of seizures relative to midnight, in seconds,
        Time_adjustment_Days = ((Start.Hours)*60+Start.Minutes)*60 + Start.Seconds; % remove time delay from recording time initialisation
    else
        Time_adjustment_Days = ((Start.Hours+12)*60+Start.Minutes)*60 + Start.Seconds; % remove time delay from recording time initialisation
    end
    if ProgramType(2) ==1 % Seizure Characterisation is specified
        Padding = str2double(DetectorSettings.Padding); % Specify padding used at start and end of seizure
        Start.Padding = Padding;
        Time_adjustment = Time_adjustment_Days;
        Time_adjustment_Days =0;
        Seizure_time = ReadEEGExcel(DetectorSettings.ExcelFilepath,'Matlab',Number_of_animals,Start.Day,Time_adjustment);
        Seizure_Compare=[0,0];
        % Extract times that seizures occur for each animal Seizure_time is a nx2xNumber_of_animals matrix.
        % Where n is the max number of seizures for any animal observed. Column
        % one indicates seizure start times and column two the corresponind end
        % time For example elemnt 4,2,3 specifies the fourth seizure end time
        % for animal in cage 3
        % Determine time adjustment for annotated seizures
        Plot_features = DetectorSettings.PlotFeatures; % Get plotfeatures setting
    else ProgramType(3) % Seizure Detection or characteris all data selected
        Time_adjustment =0;
        interval_duration = 150; % Specify data segment lengths to analyse
        Number_of_windows = floor(StudyLength/interval_duration); % Specify number of windows to analyse. Notice that by doing this the last data segment < interval_duration in length is lost
        % Notice that for Seizure Detection and Characterise all data, all data
        % needs to be anlaysed therefore their duration and number of windows
        % are identical
    end
    
    
    % Specify general analysis settings for all programs
    % ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    % Intialise counting variables
    % ~~~~~~~~~~~~~~~~~~~~~~~
    
    Channel_number =0; % Initialise counting of channels
    Channel_number_base =0; % Intialise base for counting
    
    % Specify analysis features
    % ~~~~~~~~~~~~~~~~~
    
    Decimate =1; % Specify decimation rate for data, for example if decimation is 2 frequency = fs/2. Note Decimate cannot be less than one
    
    highcutoff = 2.5; % Specify highcutoff frequency for filter
    
    lowcutoff = 40; % Specify low cutoff frequency for filter
    % Data will have frequency content between highcutoff and lowcutoff
    
    frequency_bands = 0:25; % Specify freqeuncy bands for analysis.
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Algorithm
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Specify the coefficients for the fir filter as required
    band_coeff = filtercoeff(lowcutoff,highcutoff,fs);
    
    % Create a structure to store seizure detection data
    Animal=repmat(struct('SeizureStartT',{{'0'}},'SeizureEndT',{{'0'}}),Number_of_animals,1);
    
    for k= AnimalN % Loop through number of animals
        
        %     if ChannelLength(k) ==0 % Check if the specified cage was not used in recordings
        %         continue % Start next loop, or increase the caage number
        %     end
        
        if ProgramType(1)==1 % Check if program type is Seizure Detection
            Seizure_init =0; % Intialise seizure status
            save Seizure Seizure_init % save Seizure_init for later use
            Excel_pos = [0 0]; % Intial position in excel file
            save Current_Excel_pos Excel_pos % save Excel_pos for later use
            Line_mean = zeros(round(ChannelLength(k)),Number_of_animals); % Intialise mean of line length for all animals
            Mean_number =0; % Intilaise a count of the number of windows that have passed
            Amp_mean =zeros(round(ChannelLength(k)),Number_of_animals); % Intiliase mean of amplitude for all animals
            save Features Line_mean Amp_mean Mean_number % save all features for later use
            clear Seizure_init Excel_pos Previous_mean Amp_mean % clear all variables as they are no longer required in this function
        end
        
        if k>1 % Check if the loop is above 1
            Channel_number_base = Channel_number_base+ChannelLength(k-1); % Specify new channel numbers to look at for each animal
            % This indicaes the number of channels that have been analysed for
            % all previous cages, excluding the current cage
        end
        
        if ProgramType(2) ==1 % Check if the program type is seizure characterisation
            Number_of_windows = size(Seizure_time(Seizure_time(:,1,k)~=0),1); % Determine number of windows required for seizure characterisation
            % Note that this is simply the number of seizures observed for the
            % animal considered in the loop
        end
        Start.CurrentDay=Start.Day;
        inc=1;
        for j = 1:Number_of_windows % Loop through the number of windows in the data
            
            if ((ProgramType(3) ==1) || (ProgramType(1) ==1)) % Check if all data is being analysed (For Programs 1 and 3)
                StartTime = (j-1)*interval_duration+1; % Determine start time for current window
                Duration = interval_duration; % Specify duration of current window
            else % Check if specified data needs to be analysed (For program 2)
                StartTime = Seizure_time(j,1,k)-Padding; % Determine start time, here it is the seizure start time less the specifed padding
                Duration = round(Seizure_time(j,2,k)-StartTime+Padding); % Determine window duration
            end
            if StartTime > (inc*Day_duration-Time_adjustment_Days)
                Start.CurrentDay = Start.CurrentDay+1;
                inc = inc+1;
                Animal1=repmat(struct('SeizureStartT',{{'0'}},'SeizureEndT',{{'0'}}),Number_of_animals,1);
                Animal = cat(2,Animal,Animal1);
            end
            
            clear All_Channel_Data % Clear variable containing all data for a particular animal and window
            
            Channel_number= Channel_number_base; % Return channel number to original base for each new window for specifed animal
            if size(ChannelT,2) >1
                ChannelSelect = ChannelT;
            else
                ChannelSelect = 1:round(ChannelLength(k));
            end
            for m = ChannelSelect % Loop through number of channels for each animal
                
                clear Data_out dataIn % Clear variables containing current animal, channel and window data
                
                Channel_numberT = Channel_number+m; % Increase the channel number needed to be analysed
                
                [Data_out dataIn] = Profusion_Ext_Filt_GUI(StartTime, Duration,Decimate, band_coeff,Channel_numberT,Time_adjustment); % Extract data from profusion, Data_out is filtered and dataIn is not.
                if DetectorSettings.SaveData
                    save(['Animal',int2str(k),'Seizure',int2str(j),'Channel',int2str(m),'.mat'],'dataIn','Data_out');
                end
                
                if m ==1 % Check if currently looking at first channel
                    
                    All_Channel_Data = zeros(length(Data_out),length(ChannelSelect)); % Intialise variable to store all channels for the particular animal considered
                    
                end
                if ~isempty(Data_out) % Check if data was extracted from profusion
                    All_Channel_Data(:,m) = Data_out; % Put current data from specified channel into channel specific format
                end
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Data Analysis
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            
            if (exist('All_Channel_Data','var')) % Check whether data has been inserted into All_Channel_Data
                if ProgramType(1) ==1 % Seizure Detector
                    [Seizure_start, Seizure_end] = Seizure_Detector2(All_Channel_Data,window_length,fs,j,Start,interval_duration,LLthreshold,k,Ampthreshold); % Determine whether a seizure occured in the specifed winodw for the particular animal, and determine the start and end time
                    
                    if (~isempty(Seizure_start)) % Check if a seizure start was found
                        Animal(k,inc).SeizureStartT(end+1*(j>1):end+1*(j>1)+length(Seizure_start)-1) = num2cell(Seizure_start'); % Write data to animal specific structure structure
                    end
                    if (~isempty(Seizure_end)) % Check if a seizure end was found
                        Animal(k,inc).SeizureEndT(end+1*(j>1):end+1*(j>1)+length(Seizure_end)-1) = num2cell(Seizure_end');% Write data to animal specific structure structure
                    end
                elseif ProgramType(2) ==1 % Seizure Characterise
                    Analyse_data_characterise(All_Channel_Data,window_length,frequency_bands,fs,k,j,Start,DetectorSettings.PlotFeatures) % Analyse data, results are sent to spreadsheets
                else
                    Analyse_data_characterise_bkg(All_Channel_Data,window_length,frequency_bands,fs,k,j,Start) % Analyse data, results are sent to spreadsheets
                end
            end
            
        end
        if ProgramType(1) ==1 % Check if seizure detection is selected
            Sheet_name = 'Seizure Start and End'; % Specify sheet name
            for Day = 1:inc
                Spreadsheet_Name = ['SeizuresDetected_AnimalNumber ',int2str(k),' SD',int2str(Start.Day),'CD',int2str(Start.Day+Day-1),'_',int2str(Start.Month),'_',int2str(Start.Year),'.xls']; % Specify name for spreadsheet
                xlswrite(Spreadsheet_Name,{'Seizure Start', 'Seizure End'},Sheet_name,'A1'); % Write names for each column
                if length(Animal(k,Day).SeizureStartT)>1 % Check if a seizure was found for the animal of interest
                    a={Animal(k,Day).SeizureStartT{:}; Animal(k,Day).SeizureEndT{:}}'; % Create a cell with all seizure data
                    xlswrite(Spreadsheet_Name,[a{2:end,1}; a{2:end,2}]',Sheet_name,'A2'); % Write seizure data detected into excel sheet
                end
            end
            if DetectorSettings.CompareSeizures
                Time_adjustmentT = ((Start.Hours)*60+Start.Minutes)*60 + Start.Seconds;
                Temp = Seizure_Compare(:,:,k);
                Temp(Temp<Time_adjustmentT) = Temp(Temp<Time_adjustmentT)+Day_duration;
                Annotated_data = zeros(size(Seizure_Compare,1),size(Seizure_Compare,2),2,inc);
                for Day = 1:inc
                    Annotated_data = Temp(Temp(:,1)>Day_duration*(Day-1) & Temp(:,1)<Day_duration*(Day),:);
                    %  Sort out Seizure Compare File to make sure that it is working correctly for different days
                    CompareSeizures(Start,k,Annotated_data,Animal(k,Day),Day);
                end
            end
        end
        
    end
end
if DetectorSettings.ProcessData
    if ProgramType(2)==1
        for k = AnimalN
            Directory = dir(['AnimalNumber ',int2str(k),'*SD',int2str(Start.Day),'*.xls']);
            if ~isempty(Directory)
                Directory(1).Animal=k;
                ProcessData(Directory,Start);
            end
        end
    elseif DetectorSettings.ProcessData
        for k = AnimalN
            Directory = dir(['AnimalNumber ',int2str(k),'*SD',int2str(Start.Day),'*.xls']);
            if ~isempty(Directory)
                Directory(1:end).Animal=k;
                ProcessData(Directory,Start);
            end
        end
    end
end

