function trainingFeatureExtraction(trainingDataSet, applianceLabel, decisionIDs, parameters)

    dataLength = length(trainingDataSet);
    
    % Event Detection
    a = parameters(1);
    b = parameters(2);
    c = parameters(3);
    d = parameters(4);
    e = parameters(5);
    f = parameters(6);
    g = parameters(7);
    [on, off, events] = GLR_EventDetection(trainingDataSet, a, b, c, d, e, f, g);

    trainingWindow = 10;
    onFilePath = cat(2, applianceLabel, 'OnFeatures');
    offFilePath = cat(2, applianceLabel, 'OffFeatures');
    
    % Load features if exist
    onExist = 0; offExist = 0;
    if exist(onFilePath, 'file')
        onFeatures = load(onFilePath);
        onFeatureSet = onFeatures.featureSet;
        onExist = 1;
    end    
    if exist(offFilePath, 'file')
        offFeatures = load(offFilePath);
        offFeatureSet = offFeatures.featureSet;
        offExist = 1;
    end
    
    % Collect Features
    for i = 1:dataLength
        if on(i) == 1
            eventWindow = trainingDataSet(i-trainingWindow:i+trainingWindow)';
            eventSlope = polyfit(1:21,eventWindow,1);
            eventDelta = max(eventWindow) - min(eventWindow);
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta],decisionIDs(1));
            if onExist == 1
                onFeatureSet = catObservations(onFeatureSet, eventFeatures);
            else 
                onFeatureSet = eventFeatures;
                onExist = 1;
            end
        end
        if off(i) == 1
            eventWindow = trainingDataSet(i-trainingWindow:i+trainingWindow)';
            eventSlope = polyfit(1:21,eventWindow,1);
            eventDelta = max(eventWindow) - min(eventWindow);
            eventFeatures = prtDataSetClass([eventSlope(1) eventDelta],decisionIDs(2));
            if offExist == 1        
                offFeatureSet = catObservations(offFeatureSet, eventFeatures);
            else
                offFeatureSet = eventFeatures;
                offExist = 1;
            end
        end
    end
    
    % Resave features
    save(onFilePath, 'onFeatureSet');
    save(offFilePath, 'offFeatureSet');

end