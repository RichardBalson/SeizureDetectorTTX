function ProcessData(ExcelSheets,Start,Epochs)
% Created by Richard Balson 23/07/2013
% This function Processes data from aan excel file that has the data for
% characterised seizures

% Next Edit
% Add code to wriute split seizure data to excel file, and make a user
% input to specify epochs

for Sheet =1:length(ExcelSheets)
    [~,Sheetnames] = xlsfinfo(ExcelSheets(Sheet).name); % Find out details for specified worksheet
    for k = 1:length(Sheetnames)
        if strcmp(Sheetnames{k}(1:5),'Seizu')
            Seizure_number = str2double(Sheetnames{k}(end-1:end));
            if isnan(Seizure_number)
                Seizure_number = str2double(Sheetnames{k}(end));
            end
            [Data, Details] =xlsread(ExcelSheets(Sheet).name,Sheetnames{k});
            Channels =  sum(sum(strncmp(Details,'Channel',7)));
            [~,AmplitudeInd] = find(strncmp(Details,'Maxi',4));
            [~,ZeroInd] = find(strncmp(Details,'Zero',4));
            [~,LLInd] = find(strncmp(Details,'Line',4));
            [~,TimeInd] = find(strncmp(Details,'Time',4));
            [~,SevInd] = find(strncmp(Details,'Seiz',4));
            SevTest = Details(3,SevInd(1));
            if strcmp(SevTest{1}(1:3),'Con')
                Severity =1;
            elseif strcmp(SevTest{1}(1:3),'Non')
                Severity =0;
            else
                Severity =[];
            end
            DeltaT = Data(2,TimeInd(1))-Data(1,TimeInd(1));
            PaddingIndex = Start.Padding/DeltaT;
            SeizureIndex = size(Data,1) - PaddingIndex;
            for  j=1:Channels
                
                if Epochs>1
                    SeizureSplit(Seizure_number,j,:,:,:) = CreateMat(Data,Epochs,PaddingIndex,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                end
                Padding(Seizure_number,j,:,:) = CreateMat(Data,1,1,PaddingIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);% 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH, 4th mean, min, max, std
                Seizure(Seizure_number,j,:,:) = CreateMat(Data,1,PaddingIndex+1,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                PaddingEnd(Seizure_number,j,:,:) = CreateMat(Data,1,SeizureIndex+1,size(Data,1),[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                if ~isempty(Severity)
                    if Severity
                        if Epochs>1
                            ConSeizureSplit(Seizure_number,j,:,:,:) = CreateMat(Data,Epochs,PaddingIndex,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                        end
                        ConPadding(Seizure_number,j,:,:) = CreateMat(Data,1,1,PaddingIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);% 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH, 4th mean, min, max, std
                        ConSeizure(Seizure_number,j,:,:) = CreateMat(Data,1,PaddingIndex+1,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                        ConPaddingEnd(Seizure_number,j,:,:) = CreateMat(Data,1,SeizureIndex+1,size(Data,1),[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                    else
                        if Epochs>1
                            NonConSeizureSplit(Seizure_number,j,:,:,:) = CreateMat(Data,Epochs,PaddingIndex,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                        end
                        NonConPadding(Seizure_number,j,:,:) = CreateMat(Data,1,1,PaddingIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);% 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH, 4th mean, min, max, std
                        NonConSeizure(Seizure_number,j,:,:) = CreateMat(Data,1,PaddingIndex+1,SeizureIndex,[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                        NonConPaddingEnd(Seizure_number,j,:,:) = CreateMat(Data,1,SeizureIndex+1,size(Data,1),[AmplitudeInd(j) ZeroInd(j) LLInd(j)]);
                    end
                end
                %                 Seizure(Seizure_number,j,:,:) = [mean(Data(PaddingIndex+1:SeizureIndex,AmplitudeInd(j)))...
                %                                                    mean(Data(PaddingIndex+1:SeizureIndex,ZeroInd(j)))...
                %                                                    mean(Data(PaddingIndex+1:SeizureIndex,LLInd(j)));...
                %                                                    min(Data(PaddingIndex+1:SeizureIndex,AmplitudeInd(j)))...
                %                                                    min(Data(PaddingIndex+1:SeizureIndex,ZeroInd(j)))...
                %                                                    min(Data(PaddingIndex+1:SeizureIndex,LLInd(j)));...
                %                                                    max(Data(PaddingIndex+1:SeizureIndex,AmplitudeInd(j)))...
                %                                                    max(Data(PaddingIndex+1:SeizureIndex,ZeroInd(j)))...
                %                                                    max(Data(PaddingIndex+1:SeizureIndex,LLInd(j)));...
                %                                                    std(Data(PaddingIndex+1:SeizureIndex,AmplitudeInd(j)))...
                %                                                    std(Data(PaddingIndex+1:SeizureIndex,ZeroInd(j)))...
                %                                                    std(Data(PaddingIndex+1:SeizureIndex,LLInd(j)))]';
                %                 PaddingEnd(Seizure_number,j,:,:) = [mean(Data(SeizureIndex:end,AmplitudeInd(j)))...
                %                                                       mean(Data(SeizureIndex:end,ZeroInd(j)))...
                %                                                       mean(Data(SeizureIndex:end,LLInd(j)));...
                %                                                       min(Data(SeizureIndex:end,AmplitudeInd(j)))...
                %                                                       min(Data(SeizureIndex:end,ZeroInd(j)))...
                %                                                       min(Data(SeizureIndex:end,LLInd(j)));...
                %                                                       max(Data(SeizureIndex:end,AmplitudeInd(j)))...
                %                                                       max(Data(SeizureIndex:end,ZeroInd(j)))...
                %                                                       max(Data(SeizureIndex:end,LLInd(j)));...
                %                                                       std(Data(SeizureIndex:end,AmplitudeInd(j)))...
                %                                                       std(Data(SeizureIndex:end,ZeroInd(j)))...
                %                                                       std(Data(SeizureIndex:end,LLInd(j)))]';
            end
        end
    end
    Spreadsheet_Name = ['AP',ExcelSheets(Sheet).name]; % Specify name for spreadsheet
    Spreadsheet_Name_Raw = ['APR',ExcelSheets(Sheet).name]; % Specify name for spreadsheet
    Column_Title = {'Padding Ampltide Mean','Padding Zero Crossing Mean','Padding Line Length Mean',...
        'Seizure Ampltide Mean','Seizure Zero Crossing Mean','Seizure Line Length Mean',...
        'Post Ictal Ampltide Mean','Post Ictal Zero Crossing Mean','Post Ictal Line Length Mean'};
    Sheet_names ={'Amplitude Mean','Zero Crossing Mean','Line Length Mean',...
        'Amplitude Min','Zero Crossing Min','Line Length Max',...
        'Amplitude Max','Zero Crossing Max','Line Length Max',...
        'Amplitude std','Zero Crossing std','Line Length std'};
    for  j=1:Channels
        Column_sub_titleT{j} = ['Channel ',int2str(j)];
    end
    DataExcel = [Padding, Seizure, PaddingEnd];
    Periods = size(DataExcel,2)/Channels;
    Features =size(DataExcel,3);
    Columns = cell(Channels*Periods,2);
    Column_sub_title = repmat(Column_sub_titleT,1,Periods);
    Columns(:,2) = Column_sub_title;
    % for k =1:Features
    %     Columns{(k-1)*Channels+1,1} =  Column_Title{(k-1)*Features+1};
    % end
    for j = 1:size(DataExcel,1)
        Row_title{j} = ['Seizure ',int2str(j)];
    end
    for k =1:size(DataExcel,4)
        for j =1:Features
            for m =1:Periods
                Columns{(m-1)*Channels+1,1} =  Column_Title{(m-1)*Features+j};
            end
            Index = (k-1)*Features+j;
            xlswrite(Spreadsheet_Name_Raw,Columns',Sheet_names{Index},'B1')
            xlswrite(Spreadsheet_Name_Raw,Row_title',Sheet_names{Index},'A3');
            xlswrite(Spreadsheet_Name_Raw,DataExcel(:,:,j,k),Sheet_names{Index},'B3');
        end
    end
    
    % Process convulsive seizure data
    if exist('ConPadding','var')
        Spreadsheet_Name_Raw = ['APCon',ExcelSheets(Sheet).name]; % Specify name for spreadsheet
        DataExcel = [ConPadding, ConSeizure, ConPaddingEnd];
        for k =1:size(DataExcel,4)
            for j =1:Features
                for m =1:Periods
                    Columns{(m-1)*Channels+1,1} =  Column_Title{(m-1)*Features+j};
                end
                Index = (k-1)*Features+j;
                xlswrite(Spreadsheet_Name_Raw,Columns',Sheet_names{Index},'B1')
                xlswrite(Spreadsheet_Name_Raw,Row_title',Sheet_names{Index},'A3');
                xlswrite(Spreadsheet_Name_Raw,DataExcel(:,:,j,k),Sheet_names{Index},'B3');
            end
        end
    end
    
        if exist('NonConPadding','var')
        Spreadsheet_Name_Raw = ['APNonCon',ExcelSheets(Sheet).name]; % Specify name for spreadsheet
        DataExcel = [NonConPadding, NonConSeizure, NonConPaddingEnd];
        for k =1:size(DataExcel,4)
            for j =1:Features
                for m =1:Periods
                    Columns{(m-1)*Channels+1,1} =  Column_Title{(m-1)*Features+j};
                end
                Index = (k-1)*Features+j;
                xlswrite(Spreadsheet_Name_Raw,Columns',Sheet_names{Index},'B1')
                xlswrite(Spreadsheet_Name_Raw,Row_title',Sheet_names{Index},'A3');
                xlswrite(Spreadsheet_Name_Raw,DataExcel(:,:,j,k),Sheet_names{Index},'B3');
            end
        end
    end
    
    if Epochs >1
        clear Columns
        DataExcel =[];
        Spreadsheet_Name_Raw = ['ASeizureSplit',ExcelSheets(Sheet).name]; % Specify name for spreadsheet
        for k =1:Epochs
            DataExcel = cat(2,DataExcel,SeizureSplit(:,:,:,:,k));
        end
        Periods = size(DataExcel,2)/Channels;
        Column_sub_title = repmat(Column_sub_titleT,1,Periods);
        Columns(:,2) = Column_sub_title;
        Column_append_type ={'Mean','Min','Max','Std'};
        Column_append_feature = {'Amplitude','Zero Crossings','Line Length'};
        for k =1:size(DataExcel,4)
            for j =1:Features
                for m =1:Periods
                    Columns{(m-1)*Channels+1,1} =  ['Seizure Split ',int2str(m),' ',Column_append_feature{j},' ',Column_append_type{k}];
                end
                Index = (k-1)*Features+j;
                xlswrite(Spreadsheet_Name_Raw,Columns',Sheet_names{Index},'B1')
                xlswrite(Spreadsheet_Name_Raw,Row_title',Sheet_names{Index},'A3');
                xlswrite(Spreadsheet_Name_Raw,DataExcel(:,:,j,k),Sheet_names{Index},'B3');
            end
        end
    end
end


function MeanMinMax = CreateMat(Data,Epochs,Index1,Index2,Indices)

SeizureSamples = Index2-Index1;
SplitSamples = SeizureSamples/Epochs;

for j =1:Epochs
    Index1(j) = round(Index1(1)+(j-1)*SplitSamples);
    Index2(j) = round(Index1(1)+(j)*SplitSamples);
    MeanMinMax(:,:,j) = [mean(Data(Index1(j):Index2(j),Indices(1)))... % 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH, 4th mean, min, max, std
        mean(Data(Index1(j):Index2(j),Indices(2)))...
        mean(Data(Index1(j):Index2(j),Indices(3)));...
        min(Data(Index1(j):Index2(j),Indices(1)))... % 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH
        min(Data(Index1(j):Index2(j),Indices(2)))...
        min(Data(Index1(j):Index2(j),Indices(3)));...
        max(Data(Index1(j):Index2(j),Indices(1)))... % 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH
        max(Data(Index1(j):Index2(j),Indices(2)))...
        max(Data(Index1(j):Index2(j),Indices(3)));...
        std(Data(Index1(j):Index2(j),Indices(1)))... % 1ST DIMENSION AMPLITUDE, 2ND ZERO CROSSINGS 3RD LINE LENGTH
        std(Data(Index1(j):Index2(j),Indices(2)))...
        std(Data(Index1(j):Index2(j),Indices(3)))]';
end
MeanMinMax = squeeze(MeanMinMax);


