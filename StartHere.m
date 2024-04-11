% Load results from grid morphology
load("Extracted/ExtractedGrids.mat");

% List contents of one dataset: contains responses, ground truth x/y
% positions, and times of each press
grid03

% 1000 random presses are recorded at 4 fixed forces: 0.3N, 0.5N, 0.7N,
% 1.0N, saved in grid03, grid05, grid07, grid10

% gridrepeats contains responses to 60 presses
% The first 4 are point A (5, 5) at 0.3, 0.5, 0.7 & 1.0N
% The next 4 are point B (5, 15) at 0.3, 0.5, 0.7 & 1.0N
% The next 4 are point C (15, 15) at 0.3, 0.5, 0.7 & 1.0N
% This sequence of 12 presses is repeated 5 times

size(gridrepeats.responses)

% 1024 response channels: plot and list which electrodes are involved in channel 93
load("combinations.mat");
combinations(93, :);
plotelectrodepositions(93);

pause();

% Some of the channels from the EIT board's default code are always zero
% I've included a function to get rid of these
responses = grid10.cleanresponses();

% See which locations cause the first 50 non-zero channels to respond most
% strongly
positions = grid10.positions;
clf
for i = 1:50
    scatter(positions(:, 1), positions(:,2), 30, responses(:, i), 'filled');
    title(string(i));
    axis equal
    pause();
end