function liveDisaggregation()
% Input: CSV file with Live Smart home data
% Output: CSV file with timestamp of event, event labels (ON/OFF),
% appliance ID, Delta Power

% Create an output CSV file in the home directory
format long
M = zeros(1,4);
csvwrite('eventData.csv', M);

% Create figures to call later 
% figure1 = figure('CloseRequestFcn',@figureCloseReq);
% figure1.WindowStyle = 'docked';
% drawnow;

% Load ON and OFF features
load ..\EventDetection\OnFeatures\onFeatures.mat
fullOnSet = onFeatures;
load ..\EventDetection\OffFeatures\offFeatures.mat
fullOffSet = offFeatures;

% Normalise feature space
maxONSlope = max(fullOnSet.data(:,1));
maxONDelta = max(fullOnSet.data(:,2));
fullOnSet.data(:,1) = fullOnSet.data(:,1)/maxONSlope;
fullOnSet.data(:,2) = fullOnSet.data(:,2)/maxONDelta;

minOFFSlope = min(fullOffSet.data(:,1));
maxOFFDelta = max(fullOffSet.data(:,2));
fullOffSet.data(:,1) = fullOffSet.data(:,1)/minOFFSlope;
fullOffSet.data(:,2) = fullOffSet.data(:,2)/maxOFFDelta;

%Train KNN Classifier
knnClassifierOn = prtClassKnn;
knnClassifierOn.k = 5;
knnClassifierOn = knnClassifierOn.train(fullOnSet);

knnClassifierOff = prtClassKnn;
knnClassifierOff.k = 5;
knnClassifierOff = knnClassifierOff.train(fullOffSet);

%Pmax = 2;
%dcsID = 0;

% Creating fixed variables: myOn, myOff, myEvents
liveData = importdata('../dataCollectors/shData.csv');
aggregatePower = sum(liveData(:,2:3),2) - sum(liveData(:,4:5),2);

if(size(aggregatePower, 1) == 1 && size(aggregatePower, 2) ~= 1); % Making sure data is in right format
    aggregatePower = aggregatePower';
end

onIndicator = zeros(size(aggregatePower));
offIndicator = zeros(size(aggregatePower));
eventIndicator = zeros(size(aggregatePower));

% Indicator of 1st loop:
indicator = 0;

% Create a stop loop:
FS = stoploop({'Click me to:', 'Exit out of the Loop'});

% Create vector storing Appliance IDs, Event Type and the Timestamp for every event
appID = [];
eventType = [];
eventTimeStamp = [];
d = 1;
% Main Loop: 
while (~FS.Stop())
    liveData = importdata('../dataCollectors/shData.csv');
    unixTime = liveData(:,1);
    aggregatePower = sum(liveData(:,2:3),2) - sum(liveData(:,4:5),2);
    dataLength = length(aggregatePower);
    
    % Make sure the indicator vectors are of the correct length
    if (length(onIndicator) < dataLength);
        % Matlab code automatically fills in zeros in between
        onIndicator(dataLength) = 0; 
        offIndicator(dataLength) = 0;
        eventIndicator(dataLength) = 0;
    elseif (length(onIndicator) > dataLength);
        delta = length(onIndicator) - dataLength;
        onIndicator(1:delta) = []; 
        offIndicator(1:delta) = [];
        eventIndicator(1:delta) = [];
    end
    
    % Find the last points where ON and OFF events occured
    maxOnIndex = find(onIndicator == 1, 1, 'last');
    maxOffInd = find(offIndicator == 1, 1, 'last');
    
    % Concatenate the index for On and Off
    maxIndexVector = max([maxOnIndex maxOffInd]);
    % Write 0 if the index vector is empty
    if(isempty(maxIndexVector));
        maxIndexVector = 0;
    end
    
    % Make sure GLR event detection only runs from that last point an event
    % was detected
    if(indicator == 0)
        [onDummy, offDummy, eventsDummy] = GLR_EventDetection(aggregatePower,40,15,10,-20,0,1,4);
        on = onDummy;
        off = offDummy;
        events = eventsDummy;
        indicator = 1;
    else
        dataSampleLength = dataLength - maxIndexVector;
        prev_On = onIndicator(1:maxIndexVector);
        prev_Off = offIndicator(1:maxIndexVector);
        prev_Events = eventIndicator(1:maxIndexVector);
        
        [onDummy, offDummy, eventsDummy] = GLR_EventDetection(aggregatePower((maxIndexVector+1):dataLength),40,15,10,-20,0,1,4);
        
        on = [prev_On' onDummy];
        off = [prev_Off' offDummy];
        events = [prev_Events' eventsDummy];
        
        onDummy = [zeros(1, maxIndexVector) onDummy];
        offDummy = [zeros(1, maxIndexVector) offDummy];
        eventsDummy = [zeros(1, maxIndexVector) eventsDummy];
    end
    
    windowLength = 30;
    
    GLRMax = find(events == 1, 1, 'last');
    if(isempty(GLRMax))
        GLRMax = 0;
    end
    
    % This section refreshes the event detection properly, ignoring
    % irrelevant points:
    if(GLRMax > maxIndexVector)
        on(1:maxOnIndex) = 0;
        off(1:maxOffInd) = 0;
        
        onIndicator = onIndicator + on';
        offIndicator = offIndicator + off';
    end
    
    % Plotting
    %clf; % Clear Relevant Figures
    % Call Figure 1 and update without stealing focus
%     set(0,'CurrentFigure',figure1)
%     hold on;
%     plot(aggregatePower);
%     plotOn = onIndicator;
%     plotOff = offIndicator;
%     plotOn(plotOn == 0) = NaN;
%     plotOff(plotOff == 0) = NaN;
%     plot(plotOn.*aggregatePower, 'ro', 'linewidth', 2);
%     plot(plotOff.*aggregatePower, 'go', 'linewidth', 2);
%     title('Events detected');
%     xlabel('Time Series Values (s)');
%     ylabel('Power Values (W)');
%     legend('Data', 'On Events', 'Off Events');
%     hold off;

    % Disaggregation
    for i = (1 + windowLength):(dataLength-windowLength);
        
        if onDummy(i) == 1
            eventWindow = aggregatePower(i-windowLength:i+windowLength)';
            eventSlope = polyfit(1:length(eventWindow),eventWindow,1)/maxONSlope;
            eventDelta = (max(eventWindow) - min(eventWindow))/maxONDelta;
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
            knnClassOut = knnClassifierOn.run(eventFeatures);
            [~, dcsID] = max(knnClassOut.data);
            
            filterFrom = fullOnSet;
            filterFeatures = filterFrom.retainClasses(dcsID);
            
            distance = prtDistanceEuclidean(eventFeatures,filterFeatures);
            maxDistanceON = max(distance);
            meanDistanceON = mean(distance);
            
            if and(~or(dcsID == 3, dcsID == 4), meanDistanceON > 0.005);
                dcsID = dcsID; % Classifies the ith detected on-event as OTHER
            end
            
            fprintf('%1.0f is the appliance ON at time %5.3f \n', dcsID, i);
            
            appID = [appID dcsID];
            eventTimeStamp = [eventTimeStamp unixTime(i)];
            eventType = [eventType 1];
            
            if and(d ~= unixTime(i), d < unixTime(i))
                M = [unixTime(i) dcsID eventDelta*maxONDelta 1];
                dlmwrite('eventData.csv',M,'-append','newline','pc','precision',11);
            end
            
            d = unixTime(i);
            
            % The below code works while live:
            %plotID = text(i,aggregatePower(i),num2str(dcsID),'Color','red','FontSize',20,'FontSmoothing','on','Margin',8);
            
        elseif offDummy(i) == 1
            eventWindow = aggregatePower(i-windowLength:i+windowLength)';
            eventSlope = polyfit(1:length(eventWindow),eventWindow,1)/minOFFSlope;
            eventDelta = (max(eventWindow) - min(eventWindow))/maxOFFDelta;
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
            knnClassOut = knnClassifierOff.run(eventFeatures);
            [~, dcsID] = max(knnClassOut.data);
            
            filterFrom = fullOffSet;
            filterFeatures = filterFrom.retainClasses(dcsID);
            
            distance = prtDistanceEuclidean(eventFeatures,filterFeatures);
            maxDistanceOFF = max(distance);
            meanDistanceOFF = mean(distance);
            
            % Printing Out Appliance Classification
            if and(~or(dcsID == 3, dcsID == 4),meanDistanceOFF > 0.005);
                dcsID = 0; % Classifies the ith detected on-event as OTHER
            end
            
            fprintf('%1.0f is the appliance OFF at time %5.3f \n', dcsID, i);
            
            appID = [appID dcsID];
            eventTimeStamp = [eventTimeStamp unixTime(i)];
            eventType = [eventType 0];
            
            if and(d~= unixTime(i), d < unixTime(i))
                M = [unixTime(i) dcsID eventDelta*maxOFFDelta 0];
                dlmwrite('eventData.csv',M,'-append','newline','pc','precision',11);
            end
            d = unixTime(i);
            
            % The below code works while live:
            %plotID = text(i,aggregatePower(i),num2str(dcsID),'Color','green','FontSize',20,'FontSmoothing','on','Margin',8);
            
        elseif and(d~= unixTime(i), d < unixTime(i))
            M = [unixTime(i) 0 0 0];
            dlmwrite('eventData.csv',M,'-append','newline','pc','precision',11);
            d = unixTime(i);
        end 
    end
    % 1 second pause
     pause(1)
end
FS.Clear();
clear FS;
%appLabels
end