% Step 1: Create a Satellite Scenario
sc = satelliteScenario; % Initialize the satellite scenario
sc.StartTime = datetime(2024, 12, 27, 5, 30, 0); % Example date
sc.StopTime = datetime(2024, 12, 27, 7, 0, 0); % Example duration
disp('Satellite scenario created.');

% Step 2: Define Satellite Parameters
semiMajorAxis = 6871e3 + 780e3; % Earth's radius + 780 km (in meters)
eccentricity = 0; % Circular orbit
inclination = 86.4; % Inclination angle (degrees)
raan = 90; % Right Ascension of Ascending Node (degrees)
argOfPerigee = 0; % Argument of Perigee (degrees)
trueAnomaly = 0; % Initial True Anomaly (degrees)

% Step 3: Add a Satellite to the Scenario
sat = satellite(sc, semiMajorAxis, 0, inclination, raan, 0, 0, 'Name', 'Iridium-1');
disp('LEO Satellite added to the scenario.');

% Step 4: Define Ground Stations
gs1 = groundStation(sc, 13.0827, 80.2707, 'Name', 'Chennai'); % Chennai
gs2 = groundStation(sc, 28.6139, 77.2090, 'Name', 'New Delhi'); % New Delhi
disp('Ground stations added.');

% Step 5: Display Scenario Details
disp(['Satellite Name: ', sat.Name]);
disp(['Ground Stations: ', gs1.Name, ', ', gs2.Name]);

% Step 6: Visualize the Scenario
viewer = satelliteScenarioViewer(sc); % Launch the viewer
disp('Satellite scenario viewer launched.');

% Step 7: Calculate Access Times Between Satellite and Ground Stations
access1 = access(sat, gs1);
access2 = access(sat, gs2);

% Extract and Display Access Intervals
disp('Access Times for Chennai (Start-End Intervals):');
disp(accessIntervals(access1));

disp('Access Times for New Delhi (Start-End Intervals):');
disp(accessIntervals(access2));

% Step 8: Customize Access Visualization
access1.LineWidth = 3; 
access1.LineColor = [0, 1, 0]; % Green for Chennai

access2.LineWidth = 3; 
access2.LineColor = [1, 0, 0]; % Red for New Delhi

% Step 9: Add Ground Tracks and Coverage Cones
groundTrack(sat, 'LeadTime', 3600, 'TrailTime', 3600); % Show satellite ground track


% Step 10: Run the Simulation
play(sc); % Start simulation
disp('Scenario simulation started.');

%Introducing rain attenuation
% Inputs
rainRate = 10; % Rain rate in mm/hr
elevationAngle = 45; % Satellite elevation angle in degrees

%Chennai ground station
% Frequency and Power
frequency = 2.4e9; % Frequency in Hz (2.4 GHz)
transmitterPower = 10; % Transmitter power in dBW
transmitterGain = 30; % Transmitter antenna gain in dBi
receiverGain = 25; % Receiver antenna gain in dBi
systemNoiseFigure = 3; % System noise figure in dB

% Constants for Rain Attenuation (ITU-R P.618)
specificAttenuation = 0.1 * (frequency / 1e9)^0.8 * (rainRate)^0.6; % Approximation
effectivePathLength = 2 / sin(deg2rad(elevationAngle)); % Approximate slant path

% Calculate Rain Attenuation
rainAttenuation = specificAttenuation * effectivePathLength; % Attenuation in dB

disp(['Rain Attenuation: ', num2str(rainAttenuation), ' dB']);

% Free-Space Path Loss (FSPL)
distance = 780e3; % Example satellite-to-ground distance (in meters)
c = 3e8; % Speed of light (m/s)
fspl = 20 * log10(4 * pi * distance * frequency / c); % FSPL in dB

% Atmospheric Loss
atmosphericLoss = 2; % Atmospheric loss in dB (example value)

totalLosses = fspl + atmosphericLoss + rainAttenuation; % Total losses in dB

rss = transmitterPower + transmitterGain + receiverGain - totalLosses - systemNoiseFigure;
disp(['Received Signal Strength (RSS): ', num2str(rss), ' dB']);

requiredCNR = 10; % Required Carrier-to-Noise Ratio (CNR) in dB
linkMargin = rss - requiredCNR; % Link margin in dB
disp(['Link Margin: ', num2str(linkMargin), ' dB']);

components = categorical({'Transmitter Power', 'Transmitter Gain', 'FSPL', 'Atmospheric Loss', 'Rain Loss', 'Receiver Gain', 'System Noise'});
values = [transmitterPower, transmitterGain, -fspl, -atmosphericLoss, -rainAttenuation, receiverGain, -systemNoiseFigure];

bar(components, values);
title('Satellite Link Budget');
ylabel('dB');
grid on;


% Adding potential mobile ground stations around Chennai
mobileGS1 = groundStation(sc, 11.9139,79.8145 , 'Name', 'Mobile GS Option 1'); %Puducherry  Southeast
mobileGS2 = groundStation(sc, 11.9398, 79.4932, 'Name', 'Mobile GS Option 2');  %Villupuram  Northwest
mobileGS3 = groundStation(sc, 13.0308, 77.5651, 'Name', 'Mobile GS Option 3');  %RIT
disp('Mobile ground stations added.');

% Calculate Access Times for Mobile Ground Stations
accessMobile1 = access(sat, mobileGS1);
accessMobile2 = access(sat, mobileGS2);
accessMobile3 = access(sat, mobileGS3);

% Display Access Intervals
disp('Access Times for Mobile GS Option 1 (Start-End Intervals):');
disp(accessIntervals(accessMobile1));

disp('Access Times for Mobile GS Option 2 (Start-End Intervals):');
disp(accessIntervals(accessMobile2));

disp('Access Times for Mobile GS Option 3 (Start-End Intervals):');
disp(accessIntervals(accessMobile3));

accessMobile1.LineWidth = 3; 
accessMobile1.LineColor = [0, 0, 0]; %black color

accessMobile2.LineWidth = 3; 
accessMobile2.LineColor = [0.6, 0.3, 0.1]; %brown color

accessMobile3.LineWidth = 3; 
accessMobile3.LineColor = [0, 0, 0.5];  %dark blue

% Declare lists for each parameter
transmitterPower = [30, 25, 90]; % Transmitter power for GS1, GS2, GS3 in dBm
transmitterGain = [20, 18, 50]; % Transmitter gain for GS1, GS2, GS3 in dB
receiverGain = [15, 14, 45]; % Receiver gain for GS1, GS2, GS3 in dB
frequency = [10e9, 12e9, 9e9]; % Frequency for GS1, GS2, GS3 in Hz

% Other parameters (e.g., rain rate, elevation angle, etc.)
rainRate = [7, 10, 5]; % Rain rate for GS1, GS2, GS3 in mm/hr
elevationAngle = [50, 45, 55]; % Elevation angle for GS1, GS2, GS3 in degrees
systemNoiseFigure = 5; % System noise figure (in dB)

% Pre-allocate arrays
numGroundStations = length(transmitterPower); % Number of ground stations
rss = zeros(1, numGroundStations); % Pre-allocate RSS array
totalLosses = zeros(1, numGroundStations); % Pre-allocate Total Losses array
linkMargin = zeros(1, numGroundStations); % Pre-allocate Link Margin array

% Loop through each ground station
for gs = 1:numGroundStations
    % Extract the values for the current ground station (GS)
    power = transmitterPower(gs);
    gainTx = transmitterGain(gs);
    gainRx = receiverGain(gs);
    freq = frequency(gs);
    rain = rainRate(gs);
    elevation = elevationAngle(gs);
    
    % Calculate the effective path length
    effectivePathLength = 2 / sin(deg2rad(elevation)); 

    % Calculate specific attenuation based on frequency and rain rate
    specificAttenuation = 0.1 * (freq / 1e9)^0.8 * rain^0.6; % dB/km

    % Calculate rain attenuation
    rainAttenuation = specificAttenuation * effectivePathLength; % Attenuation in dB

    % Total losses for this station
    fspl = 100; % Free space path loss (adjust if needed)
    atmosphericLoss = 5; % Atmospheric loss (adjust if needed)
    totalLosses(gs) = fspl + atmosphericLoss + rainAttenuation;

    % Received Signal Strength (RSS)
    rss(gs) = power + gainTx + gainRx - totalLosses(gs) - systemNoiseFigure;

    % Required CNR (adjust based on desired link quality)
    requiredCNR = 10; % dB (example, adjust as needed)

    % Link margin calculation
    linkMargin(gs) = rss(gs) - requiredCNR;
end

% Display the link margins for each ground station
for gs = 1:numGroundStations
    disp(['Link Margin for GS', num2str(gs), ': ', num2str(linkMargin(gs)), ' dB']);
end

% Create table to display results
resultsTable = table(groundStationNames', transmitterPower', transmitterGain', ...
    receiverGain', frequency', rainRate', elevationAngle', totalLosses', rss', ...
    linkMargin', ...
    'VariableNames', {'GroundStation', 'TransmitterPower_dBm', 'TransmitterGain_dB', ...
    'ReceiverGain_dB', 'Frequency_Hz', 'RainRate_mmhr', 'ElevationAngle_deg', ...
    'TotalLosses_dB', 'RSS_dB', 'LinkMargin_dB'});

% Display the table
disp(resultsTable);