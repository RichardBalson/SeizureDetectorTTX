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
global GUIFigure;
GUIFigure = figure('Name','Detector GUI');

%%

% Seizure detection analysis
Seizure_Detection= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.9 0.28 0.04],'string','Seizure Detection','callback',@DetectCHK);

% Seizure characterisation
Seizure_Characterise =uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.85 0.28 0.04],'string','Characterise Seizures','callback',@SeizCharCHK);

% Characterise all data
Characterise_all_data =uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.8 0.28 0.04],'string','Characterise Data','callback',@BackgCHK);

Post_process_characterise = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.4 0.6 0.28 0.04],'string','Process Characterised Data','callback',@ProcessData);

Batch_process = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.03 0.1 0.29 0.04],'string','Process Multiple Files','Visible','on','callback',@Batch);

% Conditional Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when seizure charcterisation is checked, Check if features need
% to be plotted
Plot_features= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Plot Features','Visible','off');

Save_data= uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.85 0.2 0.04],'string','Save Data','Visible','off');

% Availbale when Seizure Detection is checked, check if a comparison
% between detected and annotated seizures needs to be made
Compare_Seizures = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Compare detected and characterised seizures','Visible','off','Callback',@CompareCHK);

Post_process_annotate = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.8 0.22 0.04],'string','Process Characterised Data','Visible','Off','Callback',@ProcessC);

Select_Channels = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.85 0.29 0.04],'string','Specify Channels for detector','Visible','off','Callback',@SelectChannels);

Select_Seizure_Duration = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.8 0.29 0.04],'string','Specify Minimum seizure duration','Visible','off','Callback',@SpecifyDuration);

Process_annotations = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.9 0.29 0.04],'string','Process Characterised Excel Files in Current Folder','Visible','off','Callback',@ProcessCharacterise);

Process_Seizures = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.85 0.29 0.04],'string','Compare Detected seizures to annotated Seizures','Visible','off','Callback',@CompareDetect);

Split_Seizure_epoch = uicontrol('style','checkbox','parent',GUIFigure,'units','normalized','position',[0.7 0.75 0.29 0.04],'string','Split seizures for characterisation','Visible','off','Callback',@SplitChar);


% Text
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Text detailing information for the filepath
uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.9 0.35 0.04],'string','EEG data Path (c:\...\2012.eeg file)');

% Specify channels text
uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.4 0.55 0.25 0.04],'string','Analyse Channels (1,2,..,8)');

% Conditional text
% ~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Characterise is checked. Details of filepath for
% excel file
EEGSort= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','EEG Seizure Data Times (c:\...\2012Sorted.xls file)','Visible','off');

% Available when Seizure Detection is checked. Details on line length
% threshold.
LineLengthString= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.75 0.35 0.04],'string','Line Length Threshold','Visible','off'); %

% Available when Seizure Detection is checked. Details on amplitude
% threshold.
AmplitudeString= uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.65 0.35 0.04],'string','Amplitude Threshold','Visible','off'); %  (Multiple above mean for seizure, such that if amplitude mean = 0.1 and threshold =3, seizure is classified if the determine amplitude is 0.3 or above

PaddingString = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.4 0.45 0.25 0.04],'string','Padding for annotations (10)','Visible','off');

ChannelText = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.7 0.7 0.29 0.08],'string','Select Channels (1,2,3,4)','Visible','off');

DurationText = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.7 0.55 0.29 0.08],'string','Specify Minimum Seizure Duration (5s)','Visible','off');

SeizureSplitText = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.7 0.7 0.29 0.04],'string','Split Seizure (4)','Visible','off');

% PostprocessString = uicontrol('style','text','parent',GUIFigure,'units','normalized','position',[0.03 0.55 0.35 0.04],'string','Characterised seizures Excel file','Visible','off');
% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Specify EEG data path for analysis
EEG_data_path = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.85 0.35 0.04]);

% Provides details of errors that occur, and that the analysis has started
ErrorMessage = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.25 0.4 0.13],'Visible','off');

ChannelChoice = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.5 0.25 0.04]);

% Optional edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Charaterise is checked. Edit box for details about EEG Seizure Data Times
EEG_Seizure_times_data_path = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.45 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for line length
% threshold specified
LineLengthThreshold = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.7 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
AmplitudeThreshold = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.03 0.6 0.35 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
Padding = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.4 0.4 0.25 0.04],'Visible','off');

Channel = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.7 0.65 0.29 0.04],'Visible','off');

SeizureDuration = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.7 0.5 0.29 0.04],'Visible','off');

SeizureSplitEdit = uicontrol('style','edit','parent',GUIFigure,'units','normalized','position',[0.7 0.65 0.29 0.04],'Visible','off');

% PushButton
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Push button to start analysis
PushStart=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.5 0.1 0.25 0.1],'string','Start','callback',@StartProgram);

Browse_EEG_file=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.03 0.8 0.15 0.04],'string','Browse','callback',@BrowseEEG);

% Conditional pushbutton
% ~~~~~~~~~~~~~~~~~~
Browse_Annotate_EEG=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.03 0.5 0.15 0.04],'string','Browse','callback',@BrowseAnnotate,'Visible','off');

Clear_batch_list=uicontrol('style','pushbutton','parent',GUIFigure,'units','normalized','position',[0.03 0.15 0.15 0.04],'string','Clear batch list','callback',@ClearList,'Visible','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Callback Functions
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Callback function for folder designation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function Batch(varargin)
        if get(Batch_process,'Value')
           set(Clear_batch_list,'visible','on');
        else
            set(Clear_batch_list,'visible','off');
        end
    end

    function BrowseEEG(varargin)
        EEG = guidata(GUIFigure);
        k=0;
        EEG_files ={};
        EEG_file_path =1;
        if get(Batch_process,'value')
            while EEG_file_path ~=0
                if k>0
                    EEG_files{k} = {EEG_file_path};
                end
                k= k+1;
                EEG_file_path = uigetdir;
            end
            set(EEG_data_path,'string',EEG_files{k-1})
        else
            EEG_file_path = uigetdir;
            if EEG_file_path ~=0
                EEG_files ={EEG_file_path};
                set(EEG_data_path,'string',EEG_files)
            end
        end
        EEG.Data = EEG_files;
        guidata(EEG_data_path,EEG);
    end

    function BrowseAnnotate(varargin)
        EEG = guidata(GUIFigure);
        k=0;
        EEG_Annotate_files ={};
        EEG_Annotate_file_path =1;
        if get(Batch_process,'value')
            while EEG_Annotate_file_path ~=0
                if k>0
                    EEG_Annotate_files{k} = {strcat(pathT,EEG_Annotate_file_path)};
                end
                k= k+1;
                [EEG_Annotate_file_path pathT] = uigetfile('.xlsx');
            end
            set(EEG_Seizure_times_data_path,'string',EEG_Annotate_files{k-1})
        else
            [EEG_Annotate_file_path pathT] = uigetfile('.xlsx');
            if EEG_Annotate_file_path ~=0
                EEG_Annotate_files = {strcat(pathT,EEG_Annotate_file_path)};
                set(EEG_Seizure_times_data_path,'string',EEG_Annotate_files)
            end
        end
        EEG.Annotate = EEG_Annotate_files;
        guidata(EEG_data_path,EEG);
    end

    function ClearList(varargin)
        guidata(GUIFigure,[]);
    end

% Callback when Seizure_Detection is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function DetectCHK(varargin)
        if get(Seizure_Detection,'Value') ==1 % Determine if box checked or unchecked
            setVisInvis([Select_Seizure_Duration,Select_Channels,Compare_Seizures,LineLengthString,AmplitudeString,LineLengthThreshold,AmplitudeThreshold],...%Visible
                [PaddingString,Padding,EEGSort,Browse_Annotate_EEG,EEG_Seizure_times_data_path,SeizureSplitText,SeizureSplitEdit],...%Invisible
                [Process_Seizures,Plot_features,Save_data,Post_process_annotate,Process_annotations,Split_Seizure_epoch],...% Invisible+Value 0
                [Seizure_Characterise,Post_process_characterise,Characterise_all_data]);% Value 0
        else % Seizure)Detection unchecked
            setVisInvis(0,...%Visible
                [DurationText,SeizureDuration,ChannelText,Channel,LineLengthString,AmplitudeString,LineLengthThreshold,AmplitudeThreshold],...%Invisible
                [Select_Seizure_Duration,Select_Channels,Compare_Seizures],...% Invisible+Value 0
                0);% Value 0
        end
    end

% Callback when Seizure_Characterise is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function SeizCharCHK(varargin)
        if get(Seizure_Characterise,'Value') ==1 % Determine if box checked or unchecked
            setVisInvis([PaddingString,Padding,EEGSort,EEG_Seizure_times_data_path,Save_data,Browse_Annotate_EEG,Plot_features,Post_process_annotate],...%Visible
                [DurationText,SeizureDuration,ChannelText,Channel,LineLengthString,AmplitudeString,LineLengthThreshold,AmplitudeThreshold],...%Invisible
                [Process_annotations,Process_Seizures,Select_Seizure_Duration,Select_Channels,Compare_Seizures,Split_Seizure_epoch],...% Invisible+Value 0
                [Seizure_Detection,Characterise_all_data,Post_process_characterise]);% Value 0
        else % Seizure_Characterise unchecked
            setVisInvis([0],...%Visible
                [PaddingString,Padding,EEGSort,Browse_Annotate_EEG,Plot_features,EEG_Seizure_times_data_path,Save_data,SeizureSplitText],...%Invisible
                [Post_process_annotate,Split_Seizure_epoch],...% Invisible+Value 0
                [Save_data,Plot_features]);% Value 0
        end
    end

% Callback when Characterise_all_data is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function BackgCHK(varargin)
        if get(Characterise_all_data,'Value') ==1 % Determine if box checked or unchecked
            setVisInvis([0],...%Visible
                [DurationText,SeizureDuration,ChannelText,Channel,PaddingString,Padding,EEGSort,Browse_Annotate_EEG,EEG_Seizure_times_data_path,LineLengthString,AmplitudeString,LineLengthThreshold,AmplitudeThreshold,SeizureSplitEdit,SeizureSplitText],...%Invisible
                [Process_annotations,Process_Seizures,Select_Seizure_Duration,Select_Channels,Plot_features,Save_data,Compare_Seizures,Post_process_annotate,Split_Seizure_epoch],...% Invisible+Value 0
                [Seizure_Detection,Seizure_Characterise,Post_process_characterise]);% Value 0
        end
    end

% Callback when postprocess data is called

    function ProcessData(varargin)
        if get(Post_process_characterise,'Value')
            setVisInvis([Process_Seizures,Process_annotations,Split_Seizure_epoch],...%Visible
                [DurationText,SeizureDuration,ChannelText,Channel,PaddingString,Padding,EEGSort,Browse_Annotate_EEG,EEG_Seizure_times_data_path,LineLengthString,AmplitudeString,LineLengthThreshold,AmplitudeThreshold,SeizureSplitEdit,SeizureSplitText],...%Invisible
                [Select_Seizure_Duration,Plot_features,Save_data,Compare_Seizures,Post_process_annotate,Select_Channels,Split_Seizure_epoch],...% Invisible+Value 0
                [Seizure_Detection,Seizure_Characterise,Characterise_all_data]);% Value 0
        else
            setVisInvis([0],...%Visible
                [PaddingString,Padding,EEG_Seizure_times_data_path,Browse_Annotate_EEG],...%Invisible
                [Process_annotations,Process_Seizures,Split_Seizure_epoch],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

%%

    function ProcessC(varargin)
        if get(Post_process_annotate,'value')
            setVisInvis([Split_Seizure_epoch],...%Visible
                [0],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        else
            setVisInvis([0],...%Visible
                [0],...%Invisible
                [Split_Seizure_epoch],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

    function ProcessCharacterise(varargin)
        if get(Process_annotations,'Value')
            setVisInvis([PaddingString,Padding,Split_Seizure_epoch],...%Visible
                [Browse_Annotate_EEG,EEG_Seizure_times_data_path,EEGSort],...%Invisible
                [0],...% Invisible+Value 0
                [Process_Seizures]);% Value 0
        else
            setVisInvis([0],...%Visible
                [PaddingString,Padding],...%Invisible
                [Split_Seizure_epoch],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

    function CompareDetect(varargin)
        if get(Process_Seizures,'Value')
            setVisInvis([Browse_Annotate_EEG,EEG_Seizure_times_data_path,EEGSort],...%Visible
                [PaddingString,Padding],...%Invisible
                [Split_Seizure_epoch],...% Invisible+Value 0
                [Process_annotations]);% Value 0
        else
            setVisInvis([0],...%Visible
                [Browse_Annotate_EEG,EEG_Seizure_times_data_path,EEGSort],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

% Callback when Compare_Seizures is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~
    function CompareCHK(varargin)
        if get(Compare_Seizures,'Value') % Check if checkbox is checked
            setVisInvis([Browse_Annotate_EEG,EEG_Seizure_times_data_path,EEGSort],...%Visible
                [0],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        else
            setVisInvis([0],...%Visible
                [Browse_Annotate_EEG,EEG_Seizure_times_data_path,EEGSort],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

% Callback when Channel Select is checked
    function SelectChannels(varargin)
        if get(Select_Channels,'Value')
            setVisInvis([ChannelText,Channel],...%Visible
                [0],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        else
            setVisInvis([0],...%Visible
                [ChannelText,Channel],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

% Callback when specify minimum seizure duration is checked
    function SpecifyDuration(varargin)
        if get(Select_Seizure_Duration,'Value')
            setVisInvis([DurationText,SeizureDuration],...%Visible
                [0],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        else
            setVisInvis([0],...%Visible
                [DurationText,SeizureDuration],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        end
    end

    function SplitChar(varargin)
        if get(Split_Seizure_epoch,'value')
            setVisInvis([SeizureSplitText,SeizureSplitEdit],...%Visible
                [0],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        else
            setVisInvis([0],...%Visible
                [SeizureSplitText,SeizureSplitEdit],...%Invisible
                [0],...% Invisible+Value 0
                [0]);% Value 0
        end
        
    end

%%


% Callback when Start_Program push button is pressed
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    function StartProgram(varargin)
        DetectorSettings = struct('EEGFilepath',{{0}},'ExcelFilepath',{{0}},'PlotFeatures',0,'LLThres',0,'AmpThres',0,'CompareSeizures',0,...
            'Padding','10','Animals',0,'SaveData',0,'ProcessAnnotated',0,'CompareS',0,'MinSeizure','0','Channels','all','SplitSeizure','1');
        ProgramType = [0 0 0];
        clear filepath LLThres AmpThres Excel_data_filepath % CLear all temporary variables at start of callback
        %         set(PushStart,'Enable','Off') % Disable Push button during analysis
        Gui = guidata(EEG_data_path);
        set(ErrorMessage,'Visible','Off') % Turn off error message edit box
        set(ErrorMessage,'string','Analysis Started') % Set error message
        set(ErrorMessage,'Visible','On') % Display error message
        filepath =  get(EEG_data_path,'string'); % Get filepath from edit box
        if ~iscell(filepath)
            filepath ={filepath}
        end
        Excel_data_filepath =  get(EEG_Seizure_times_data_path,'string');
        if ~iscell(Excel_data_filepath)
            Excel_data_filepath = {Excel_data_filepath}
        end
        if isempty(filepath) % Determine if filepath specified
            set(ErrorMessage,'string','No .eeg filepath specified') % Inform user that no filepath is specified
            set(ErrorMessage,'Visible','On') % Show error message
            return % End callback
        else
            if get(Batch_process,'Value')
            DetectorSettings.EEGFilepath=Gui.Data; % Set detector settings with filepath specified
            else
              DetectorSettings.EEGFilepath= filepath;
            end
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
                if isempty(Excel_data_filepath)% Check if excel filepath exists
                    set(ErrorMessage,'string','No excel filepath specified') % Set error message
                    set(ErrorMessage,'Visible','On') % Show error message
                    return % End callback
                else
                    if get(Batch_process,'Value')
                    DetectorSettings.ExcelFilepath =  Gui.Annotate; % Set filepath for excel file in detector settings
                    else
                       DetectorSettings.ExcelFilepath=Excel_data_filepath;
                    end
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
            DetectorSettings.ProcessAnnotated = get(Post_process_annotate,'Value');
             % Get excel filepath from edit box
            if isempty(Excel_data_filepath)% Check if excel filepath exists
                set(ErrorMessage,'string','No excel filepath specified') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
            else
                if get(Batch_process,'Value')
                    DetectorSettings.ExcelFilepath =  Gui.Annotate; % Set filepath for excel file in detector settings
                    else
                       DetectorSettings.ExcelFilepath=Excel_data_filepath;
                    end % Set filepath for excel file in detector settings
            end
            PaddingStr = get(Padding,'string');
            if ~isempty(PaddingStr)
                DetectorSettings.Padding = PaddingStr;
            end
            if get(Split_Seizure_epoch,'value')
                SplitVal = get(SeizureSplitEdit,'string');
                if ~isempty(SplitVal)
                    DetectorSettings.SplitSeizure = SplitVal;
                else
                    DetectorSettings.SplitSeizure ='4';
                end
            end
            ProgramType = [0 1 0]; % Set program type to Seizure characterisation
        elseif get(Characterise_all_data,'Value') ==1 % Check if characterise all data is checked
            ProgramType = [0 0 1]; % Set program type to characterise all data
        elseif get(Post_process_characterise,'Value')
            if get(Split_Seizure_epoch,'value')
                SplitVal = get(SeizureSplitEdit,'string');
                if ~isempty(SplitVal)
                    DetectorSettings.SplitSeizure = SplitVal;
                else
                    DetectorSettings.SplitSeizure ='4';
                end
            end
            DetectorSettings.ProcessAnnotated =get(Process_annotations,'value');
            DetectorSettings.CompareS = get(Process_Seizures,'value');
            if isempty(Excel_data_filepath)% Check if excel filepath exists
                set(ErrorMessage,'string','No excel filepath specified') % Set error message
                set(ErrorMessage,'Visible','On') % Show error message
                return % End callback
            else
                if get(Batch_process,'Value')
                    DetectorSettings.ExcelFilepath =  Gui.Annotate; % Set filepath for excel file in detector settings
                    else
                       DetectorSettings.ExcelFilepath=Excel_data_filepath;
                    end % Set filepath for excel file in detector settings
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
        err = Analyse_EEG_GUI(DetectorSettings,ProgramType); % Begin analysis of data
        if err
            set(ErrorMessage,'string','Number of files does not match') % Inform user that analysis is finished
        else
        set(PushStart,'Enable','On') % Enable push button
        set(ErrorMessage,'string','Analysis Finished') % Inform user that analysis is finished
        end
    end
end



function setVisInvis(Vis,Invis,InvVal,Val)

if Vis(1) ~=0
    for k =1:length(Vis)
        set(Vis(k),'Visible','On')
    end
end
if Invis(1) ~=0
    for k =1:length(Invis)
        set(Invis(k),'Visible','Off')
    end
end
if InvVal(1) ~=0
    for k =1:length(InvVal)
        set(InvVal(k),'Visible','Off','Value',0)
    end
end
if Val(1) ~=0
    for k =1:length(Val)
        set(Val(k),'Value',0);
    end
end
end
