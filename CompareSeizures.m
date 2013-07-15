function CompareSeizures(Start,Animal,Seizure_Compare,SeizureTimes,Day)
% Created by Richard Balson 28/05/2013
if Day ==1
StartSecond = (Start.Hours*60+Start.Minutes)*60+Start.Seconds;
else 
    StartSecond=(Day-1)*24*60*60;
end
SeizureSec(:,1) = hms2sec(SeizureTimes.SeizureStartT);
SeizureSec(:,2) = hms2sec(SeizureTimes.SeizureEndT);
% SeizureSec(SeizureSec==0) = SeizureSec(SeizureSec==0
[Detect_seizure_matrix, Annotate_seizure_matrix] = Seizure2binary(Seizure_Compare,SeizureSec,StartSecond);
[Seizures_Correctly_Detected, False_Positive, False_Negative, SeizureStartTimeError, SeizureEndTimeError, TotalError, SeizureMatchIndex, Seizures_Detected, Actual_Seizures, Annotated_Seizure_Duration] ...
    = Seizure_Count_Correct(Detect_seizure_matrix,Annotate_seizure_matrix);
WriteExcel(Start.Day,Start.Month,Start.Year,Animal,Seizures_Correctly_Detected,False_Positive,False_Negative,SeizureStartTimeError,SeizureEndTimeError,TotalError,SeizureMatchIndex,Seizures_Detected,Actual_Seizures,Annotated_Seizure_Duration,Day);


function [Seconds] = hms2sec(Time)
% Change time in format 'HH:MM:SS' to seconds

Seconds = zeros(size(Time,1),1);
for k = 1:length(Time)
    index = cell2mat(strfind(Time{k},':'));
    if isempty(index)
        Seconds(k)=0;
        continue
    end
    [HoursS Remainder] = strtok(Time{k},':');
    [MinutesS Remainder] = strtok(Remainder,':');
    [SecondsS Remainder] = strtok(Remainder,':');
    Seconds(k) = str2double(SecondsS{1})+60*(str2double(MinutesS{1})+60*str2double(HoursS{1}));
%     Hours = str2double(Time{k}{1:index(1)-1});
%     Minutes = str2double(Time{k}(index(1)+1:index(2)-1));
%     Seconds(k) = str2double(Time{k}(index(2)+1:end)) + 60*(Minutes +60*Hours);
end

function [DSM, ASM] = Seizure2binary(Seizure_Compare,SeizureSec,StartSecond)
% Make binary matrix for seizures, this binary matrix represents each
% second of a day as being either seizure or non seizure
if SeizureSec(1,2) ==0
SeizureSec = SeizureSec(2:end,:);
end
DSM = zeros(1,24*60*60);
ASM = zeros(1,24*60*60);
ASMIndex = Seizure_Compare(:,1) -StartSecond;
ASMIndex(ASMIndex<0) = ASMIndex(ASMIndex<=0)+ 24*60*60;
ASMDurationIndex = Seizure_Compare(:,2) - Seizure_Compare(:,1)+ASMIndex;
DSMIndex = SeizureSec(:,1) - StartSecond;
DSMIndex(DSMIndex<0) = DSMIndex(DSMIndex<0)+ 24*60*60;
DSMDurationIndex = SeizureSec(:,2)-SeizureSec(:,1)+ DSMIndex;
for k = 1:length(DSMIndex)
    if round(DSMIndex(k))~=round(DSMDurationIndex(k))
    DSM(round(DSMIndex(k)):round(DSMDurationIndex(k))) =1;
    end
end
for k =1:length(ASMIndex)
    if round(ASMIndex(k))~=round(ASMDurationIndex(k))
    ASM(round(ASMIndex(k)):round(ASMDurationIndex(k)))=1;
    end
end

function [Correct, FP, FN, SSError, SEError, Percentage_Error_Total, index, SD, AS,ASMD] = Seizure_Count_Correct(DSM,ASM)
% Determine the number of correctly detected seizures,  how many seizures
% have been missed by the detector(FN) and how many non seizure events are
% marked by the detector as seizure (FP)

index = [];
SSError =[];
SEError =[];
ASMD=[];
Percentage_Error_Total = sum(abs(ASM-DSM))/length(DSM)*100;
DSMIndexStart = strfind(DSM,[0 1])+1;
DSMIndexEnd = strfind(DSM,[1 0]);
ASMIndexStart = strfind(ASM,[0 1])+1;
ASMIndexEnd = strfind(ASM,[1 0])+1;
Correct =0;
for k =1:length(DSMIndexStart)
    for j = 1:length(ASMIndexStart)
        cond1 =any((DSMIndexStart(k):DSMIndexEnd(k))' == ASMIndexStart(j));
        cond2 =any(DSMIndexStart(k):DSMIndexEnd(k) == ASMIndexEnd(j));
        if (cond1 || cond2)
            Correct = Correct+1;
            index(Correct,:) = [k j];
            SSError(Correct) = ASMIndexStart(j)-DSMIndexStart(k);
            SEError(Correct) = ASMIndexEnd(j) - DSMIndexEnd(k);
            ASMD(Correct) = ASMIndexEnd(j)-ASMIndexStart(j);
            ASMIndexStart(j) =0; ASMIndexEnd(j) =0;
        end
    end
end
AS = length(ASMIndexStart);
SD = length(DSMIndexStart);
FN = AS-Correct;
FP = SD-Correct;
if Correct ==0
    index = [0 0];
    SSError = 0;
    SEError = 0;
end

    function WriteExcel(D,M,Y,Animal,SCD,FP,FN,SSError,SEError,TE,SMI,SD,AS,ASD,Day)
    % This function writes all data to excel
    
    Spreadsheet_Name = ['Comparison AnimalNumber ',int2str(Animal),' D ',int2str(D+Day-1),'_',int2str(M),'_',int2str(Y),'.xls']; % Initilaise spreadsheet name
    Sheet_name = 'Results'; % Initilaise sheet name
   Excel_dataT = {'Seizures Detected','Annotated Seizures','Seizure Correctly Detected','False Postives', 'False Negatives', 'Total error over data segment(%)', 'Seizure Start Error','Seizure End Error','Match Index Detect', 'Match Index Annotate','Annotated Seizure Duration'}; % Specify names for EEG feature data
    Excel_dataD = [SD,AS,SCD,FP,FN,TE]; % Specify features to write to excel
    Excel_dataN =[SSError',SEError',SMI,ASD'];
    
    % Write data to excel
    xlswrite(Spreadsheet_Name,Excel_dataN,Sheet_name,'G2');
    xlswrite(Spreadsheet_Name,Excel_dataT,Sheet_name,'A1');
    xlswrite(Spreadsheet_Name,Excel_dataD,Sheet_name,'A2');
    
    
    
    
    
