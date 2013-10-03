function SummariseData(Directory,FileName,FileType)
% Created y Richard Balson 03/10/2013
%   Detailed explanation goes here
if strcmp(FileType,'Characterise')
    [Columns Title] = FindCol(FileName,'Characterise');
    Sheet = 'CharacterisedData';
    Data = [0,1;2 3];
elseif strcmp(FileType,'Comparison')
    [Columns Title] = FindCol(FileName,'Comparison');
    Sheet = 'Comparison';
    Data = SummariseComp(Directory);
elseif strcmp(FileType,'Detected')
    
elseif strcmp(FileType,'ProcessedSplit')
    
elseif strcmp(FileType,'ProcessedO')
    
elseif strcmp(FileType,'ProcessedRaw')
    
elseif strcmp(FileType,'ProcessedNon')
    
elseif strcmp(FileType,'ProcessedCon')
      
end
if exist('Sheet','var')
if Title
  xlswrite(FileName,Data(1,:),Sheet,'A1'); 
end
xlswrite(FileName,Data(2,1),Sheet,['A',num2str(Columns)]);   
xlswrite(FileName,Data(2,2:end),Sheet,['B',num2str(Columns)]);
end
end

function Data = SummariseCharacterise(Dir)
 Data=0;

end

function Data = SummariseComp(Dir)
 [Results,Details]=xlsread(Dir.name,'Results')
 Data(1,2:7) = Details(1:6);
 Data(2,2:7) = num2cell(Results(1,1:6));
 Day = Dir.name(strfind(Dir.name,'CD')+2:strfind(Dir.name,'CD')+3);
 try
     DayN = str2num(Day);
 catch
     DayN = str2num(Day(1));
 end
 Data(2,1) = {['Day ',int2str(DayN)]};
 
end

function [Columns index]= FindCol(FileName,Sheet)
    try 
        Data = xlsread(FileName,Sheet)
        Columns = 2+size(Data,1);
        index =0;
    catch
        Columns =2;
        index = 1;
    end
end

