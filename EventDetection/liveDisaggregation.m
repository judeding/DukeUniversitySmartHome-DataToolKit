function liveDisaggregation()

     onFiles = prtUtilSubDir('OnFeatures','*.mat');
     fullOnSet = prtDataSetClass();
     for iFile = 1:length(onFiles)
         %cFile = onFiles{iFile};
         load(onFiles{iFile});
         fullOnSet = catObservations(fullOnSet, onFeatureSet);
         plot(onFeatureSet)
     end
%     
     offFiles = prtUtilSubDir('OffFeatures','*.mat');
     fullOffSet = prtDataSetClass();
     for iFile = 1:length(offFiles)
         %cFile = offFiles{iFile};
         load(offFiles{iFile});
         fullOffSet = catObservations(fullOffSet, offFeatureSet);
     end
%
     knnClassifierOn = prtClassKnn;
     knnClassifierOn.k = 5;
     knnClassifierOn = knnClassifierOn.train(fullOnSet);

     knnClassifierOff = prtClassKnn;
     knnClassifierOff.k = 5;
     knnClassifierOff = knnClassifierOff.train(fullOffSet);
     
    while 1
        liveData = csvread('../dataCollectors/shData.csv');
        % endRow = length(liveData(:,1));

        % Original data
        %figure(1);
        %plot(times, aggregatePower);

        % Keep window (for plotting) at 300seconds (can be changed to any value
        % upto 1800).
        % window = 300;
%        times = liveData(endRow-window:endRow,1);
        aggregatePower = sum(liveData(:,2:3),2);
        dataLength = length(aggregatePower);
        % Plot
        % refresh
%        figure(1);
%        plot(times,aggregatePower);

        % Event Detection
        [on, off, events] = GLR_EventDetection(aggregatePower,40,30,25,-10,3,0,6);
        trainingWindow = 10;
        % Disaggregation
         for i = (1 + trainingWindow):(dataLength-trainingWindow)
             if on(i) == 1
                 eventWindow = aggregatePower(i-trainingWindow:i+trainingWindow)';
                 eventSlope = polyfit(1:21,eventWindow,1);
                 eventDelta = max(eventWindow) - min(eventWindow);
                 eventFeatures = prtDataSetClass([eventSlope(1) eventDelta]);
                 eventFeatures = prtDataSetClass(eventWindow);
                 
                 knnClassOut = knnClassifierOn.run(eventFeatures);
                 
                 [~, dcsID] = max(knnClassOut.data);
                 
                 
             end
             if off(i) == 1
                 eventWindow = aggregatePower(i-trainingWindow:i+trainingWindow)';
                 eventFeatures = prtDataSetClass(eventWindow);
                 
                 knnClassOut = knnClassifierOff.run(eventFeatures);
                 
                 [~, dcsID] = max(knnClassOut.data);
             end
         end
        dcsID
        % 1 second pause
        pause(.1)
    end
end