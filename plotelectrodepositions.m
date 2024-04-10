function plotelectrodepositions(ind)
    load("combinations.mat", "combinations");
    load("electrodepositions.mat", "electrodepositions");

    scatter(electrodepositions(:,1), electrodepositions(:,2), 20, 'k', 'filled');
    hold on

    % Injection electrodes colored red
    scatter(electrodepositions(combinations(ind, 1:2),1), electrodepositions(combinations(ind, 1:2),2), 50, 'r', 'filled');

    % Measurement electrodes colored blue
    scatter(electrodepositions(combinations(ind, 3:4),1), electrodepositions(combinations(ind, 3:4),2), 50, 'b', 'filled');

    axis equal
end