% Scipt created by Richard Balson 3/10/2013

clear all
clc
close all
Number_of_animals =8;


for k=1:Number_of_animals
    Directory = dir(['*AnimalNumber ',int2str(k),'*.xls']);
    if ~isempty(Directory)
        Filename = ['Summary_Animal ',int2str(k),'.xls'];
        for j = 1:length(Directory)
            if ~isempty(strfind(Directory(j).name,'Pad'))
                SummariseData(Directory(j),Filename,'Characterise');
            elseif ~isempty(strfind(Directory(j).name,'Comparison'))
                SummariseData(Directory(j),Filename,'Comparison');
            elseif ~isempty(strfind(Directory(j).name,'SeizuresDetected'))
                SummariseData(Directory(j),Filename,'Detected');
            elseif ~isempty(strfind(Directory(j).name,'ASeizureSplit'))
                SummariseData(Directory(j),Filename,'ProcessedSplit');
            elseif ~isempty(strfind(Directory(j).name,'APAnimal'))
                SummariseData(Directory(j),Filename,'ProcessedO');
            elseif ~isempty(strfind(Directory(j).name,'APRAnimal'))
                SummariseData(Directory(j),Filename,'ProcessedRaw');
            elseif ~isempty(strfind(Directory(j).name,'APNon'))
                SummariseData(Directory(j),Filename,'ProcessedNon');
            elseif ~isempty(strfind(Directory(j).name,'APCon'))
                SummariseData(Directory(j),Filename,'ProcessedCon');
            else
                disp(['Filetype unknown ', Directory(j).name]); 
            end
        end
    end
end