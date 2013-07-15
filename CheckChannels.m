function [ChannelLength Number_of_animals]  = CheckChannels(ChannelName)
% script created by Richard Balson 12/03/2013

% description
% ~~~~~~~~~~~
% This function determines how many channels each animal has recordings
% from as well as the last number cage that is recorded from, ie. if cages
% 1,3 and 7 are recorded from Number_of_animals will be 7. Channelname is a
% cell of strings that specify cage number and electrode used. Lastly
% Channel length indicates the number of channels used in each cage, for
% example if cage 7 has four channels ChannelLength(7)=4

TotalChs = length(ChannelName); % Determine number of channels recorded from


for k = 1:TotalChs % Loop through all channels
    Animal_number(k) = int32(str2num(ChannelName{k}(1))); % Determine which animal each channel is from,
    % and write it to a vector specifying each electrodes identifying cage,
    % if cage 7 has 4 channels there will be four elements in the vector that are =7
end

Number_of_animals = max(Animal_number); % Determine the last cage used in recordings
ChannelLength= zeros(Number_of_animals,1); % Specify the channellength matrix

for j = 1:Number_of_animals % Loop through all cages
    for k = 1:TotalChs % Loop through all channels
        ChannelLength(j) = ChannelLength(j)+(Animal_number(k) == j); % Determine how many channels are used for each animal, increment count whenever j matches k
    end
end