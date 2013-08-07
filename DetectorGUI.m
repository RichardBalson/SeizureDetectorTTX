function DetectorGUI
%This function generates the GUI for the designed seizure detector
%   Created by Richard Balson 16/04/2013

%J:\JLJ\20130211{67E4360B-DF57-41A9-89BD-AB24922620C9}.eeg
%J:\JLJ\20130124{632926F5-DF3B-4F03-85FC-593FD25EEC65}.eeg
%C:\Users\balsonr\Dropbox\Polymer Project Jonathan)\Test\GUI1\EEG Matlab Sorting.xlsx
%J:\JLJ\20130120{6E9AE138-D330-4BF2-AFC0-C862D1E254D4}.eeg
% H:\Jonathan\Seizure characterise\GUIv2\EEG Matlab Sorting.xlsx
% J:\rbalson\Control\20130312{144A4128-D510-462B-BAFB-1A99CABB99E4}.eeg
% C:\Users\balsonr\Dropbox\Work\PhD\Projects\Estimation\UKF\UKFFinal\GUI\EEGData\20130312Annotate.xlsx


clear
clc
close all

addpath(genpath(pwd));

% Create structure used for setting specified by GUI.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ProgramType = [0 0 0];% Index 1 Detector, 2 characterise seizures, 3 characterise background

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global h;
h = figure('Name','Seizure Detector');

% Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Seizure detection analysis
Seizure_Detection= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.9 0.2 0.04],'string','Seizure Detection','callback',@DetectCHK);

% Seizure characterisation
Seizure_Characterise =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.85 0.25 0.04],'string','Characterise Seizures','callback',@SeizCharCHK);

% Characterise all data
Characterise_all_data =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.8 0.25 0.04],'string','Characterise Data','callback',@BackgCHK);

Post_process_characterise = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.75 0.25 0.04],'string','Process Characterised Data','callback',@ProcessData);

% Conditional Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when seizure charcterisation is checked, Check if features need
% to be plotted
Plot_features= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.29 0.04],'string','Plot Features','Visible','off');

Save_data= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.85 0.29 0.04],'string','Save Data','Visible','off');

% Availbale when Seizure Detection is checked, check if a comparison
% between detected and annotated seizures needs to be made
Compare_Seizures = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.29 0.04],'string','Compare detected and characterised seizures','Visible','off','Callback',@CompareCHK);

Post_process_annotate = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.8 0.29 0.04],'string','Process Characterised Data','Visible','Off');

Select_Channels = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.85 0.29 0.04],'string','Specify Channels for detector','Visible','off','Callback',@SelectChannels);

Select_Seizure_Duration = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.8 0.29 0.04],'string','Specify Minimum seizure duration','Visible','off','Callback',@SpecifyDuration);

% Text
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Text detailing information for the filepath
uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.9 0.35 0.04],'string','EEG data Path (c:\...\2012.eeg file)');

% Specify channels text
uicontrol('style','text','parent',h,'units','normalized','position',[0.4 0.7 0.25 0.04],'string','Analyse Animals (1,2,..,8)');

% Conditional text
% ~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Characterise is checked. Details of filepath for
% excel file
EEGSort= uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','EEG Seizure Data Times (c:\...\2012Sorted.xls file)','Visible','off');

% Available when Seizure Detection is checked. Details on line length
% threshold.
LineLengthString= uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.75 0.35 0.04],'string','Line Length Threshold','Visible','off'); %

% Available when Seizure Detection is checked. Details on amplitude
% threshold.
AmplitudeString= uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.65 0.35 0.04],'string','Amplitude Threshold','Visible','off'); %  (Multiple above mean for seizure, such that if amplitude mean = 0.1 and threshold =3, seizure is classified if the determine amplitude is 0.3 or above

PaddingString = uicontrol('style','text','parent',h,'units','normalized','position',[0.4 0.6 0.25 0.04],'string','Padding for annotations (10)','Visible','off');

ChannelText = uicontrol('style','text','parent',h,'units','normalized','position',[0.7 0.7 0.29 0.08],'string','Select Channels (1,2,3,4)','Visible','off');

DurationText = uicontrol('style','text','parent',h,'units','normalized','position',[0.7 0.55 0.29 0.08],'string','Specify Minimum Seizure Duration (5s)','Visible','off');

% SeizureSplit = uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','Split Seizure','Visible','off');

% PostprocessString = uicontrol('style','text','parent',h,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','Characterised seizures Excel file','Visible','off');
% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Specify EEG data path for analysis
EEG_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.03 0.85 0.35 0.04]);

% Provides details of errors that occur, and that the analysis has started
ErrorMessage = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.3 0.4 0.2],'Visible','off');

ChannelChoice = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.65 0.25 0.04]);

% Optional edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Charaterise is checked. Edit box for details about EEG Seizure Data Times
EEG_Seizure_times_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.03 0.45 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for line length
% threshold specified
LineLengthThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.03 0.7 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
AmplitudeThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.03 0.6 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
Padding = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.55 0.25 0.04],'Visible','off');

Channel = uicontrol('style','edit','parent',h,'units','normalized','position',[0.7 0.65 0.29 0.04],'Visible','off');

SeizureDuration = uicontrol('style','edit','parent',h,'units','normalized','position',[0.7 0.55 0.29 0.04],'Visible','off');

% PushButton
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Push button to start analysis
PushStart=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.5 0.1 0.25 0.1],'string','Start','callback',@StartProgram);

uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.03 0.8 0.15 0.04],'string','Browse','callback',@BrowseEEG);

% Conditional pushbutton
% ~~~~~~~~~~~~~~~~~~
Browse_Annotate_EEG=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.03 0.5 0.15 0.04],'string','Browse','callback',@BrowseAnnotate,'Visible','off');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Callback Functions
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Callback when Seizure_Detection is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function BrowseEEG(varargin)
        EEG_file_path = uigetdir;
        set(EEG_data_path,'string',EEG_file_path)
    end

    function BrowseAnnotate(varargin)
        [EEG_annotate_file path] = uigetfile('.xlsx');
        set(EEG_Seizure_times_data_path,'string',strcat(path,EEG_annotate_file))
    end

    function DetectCHK(varargin)
        if get(Seizure_Detection,'Value') ==1 % Determine if box checked or unchecked
            set(Select_Seizure_Duration,'Visible','On'); % Turn on option to select seizure duration
            set(Select_Channels,'Visible','On'); % Put select channel option on
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(Compare_Seizures,'Visible','On'); % Turn on compare seizure check box
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            set(Post_process_characterise,'Value',0);
            set(Post_process_annotate,'Value',0,'Visible','off');
            %             set(PostprocessString,'Visible','Off');
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(LineLengthString,'Visible','On'); % Turn on line length threshold text
            set(AmplitudeString,'Visible','On'); % Turn on amplitude threshold text
            set(LineLengthThreshold,'Visible','On'); % Turn on line length threshold edit box
            set(AmplitudeThreshold,'Visible','On');% Turn on amplitude threshold edit box
        else % Seizure)Detection unchecked
            set(Select_Seizure_Duration,'Visible','On','Value',0); % Turn on option to select seizure duration
            set(DurationText,'Visible','Off'); % Turn off duration text
            set(SeizureDuration,'Visible','Off') % Turn off seizure duration edit box
            set(Select_Channels,'Visible','Off','Value',0); % Put select channel option on
            set(ChannelText,'Visible','Off'); % Make text for select channel invisible
            set(Channel,'Visible','off'); % Make edit box for select channel invisible
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
        end
    end

% Callback when Seizure_Characterise is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function SeizCharCHK(varargin)
        if get(Seizure_Characterise,'Value') ==1 % Determine if box checked or unchecked
            set(Select_Seizure_Duration,'Visible','On','Value',0); % Turn on option to select seizure duration
            set(DurationText,'Visible','Off'); % Turn off duration text
            set(SeizureDuration,'Visible','Off') % Turn off seizure duration edit box
            set(Select_Channels,'Visible','Off','Value',0); % Put select channel option on
            set(ChannelText,'Visible','Off'); % Make text for select channel invisible
            set(Channel,'Visible','off'); % Make edit box for select channel invisible
            set(PaddingString,'Visible','On'); % Specify padding as on
            set(Padding,'Visible','On'); % Specify padding as on
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Save_data,'Visible','On') % Turn off plot features check box
            set(Browse_Annotate_EEG,'Visible','On') % Turn on browse EEG anotate file push button
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(Plot_features,'Visible','On') % Turn on plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            set(Post_process_characterise,'Value',0);
            set(Post_process_annotate,'Visible','On');
            %             set(PostprocessString,'Visible','Off');
        else % Seizure_Characterise unchecked
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            set(Post_process_annotate,'Value',0,'Visible','Off');
        end
    end

% Callback when Characterise_all_data is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function BackgCHK(varargin)
        if get(Characterise_all_data,'Value') ==1 % Determine if box checked or unchecked
            set(Select_Seizure_Duration,'Visible','On','Value',0); % Turn on option to select seizure duration
            set(DurationText,'Visible','Off'); % Turn off duration text
            set(SeizureDuration,'Visible','Off') % Turn off seizure duration edit box
            set(Select_Channels,'Visible','Off','Value',0); % Put select channel option on
            set(ChannelText,'Visible','Off'); % Make text for select channel invisible
            set(Channel,'Visible','off'); % Make edit box for select channel invisible
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(Padding,'Visible','Off'); % Specify padding as off
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Value',0);
            set(Save_data,'Value',0);
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text box
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(Plot_features,'Visible','Off')% Turn off plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            set(Post_process_characterise,'Value',0);
            set(Post_process_annotate,'Visible','Off');
            %             set(PostprocessString,'Visible','Off');
        end
    end

% Callback when postprocess data is called

    function ProcessData(varargin)
        if get(Post_process_characterise,'Value')
            set(Select_Seizure_Duration,'Visible','On','Value',0); % Turn on option to select seizure duration
            set(DurationText,'Visible','Off'); % Turn off duration text
            set(SeizureDuration,'Visible','Off') % Turn off seizure duration edit box
            %             set(PostprocessString,'Visible','On');
            set(Select_Channels,'Visible','Off','Value',0); % Put select channel option on
            set(ChannelText,'Visible','Off'); % Make text for select channel invisible
            set(Channel,'Visible','off'); % Make edit box for select channel invisible
            set(PaddingString,'Visible','Off'); % Specify padding as off
            set(EEGSort,'Visible','off');
            set(PaddingString,'Visible','On'); % Specify padding as on
            set(Padding,'Visible','On'); % Specify padding as on
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn on EEG sort filepath edit box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Browse_Annotate_EEG,'Visible','Off') % Turn on browse EEG anotate file push button
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(Save_data,'Visible','Off') % Turn off plot features check box
            set(Plot_features,'Visible','Off','Value',0) % Turn on plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
            set(Post_process_annotate,'Value',0,'Visible','off');
        else
            set(PaddingString,'Visible','Off'); % Specify padding as on
            set(Padding,'Visible','Off'); % Specify padding as on
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn on EEG sort filepath edit box
            set(Browse_Annotate_EEG,'Visible','Off') % Turn on browse EEG anotate file push button
            %             set(PostprocessString,'Visible','Off');
        end
    end


% Callback when Compare_Seizures is checked
    function CompareCHK(varargin)
        if get(Compare_Seizures,'Value') % Check if checkbox is checked
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','On') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
        else
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Browse_Annotate_EEG,'Visible','Off') % Turn off browse EEG anotate file push button
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
        end
    end

% Callback when Channel Select is checked
    function SelectChannels(varargin)
        if get(Select_Channels,'Value')
            set(ChannelText,'Visible','On'); % Make text for select channel invisible
            set(Channel,'Visible','on'); % Make edit box for select channel invisible
        else
            set(ChannelText,'Visible','Off'); % Make text for select channel invisible
            set(Channel,'Visible','off'); % Make edit box for select channel invisible
        end
    end

% Callback when specify minimum seizure duration is checked
    function SpecifyDuration(varargin)
        if get(Select_Seizure_Duration,'Value')
            set(DurationText,'Visible','On'); % Turn off duration text
            set(SeizureDuration,'Visible','On') % Turn off seizure duration edit box
        else
            set(DurationText,'Visible','Off'); % Turn off duration text
            set(SeizureDuration,'Visible','Off') % Turn off seizure duration edit box
        end
    end


% Callback when Start_Program push button is pressed
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function StartProgram(varargin)
        DetectorSettings = struct('EEGFilepath',{{0}},'ExcelFilepath',{{0}},'PlotFeatures',0,'LLThres',0,'AmpThres',0,'CompareSeizures',0,'Padding','10','Animals',0,'SaveData',0,'ProcessData',0,'MinSeizure','0','Channels','all');
        ProgramType = [0 0 0];
        clear filepath LLThres AmpThres Excel_data_filepath % CLear all temporary variables at start of callback
        %         set(PushStart,'Enable','Off') % Disable Push button during analysis
        set(ErrorMessage,'Visible','Off') % Turn off error message edit box
        set(ErrorMessage,'string','Analysis Started') % Set error message
        set(ErrorMessage,'Visible','On') % Display error message
        filepath =  get(EEG_data_path,'string'); % Get filepath from edit box
        if isempty(filepath) % Determine if filepath specified
            set(ErrorMessage,'string','No .eeg filepath specified') % Inform user that no filepath is specified
            set(ErrorMessage,'Visible','On') % Show error message
            return % End callback
        else
            DetectorSettings.EEGFilepath=filepath; % Set detector settings with filepath specified
        end
        if get(Seizure_Detection,'Value') % Check if Seizure_Detection is checked
            LLThres = get(LineLengthThreshold,'string'); % Get value in edit box specifying threshold for line length
            if isempty(LLThres) % Determine if line length threshold is specified
                set(ErrorMessage,'string','No line length threshold specified') % Set errror message
                set(ErrorMessage,'Visible','On')% Display error message
                return % End callback
            else
                DetectorSettings.LLThres = LLThres; % Set line length in detector settings
            end
            AmpThres = get(AmplitudeThreshold,'string'); % Get amplitude threshold from edit box
            if isempty(AmpThres) % Check if an amplitude threshold is specified
                set(ErrorMessage,'string','No amplitude threshold specified') % Set error message
                set(ErrorMessage,'Visible','On') % Display error message
                return % End callback
            else
                DetectorSettings.AmpThres = AmpThres; % Set amplitude threshold in detector settings
            end
            if get(Compare_Seizures,'Value')
                DetectorSettings.CompareSeizures =1;
                Excel_data_filepath =  get(EEG_Seizure_times_data_path,'string'); % Get excel filepath from edit box
                if isempty(Excel_data_filepath)% Check if excel filepath exists
                    set(ErrorMessage,'string','No excel filepath specified') % Set error message
                    set(ErrorMessage,'Visible','On') % Show error message
                    return % End callback
                else
                    DetectorSettings.ExcelFilepath =  Excel_data_filepath; % Set filepath for excel file in detector settings
                end
            end
            if get(Select_Channels,'Value')
                ChannelsRequested = get(Channel,'string');
                if isempty(ChannelsRequested)
                    DetectorSettings.Channels ='all';
                else
                    DetectorSettings.Channels =ChannelsRequested;
                end
            end
            if get(Select_Seizure_Duration,'Value')
                DurationS = get(SeizureDuration,'string');
                if isempty(DurationS)
                    DetectorSettings.MinSeizure = '5';
                else 
                    DetectorSettings.MinSeizure = DurationS;
                end
            end
            ProgramType = [1 0 0]; % Set the program type to seizure detection
        elseif get(Seizure_Characterise,'Value') % Check if seizure characterisation is checked
            DetectorSettings.PlotFeatures = get(Plot_features,'Value'); % Update detector settings with plot features
            DetectorSettings.SaveData = get(Save_data,'Value');
            DetectorSettings.ProcessData = get(Post_process_annotate,'Value');
            Excel_data_filepath =  get(EEG_Seizure_times_data_path,'string'); % Get excel filepath from edit box
            if isempty(Excel_data_filepath)% Check if excel filepath exists
                set(ErrorMessage,'string','No excel filepath specified') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
            else
                DetectorSettings.ExcelFilepath = Excel_data_filepath; % Set filepath for excel file in detector settings
            end
            PaddingStr = get(Padding,'string');
            if ~isempty(PaddingStr)
                DetectorSettings.Padding = PaddingStr;
            end
            ProgramType = [0 1 0]; % Set program type to Seizure characterisation
        elseif get(Characterise_all_data,'Value') ==1 % Check if characterise all data is checked
            ProgramType = [0 0 1]; % Set program type to characterise all data
        elseif get(Post_process_characterise,'Value')
            DetectorSettings.ProcessData=1;
            if isempty(Excel_data_filepath)% Check if excel filepath exists
                set(ErrorMessage,'string','No excel filepath specified') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
            else
                DetectorSettings.ExcelFilepath = Excel_data_filepath; % Set filepath for excel file in detector settings
            end
        else % Check if no options selected
            set(ErrorMessage,'string','No options chosen') % Set error message
            set(ErrorMessage,'Visible','On') % Display error message
            return % End callback
        end
        clc
        refreshdata;
        ChannelsRequested = get(ChannelChoice,'string');
        if isempty(ChannelsRequested)
            DetectorSettings.Animals ='all';
        else
            DetectorSettings.Animals =ChannelsRequested;
        end
        Analyse_EEG_GUI(DetectorSettings,ProgramType); % Begin analysis of data
        set(PushStart,'Enable','On') % Enable push button
        set(ErrorMessage,'string','Analysis Finished') % Inform user that analysis is finished
    end
end


