function CompareSeizures1(Start,Animal,Seizure_Compare,SeizureTimes,Day,AnnotatedTimes)
% Created by Richard Balson 28/05/2013

if Day ~=1
    StartSecond=(Day-1)*24*60*60;
else
    StartSecond =0;
end
if  SeizureTimes.Detection ==1
    SeizureSec(:,1) = hms2sec(SeizureTimes.SeizureStartT);
SeizureSec(:,2) = hms2sec(SeizureTimes.SeizureEndT);
else
    SeizureSec = [0 0];
end
% SeizureSec(SeizureSec==0) = SeizureSec(SeizureSec==0
[Detect_seizure_matrix, Annotate_seizure_matrix] = Seizure2binary(Seizure_Compare,SeizureSec,StartSecond);
[Seizures_Correctly_Detected, False_Positive, False_Negative, SeizureStartTimeError, SeizureEndTimeError, TotalError, SeizureMatchIndex, Seizures_Detected, Actual_Seizures, Annotated_Seizure_Duration,StudyDuration] ...
    = Seizure_Count_Correct(Detect_seizure_matrix,Annotate_seizure_matrix,Start,Day,AnnotatedTimes);
WriteExcel(Start,Animal,Seizures_Correctly_Detected,False_Positive,False_Negative,SeizureStartTimeError,SeizureEndTimeError,TotalError,SeizureMatchIndex,Seizures_Detected,Actual_Seizures,Annotated_Seizure_Duration,Day,StudyDuration);


function [Seconds] = hms2sec(Time)
% Change time in format 'HH:MM:SS' to seconds

Seconds = zeros(size(Time,1),1);
for k = 1:size(Time,1)
    if iscell(Time)
    index = cell2mat(strfind(Time{k},':'));
    else
        index = strfind(Time(k,:),':');
    end
    if isempty(index)
        Seconds(k)=0;
        continue
    end
    if iscell(Time)
    [HoursS Remainder] = strtok(Time{k},':');
        [MinutesS Remainder] = strtok(Remainder,':');
    [SecondsS Remainder] = strtok(Remainder,':');
    Seconds(k) = str2double(SecondsS{1})+60*(str2double(MinutesS{1})+60*str2double(HoursS{1}));
    else
       [HoursS Remainder] = strtok(Time(k,:),':'); 
       [MinutesS Remainder] = strtok(Remainder,':');
    [SecondsS Remainder] = strtok(Remainder,':');
    Seconds(k) = str2double(SecondsS(:))+60*(str2double(MinutesS(:))+60*str2double(HoursS(:)));
    end
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
DSMIndex = SeizureSec(:,1);
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

function [Correct, FP, FN, SSError, SEError, Percentage_Error_Total, indexR, SD, AS,ASMD,StudyDuration] = Seizure_Count_Correct(DSM,ASM,Start,Day,AnnotatedTimes)
% Determine the number of correctly detected seizures,  how many seizures
% have been missed by the detector(FN) and how many non seizure events are
% marked by the detector as seizure (FP)
indexAnnotate = [];
for j = 1:length(AnnotatedTimes)/2
    indexA = (AnnotatedTimes((j-1)*2+1)*60*60+1):(AnnotatedTimes((j-1)*2+2)*60*60+1);
    if length(indexA)>1
        indexAnnotate = setxor(indexAnnotate,indexA);
    end
end
if (Day ==1 && (Start.StudyLength> 24*60*60-Start.Time_adjustmentT))
    index = Start.Time_adjustmentT:24*60*60;
    DayLength = length(DSM)-Start.Time_adjustmentT;
elseif Day ==1
    index = Start.Time_adjustmentT:(Start.Time_adjustmentT+Start.StudyLength);
    DayLength = Start.StudyLength;
else
    DayLength = Start.StudyLength-(Day-1)*24*60*60+Start.Time_adjustmentT;
    if DayLength >24*60*60
        DayLength = 24*60*60;
        index = 1:24*60*60;
    else
        index = 1:DayLength;
    end
end
index = intersect(index,indexAnnotate);
StudyDuration = length(index);
Percentage_Error_Total = sum(abs(ASM(index)-DSM(index)))/StudyDuration*100; % If study is less than a day
DSMIndexStart = strfind(DSM(index),[0 1])+1;
DSMIndexEnd = strfind(DSM(index),[1 0]);
ASMIndexStart = strfind(ASM(index),[0 1])+1;
ASMIndexEnd = strfind(ASM(index),[1 0])+1;
ASMD = ASMIndexEnd-ASMIndexStart;
Correct =0;
for k =1:length(DSMIndexStart)
    for j = 1:length(ASMIndexStart)
        cond1 =any((DSMIndexStart(k):DSMIndexEnd(k))' == ASMIndexStart(j));
        cond2 =any(DSMIndexStart(k):DSMIndexEnd(k) == ASMIndexEnd(j));
        if (cond1 || cond2)
            Correct = Correct+1;
            indexR(Correct,:) = [k j];
            SSError(Correct) = ASMIndexStart(j)-DSMIndexStart(k);
            SEError(Correct) = ASMIndexEnd(j) - DSMIndexEnd(k);
            ASMIndexStart(j) =0; ASMIndexEnd(j) =0;
        end
    end
end
AS = length(ASMIndexStart);
SD = length(DSMIndexStart);
FN = AS-Correct;
FP = SD-Correct;
if Correct ==0
    indexR = [0 0];
    SSError = 0;
    SEError = 0;
end

    function WriteExcel(Start,Animal,SCD,FP,FN,SSError,SEError,TE,SMI,SD,AS,ASD,Day,AnnotatedDuration)
    % This function writes all data to excel
    
    Spreadsheet_Name = ['Comparison_AnimalNumber ',int2str(Animal),' SD',int2str(Start.Day),'CD',int2str(Start.Day+Day-1),'_',int2str(Start.Month),'_',int2str(Start.Year),'.xls']; % Initilaise spreadsheet name
    Sheet_name = 'Results'; % Initilaise sheet name
   Excel_dataT = {'Seizures Detected','Annotated Seizures','Seizure Correctly Detected','False Postives', 'False Negatives', 'Total error over data segment(%)', 'Seizure Start Error','Seizure End Error','Match Index Detect', 'Match Index Annotate','Annotated Seizure Duration','Study Duration'}; % Specify names for EEG feature data
    Excel_dataD = [SD,AS,SCD,FP,FN,TE]; % Specify features to write to excel
    Excel_dataN =[SSError',SEError',SMI];
    Excel_DataF = ASD';
    ExcelDataD = AnnotatedDuration/3600;
    
    % Write data to excel
    xlswrite(Spreadsheet_Name,Excel_dataN,Sheet_name,'G2');
    xlswrite(Spreadsheet_Name,Excel_dataT,Sheet_name,'A1');
    xlswrite(Spreadsheet_Name,Excel_dataD,Sheet_name,'A2');
    if size(Excel_DataF,1)>0
    xlswrite(Spreadsheet_Name,Excel_DataF,Sheet_name,'K2');
    end
    xlswrite(Spreadsheet_Name,ExcelDataD,Sheet_name,'L2');
    
    
    
    
    
