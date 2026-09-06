clear
clc
close all

addpath(".\BedFormAnalysis\");
addpath(".\MoRiverBedformIdentification\");
addpath(".\MoRiverBedformIdentification\VectorMath\");
addpath("..\..\..\Single Beam Data\")

%% Variables
    frequency = 0.00001; % data frequency for linear interpolation
    Axis = "Center"; % Center, Left, or Right data
    ox = 0.1; % offset x to correct for discrete when mapping
    xStart = 110; % starting mile
    xLength = 10; % plot length (miles)
    month = "June"; % month of data collection
    N = 25; % number of tests
    s = -4; % start of exponential function
    e = 1; % end of exponential function
    numbers = zeros(1, N); % initialize the numbers vector
    avgLength = zeros(1, N); % initialize the length vector
    avgHeight = zeros(1, N); % initialize the height vector

%% Get Data
    load("MoRiverData.mat");
        [x1, y1, x2, y2] = getRiverData(MoData, xStart, xLength, month);
    
    % data must be smoothed (sparingly) to distinguish peaks
        [X, Y] = curveSmoothing(x1, y1, 1, 23);

    x = linspace(s, e, N);
    p = 10.^x;

    for i = 1:N
        [n, l, h] = prominenceTest(X, Y, p(i));
        numbers(i) = n;
        avgLength(i) = mean(l);
        avgHeight(i) = mean(h);
        fprintf("%d of %d completed.\n", i, N);
    end

%% Plot Data
    figure("Name", "Number of Dunes vs. Prominence");
        loglog(p, numbers);
        hold on;
        loglog(1, numbers(20), 'o');
        loglog(0.01, numbers(10) , 'o');
        title("Number of Dunes vs. Prominence")
        xlabel("Prominence");
        ylabel("Number of Dunes");
        legend("Number of Dunes");
        hold off;
    figure("Name","Dunes vs. Prominence");
        plot(p, numbers);

    figure("Name", "Average Lengths and Heights vs. Prominence");
        yyaxis left;
        loglog(p, avgLength);
        hold on;
        loglog(1, avgLength(20), 'o')
        loglog(0.01, avgLength(10), 'o');
        ylabel("Average Length");
        yyaxis right;
        loglog(p, avgHeight);
        hold on;
        loglog(1, avgHeight(20), 'o')
        loglog(0.01, avgHeight(10), 'o');
        ylabel("Average Height")
        title("Average Lengths and Heights vs. Prominence")
        xlabel("Prominence");
        legend("Average Length (meters)", '','',"Average Height (meters)", '','',"Location","northwest");
        hold off;