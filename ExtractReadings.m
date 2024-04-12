% Inefficient script for extracting data - good enough for functionality
[readings, readingtimes] = extracteit("RawData/PartRadial");
[positions, positiontimes] = extractprinter("RawData/PartRadialProbing1_0");
partradial10 = combinedata(readings, readingtimes, positions, positiontimes);


% Extract data from EIT board
function [readings, readingtimes] = extracteit(filename)
    lines = readlines(filename);
    lines = lines(4:end-1);
    
    readings = zeros([length(lines), 1024]);
    readingtimes(length(lines)) = datetime();
    
    for i = 1:length(lines)
        line = char(lines(i));
        readingtimes(i) = datetime(line(2:24));
        response = str2double(split(line(27:end), ", "));
        readings(i, :) = response(1:1024);
    end
end


% Extract data from printer
function [positions, positiontimes] = extractprinter(filename)
    lines = readlines(filename);
    lines = lines(1:end-1);
    
    positions = zeros([length(lines), 2]);
    positiontimes(length(lines), 3) = datetime();
    
    for i = 1:length(lines)
        items = split(char(lines(i)), ", ");
        positions(i, :) = [str2double(items{1, 1}) str2double(items{2, 1})];
        positiontimes(i, :) = [datetime(items{3, 1}) datetime(items{4, 1}) datetime(items{5, 1})];
    end
end

% Combine data to create object
function responseobject = combinedata(readings, readingtimes, positions, positiontimes)

    % Ensure there are no nans in response before beginning
    goodindices = [];
    for i = 1:length(readings)
        if ~any(isnan(readings(i, :)))
            goodindices = [goodindices; i];
        end
    end
    readings = readings(goodindices, :);
    readingtimes = readingtimes(goodindices);

    responses = zeros([length(positions), 1024]);
    for i = 1:length(positions)
        ind1 = find(readingtimes>positiontimes(i, 2), 1, "first");
        ind2 = find(readingtimes<positiontimes(i, 2)+seconds(5), 1, "last");

        ind3 = find(readingtimes>positiontimes(i, 1)-seconds(5), 1, "first");
        ind4 = find(readingtimes<positiontimes(i, 1), 1, "last");

        if isempty(ind1) || isempty(ind2) || isempty(ind3) || isempty(ind4)
            i
            fprintf("NAN READING\n");
        end

        responses(i, :) = mean(readings(ind1:ind2, :)) - mean(readings(ind3:ind4, :));
    end
    responseobject = SkinResponse(responses, positiontimes(:, 2), positions);
end