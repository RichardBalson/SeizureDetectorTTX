function Seizure_time = ReadEEGExcel(filepath,sheet,number_of_animals,CurrentDay,Time_adjustment)
% script created by Richard Balson 20/02/2013

% description
% ~~~~~~~~~~~
% This script reads start and end times for Seizure data based on
% annotations, the filepath specifies the path of the excel sheet, sheet
% the specific sheet in the excel file used and number of animals the last
% cage that was used for recrdings. This excel sheet is a sheet with
% numeric values indicating time, further column one specifies the cage the seizure was detected in.
% The second column has seizure start times
% in seconds, and the third column seizure end times in seconds. The times
% are based on a midnight index where midnight is zero seconds and midday
% is 24*60*60/2 seconds Note that only one day of recordings can be
% processed by this file, and if more data is available the excel files
% should be split. Further no identifying cells should be specified. The
% output variable Seizure_time is a nx2xNumber_of_animals vector, where n
% indicates the maximum number of seizures detected for any animal. Each
% row indicates a different seizure and column one and two their start and
% end time respectively. Each nx2 matrix represents the results for each
% animal

[ExcelData] = xlsread(filepath,sheet); % Obtain data from excel sheet and file specified
Rows= find(any(isnan(ExcelData(:,1)),2)==1,1,'first')-1;
Columns = find(any(isnan(ExcelData(1,:)),1)==1,1,'first')-1;
if isempty(Columns)
    Columns = size(ExcelData,2);
end
ExcelData = ExcelData(1:Rows,1:Columns);

n = zeros(1,number_of_animals); % Create a temporary matrix
% Seizure_time = zeros(Rows,2,number_of_animals);
StartDay = CurrentDay;
for k =1:Rows % Loop through all the seizures
    for j = 1:number_of_animals % Loop through all cages
        if (ExcelData(k,1) == j) % Determine if the
            n(j) = n(j)+1; % Increase the index for the specified cage
            if Columns >=4
                if CurrentDay <=ExcelData(k,4)
                Seizure_time_init(n(j),1:2,j) = ExcelData(k,2:3)+(ExcelData(k,4)-CurrentDay)*24*60*60; % Create a temporary varaible storing seizure times,
                else
                  Seizure_time_init(n(j),1:2,j) = ExcelData(k,2:3)+(ExcelData(k,4))*24*60*60;
                end
                % where rows are seizure for a particular animal,
                % the columns have seizure times and the
                % third dimension specifies the cage the seizure was found in
                if Columns ==5
                    Seizure_time_init(n(j),3,j) = ExcelData(k,5); % Detaisabout convulsive or non convulsive seizures
                end
            else
                if ExcelData(k,2)>Time_adjustment
                    Seizure_time_init(n(j),:,j) = ExcelData(k,2:3);
                else
                    Seizure_time_init(n(j),:,j) = ExcelData(k,2:3)+24*60*60;
                end
            end
        end
    end
end

Seizure_time = zeros(max(n),2+(Columns==5),number_of_animals); % Initialise variable to store seizure times
Seizure_time(1:size(Seizure_time_init,1),1:size(Seizure_time_init,2),1:size(Seizure_time_init,3)) = Seizure_time_init; % Transfer seizure times into variable used

