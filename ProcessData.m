function ProcessData(Spreadsheet,Start)
% Created by Richard Balson 23/07/2013
% This function Processes data from aan excel file that has the data for
% characterised seizures

[~,Sheetnames] = xlsfinfo(Spreadsheet);
Seizure_number =0;
for k = 1:length(Sheetnames)
    if strcmp(Sheetnames{k}(1:5),'Seizu')
        Seizure_number = Seizure_number+1;
        [Data, Details] =xlsread(Spreadsheet,Sheetnames{k});
        Channels =  sum(sum(strncmp(Details,'Channel',7)));
        [~,AmplitudeInd] = find(strncmp(Details,'Maxi',4));
        [~,ZeroInd] = find(strncmp(Details,'Zero',4));
        [~,LLInd] = find(strncmp(Details,'Line',4));
        [~,TimeInd] = find(strncmp(Details,'Time',4));
        DeltaT = Data(2,TimeInd(1))-Data(1,TimeInd(1));
        PaddingIndex = Start.Padding/DeltaT;
        SeizureIndex = size(Data,1) - PaddingIndex;
        for  j=1:Channels
            PaddingAmpMean(Seizure_number,j) = mean(Data(1:PaddingIndex,AmplitudeInd(j)));
            PaddingZCDMean(Seizure_number,j) = mean(Data(1:PaddingIndex,ZeroInd(j)));
            PaddingLLMean(Seizure_number,j) = mean(Data(1:PaddingIndex,LLInd(j)));
            SeizureAmpMean(Seizure_number,j) = mean(Data(PaddingIndex+1:SeizureIndex,AmplitudeInd(j)));
            SeizureZCDMean(Seizure_number,j) = mean(Data(PaddingIndex+1:SeizureIndex,ZeroInd(j)));
            SeizureLLMean(Seizure_number,j) = mean(Data(PaddingIndex+1:SeizureIndex,LLInd(j)));
            PaddingEndAmpMean(Seizure_number,j) = mean(Data(SeizureIndex:end,AmplitudeInd(j)));
            PaddingEndZCDMean(Seizure_number,j) = mean(Data(SeizureIndex:end,ZeroInd(j)));
            PaddingEndLLMean(Seizure_number,j) = mean(Data(SeizureIndex:end,LLInd(j)));
        end
    end
end