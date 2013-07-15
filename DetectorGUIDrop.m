function DetectorGUIDrop
%This function generates the GUI for the designed seizure detector
%   Created by Richard Balson 16/04/2013

%J:\JLJ\20130211{67E4360B-DF57-41A9-89BD-AB24922620C9}.eeg
%J:\JLJ\20130124{632926F5-DF3B-4F03-85FC-593FD25EEC65}.eeg
%C:\Users\balsonr\Dropbox\Polymer Project Jonathan)\Test\GUI1\EEG Matlab Sorting.xlsx
%J:\JLJ\20130120{6E9AE138-D330-4BF2-AFC0-C862D1E254D4}.eeg
% H:\Jonathan\Seizure characterise\GUIv2\EEG Matlab Sorting.xlsx
% J:\rbalson\Control\20130312{144A4128-D510-462B-BAFB-1A99CABB99E4}.eeg
% C:\Users\balsonr\Dropbox\Work\PhD\Projects\Estimation\UKF\WendlingUKF\GUI\EEGData\20130312Annotate.xlsx

% Test Data
% J:\JLJ\20130119{BF4C39F5-12B7-4A5C-8557-9DE64590E7C2}.eeg
% C:\Users\balsonr\Dropbox\Polymer Project Jonathan)\EEG Annotations\EEG Matlab Sorting.xlsx


clear
clc
close all

% Create structure used for setting specified by GUI.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

DetectorSettings = struct('EEGFilepath',{{0}},'ExcelFilepath',{{0}},'PlotFeatures',0,'LLThres',0,'AmpThres',0,'CompareSeizures',0);
ProgramType = [0 0 0];% Index 1 Detector, 2 characterise seizures, 3 characterise background

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% GUI creation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h = figure;

% Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Seizure detection analysis
Seizure_Detection= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.9 0.2 0.04],'string','Seizure Detection','callback',@DetectCHK);

% Seizure characterisation
Seizure_Characterise =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.85 0.25 0.04],'string','Characterise Seizures','callback',@SeizCharCHK);

% Characterise all data
Characterise_all_data =uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.4 0.8 0.25 0.04],'string','Characterise Data','callback',@BackgCHK);

% Conditional Check boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Available when seizure charcterisation is checked, Check if features need
% to be plotted
Plot_features= uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Plot Features','Visible','off');

% Availbale when Seizure Detection is checked, check if a comparison
% between detected and annotated seizures needs to be made
Compare_Seizures = uicontrol('style','checkbox','parent',h,'units','normalized','position',[0.7 0.9 0.2 0.04],'string','Compare detected and characterised seizures','Visible','off','Callback',@CompareCHK);


% Text
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Text detailing information for the filepath
uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.9 0.25 0.04],'string','EEG data Path (c:\...\2012.eeg file)');

% Conditional text
% ~~~~~~~~~~~~~~~~~~~~

% Available when Seizure Characterise is checked. Details of filepath for
% excel file
EEGSort= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.6 0.25 0.04],'string','EEG Seizure Data Times (c:\...\2012Sorted.xls file)','Visible','off');

% Available when Seizure Detection is checked. Details on line length
% threshold.
LineLengthString= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.8 0.25 0.04],'string','Line Length Threshold','Visible','off'); %

% Available when Seizure Detection is checked. Details on amplitude
% threshold.
AmplitudeString= uicontrol('style','text','parent',h,'units','normalized','position',[0.1 0.7 0.25 0.04],'string','Amplitude Threshold','Visible','off'); %  (Multiple above mean for seizure, such that if amplitude mean = 0.1 and threshold =3, seizure is classified if the determine amplitude is 0.3 or above

% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Look for single-letter drives, starting at a: or c: as appropriate

TestFilesTemp =dir;
TestFilesInit = TestFilesTemp(1:2);
k=2;
for i = double('a'):double('z')
    if exist(['' char(i) ':\'], 'dir') == 7
        k = k+1;
        TestFilesInit(k,1).name = [char(i) ':'];       
    end
end
Dir_num =0;
Current_dir = '';
% TestFiles = dir(Current_dir);
EEG_data_path_pop = uicontrol('Style','popup', 'String', {TestFilesInit.name},'parent',h,'units','normalized','position',[0.1 0.85 0.25 0.04],'callback',@ChangeFolder);


% % Specify EEG data path for analysis
% EEG_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.85 0.25 0.04]);
% 
% % Provides details of errors that occur, and that the analysis has started
% ErrorMessage = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.3 0.4 0.2],'Visible','off');

% Optional edit boxes
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
TestFilesTemp1 =dir;
Dir_num1=0;
Current_dir1='';
EEG_Seizure_times_data_path = uicontrol('Style','popup', 'String', {TestFilesInit.name},'parent',h,'units','normalized','position',[0.1 0.55 0.25 0.04],'callback',@ChangeFolder1,'visible','off');


% % Specify EEG data path for analysis
EEG_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.85 0.25 0.04]);
% 
% % Provides details of errors that occur, and that the analysis has started
ErrorMessage = uicontrol('style','edit','parent',h,'units','normalized','position',[0.4 0.3 0.4 0.2],'Visible','off');
% 
% % Optional edit boxes
% % ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
% 
% % Available when Seizure Charaterise is checked. Edit box for details about EEG Seizure Data Times
% EEG_Seizure_times_data_path = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.55 0.25 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for line length
% threshold specified
LineLengthThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.75 0.25 0.04],'Visible','off');

% Avaliablle whne Seizure Detection is checked. Edit box for amplitude
% threshold specified
AmplitudeThreshold = uicontrol('style','edit','parent',h,'units','normalized','position',[0.1 0.65 0.25 0.04],'Visible','off');

% PushButton
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

% Push button to start analysis
PushStart=uicontrol('style','pushbutton','parent',h,'units','normalized','position',[0.5 0.1 0.25 0.1],'string','Start','callback',@StartProgram);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Callback Functions
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


% Callback function for folder designation
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function ChangeFolder(varargin)
        EEGSelect =0;
        Folder = get(EEG_data_path_pop,{'string','Value'});         
        Current_dir_temp = [Current_dir, Folder{1}{Folder{2}},'\'];
        if exist(Current_dir_temp,'dir')==7
            selectdir = Folder{1}{Folder{2}};
        if ((strcmp(selectdir,'.') || strcmp(selectdir,'..')))
            Dir_num = Dir_num-1;
        elseif ((length(selectdir)>4)&&(strcmp(selectdir(end-3:end),'.eeg')))
            EEGSelect =1;
        else 
            Dir_num = Dir_num+1;
        end
        TestFiles = dir(Current_dir_temp);
        if ~strcmp(TestFiles(1).name,'.')
        TestFiles = [TestFilesTemp(1:2); TestFiles];
        end
        if ((length(TestFiles)>3 && (Dir_num ~=0)) && ~EEGSelect)
        set(EEG_data_path_pop,'string',{TestFiles.name});
        Current_dir = Current_dir_temp;
        elseif EEGSelect
            Current_dir = Current_dir_temp(1:end-1);
        elseif (Dir_num <=0)
            set(EEG_data_path_pop, 'value', 1);
            set(EEG_data_path_pop,'string',{TestFilesInit.name})
            Current_dir = '';
        end
        end
    end
        
    function ChangeFolder1(varargin)
        Folder = get(EEG_Seizure_times_data_path,{'string','Value'});         
        Current_dir_temp = [Current_dir1, Folder{1}{Folder{2}},'\'];
        if exist(Current_dir_temp,'dir')==7
            selectdir = Folder{1}{Folder{2}};
        if ((strcmp(selectdir,'.') || strcmp(selectdir,'..')))
            Dir_num1 = Dir_num1-1;
        else 
            Dir_num1 = Dir_num1+1;
        end
        TestFiles = dir(Current_dir_temp);
        if ~strcmp(TestFiles(1).name,'.')
        TestFiles = [TestFilesTemp1(1:2); TestFiles];
        end
        if (length(TestFiles)>3 && (Dir_num1 ~=0))
        set(EEG_Seizure_times_data_path,'string',{TestFiles.name});
        Current_dir1 = Current_dir_temp;
        elseif (Dir_num ==0)
            set(EEG_Seizure_times_data_path, 'value', 1);
            set(EEG_Seizure_times_data_path,'string',{TestFilesInit.name})
            Current_dir1 = '';
        end
                else
          Current_dir1=Current_dir_temp(1:end-1);  
        end
    end

% Callback when Seizure_Detection is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function DetectCHK(varargin)
        if get(Seizure_Detection,'Value') ==1 % Determine if box checked or unchecked
            set(Compare_Seizures,'Visible','On'); % Turn on compare seizure check box
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(LineLengthString,'Visible','On'); % Turn on line length threshold text
            set(AmplitudeString,'Visible','On'); % Turn on amplitude threshold text
            set(LineLengthThreshold,'Visible','On'); % Turn on line length threshold edit box
            set(AmplitudeThreshold,'Visible','On');% Turn on amplitude threshold edit box
        else % Seizure)Detection unchecked
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
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Characterise_all_data,'Value',0) % Uncheck Characterise all data
            set(Plot_features,'Visible','On') % Turn on plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
        else % Seizure_Characterise unchecked
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(Plot_features,'Visible','Off') % Turn off plot features check box
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
        end
    end

% Callback when Characterise_all_data is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function BackgCHK(varargin)
        if get(Characterise_all_data,'Value') ==1 % Determine if box checked or unchecked
            set(Seizure_Detection,'Value',0) % Uncheck Seizure Detection
            set(Seizure_Characterise,'Value',0) % Uncheck Seizure Characterise
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text box
            set(EEG_Seizure_times_data_path,'Visible','Off') % Turn off EEG sort filepath edit box
            set(Plot_features,'Visible','Off')% Turn off plot features check box
            set(LineLengthString,'Visible','Off');% Turn off line length threshold text
            set(AmplitudeString,'Visible','Off');% Turn off amplitude threshold text
            set(LineLengthThreshold,'Visible','Off');% Turn off line length threshold edit box
            set(AmplitudeThreshold,'Visible','Off');% Turn off amplitude threshold edit box
            set(Compare_Seizures,'Visible','Off'); % Turn off compare seizure check box
            set(Compare_Seizures,'Value',0);
        end
    end

% Callback when Compare_Seizures is checked
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function CompareCHK(varargin)
        if get(Compare_Seizures,'Value') % Check if checkbox is checked
            set(EEGSort,'Visible','On') % Turn on EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','On')% Turn on EEG sort filepath edit box
        else
            set(EEGSort,'Visible','Off') % Turn off EEG sort filepath text
            set(EEG_Seizure_times_data_path,'Visible','Off')% Turn off EEG sort filepath edit box
        end
    end

% Callback when Start_Program push button is pressed
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    function StartProgram(varargin)
        clear filepath LLThres AmpThres Excel_data_filepath ProgramType % CLear all temporary variables at start of callback
        %         set(PushStart,'Enable','Off') % Disable Push button during analysis
        set(ErrorMessage,'Visible','Off') % Turn off error message edit box
        set(ErrorMessage,'string','Analysis Started') % Set error message
        set(ErrorMessage,'Visible','On') % Display error message
        if strcmp(Current_dir,'') % Determine if filepath specified
            set(ErrorMessage,'string','No .eeg filepath specified') % Inform user that no filepath is specified
            set(ErrorMessage,'Visible','On') % Show error message
            return % End callback
        else
            DetectorSettings.EEGFilepath=Current_dir; % Set detector settings with filepath specified
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
                if strcmp(Current_dir1,'')% Check if excel filepath exists
                    set(ErrorMessage,'string','No excel filepath specified') % Set error message
                    set(ErrorMessage,'Visible','On') % Show error message
                    return % End callback
                else
                    DetectorSettings.ExcelFilepath = Current_dir1; % Set filepath for excel file in detector settings
                end
            end
            ProgramType = [1 0 0]; % Set the program type to seizure detection
        elseif get(Seizure_Characterise,'Value') ==1 % Check if seizure characterisation is checked
            DetectorSettings.PlotFeatures = get(Plot_features,'Value'); % Update detector settings with plot features
                if strcmp(Current_dir1,'')% Check if excel filepath exists
                    set(ErrorMessage,'string','No excel filepath specified') % Set error message
                    set(ErrorMessage,'Visible','On') % Show error message
                    return % End callback
                else
                    DetectorSettings.ExcelFilepath = Current_dir1; % Set filepath for excel file in detector settings
                end
            ProgramType = [0 1 0]; % Set program type to Seizure characterisation
        elseif get(Characterise_all_data,'Value') ==1 % Check if characterise all data is checked
            ProgramType = [0 0 1]; % Set program type to characterise all data
        else % Check if no options selected
            set(ErrorMessage,'string','No options chosen') % Set error message
            set(ErrorMessage,'Visible','On') % Display error message
            return % End callback
        end
        clc
        refreshdata;
        Analyse_EEG_GUI(DetectorSettings,ProgramType); % Begin analysis of data
        set(PushStart,'Enable','On') % Enable push button
        set(ErrorMessage,'string','Analysis Finished') % Inform user that analysis is finished
    end
end


