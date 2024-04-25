%% Logistics: load in data
load("Extracted/ExtractedRadials.mat");
positions = radial03.positions;
responses = radial03.cleanresponses();

%% Localize using WAM: return average localization error on 10% test set
error = wamtesting(1:size(responses,2), responses, positions, 0);
fprintf("Localization Error on Test Set: %fmm\n", error);

% Change final input to 1 to see prediction map & ground truth (red cross)
% wamtesting(1:size(responses,2), responses, positions, 1);

%% WAM implementation
function error = wamtesting(combinations, responses, targetpositions, figs, traininds, testinds)
        
    responses = tanh(normalize(responses)); % Deal with outliers

    % Generate test & train sets, if not explicitly input
    if nargin == 4
        P = randperm(length(targetpositions));
        traininds = P(1:floor(0.9*length(targetpositions)));
        testinds = P(ceil(0.9*length(targetpositions)):end);
    end
    testresponses = responses(testinds, :);
    testpositions = targetpositions(testinds, :);
    responses = responses(traininds, :);
    targetpositions = targetpositions(traininds, :);

    error = 0;

    % Loop through test set
    for i = 1:size(testresponses, 1)
        % Actual WAM process
        sum = zeros([size(responses, 1), 1]);
        for j = 1:length(combinations)
            newsum = testresponses(i, combinations(j))*responses(:, combinations(j));
            if isempty(find(isnan(newsum), 1))
                sum = sum + newsum;
            end
        end

        [~, ind] = sort(sum, 'descend');


        % Prediction is average location of n brightest pixels
        % (Here n = 1 ie brightest pixel prediction)
        n = min(1, size(responses, 2));
        prediction = [mean(targetpositions(ind(1:n), 1)),...
                        mean(targetpositions(ind(1:n), 2))];


        error = error + rssq(prediction-testpositions(i,:));

        % Plot error map if final input is 1
        if figs
            vals = sum;
            interpolant = scatteredInterpolant(targetpositions(:,1), targetpositions(:,2), vals);
            [xx,yy] = meshgrid(linspace(min(targetpositions(:,1)), max(targetpositions(:,1)),100),...
                                linspace(min(targetpositions(:,2)), max(targetpositions(:,2)),100));
            value_interp = interpolant(xx,yy); 
            value_interp = max(value_interp, 0); % Don't allow extrapolation below zero
            contourf(xx,yy,value_interp, 100, 'LineStyle', 'none');
            
            
            hold on
            scatter(testpositions(i, 1), testpositions(i, 2), 100, 'r', 'x');
            axis equal
            axis off
            set(gcf, 'position', [871   531   272   284], 'color', 'w');
            title("Test Set, Press " + string(testinds(i)));
            pause();
            clf
        end
    end
    error = error/size(testresponses, 1); % calculate mean
end
