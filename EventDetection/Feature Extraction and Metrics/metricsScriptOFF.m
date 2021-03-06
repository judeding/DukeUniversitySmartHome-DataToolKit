%% GENERATE ACCURACY METRICS for OFF events based on OFF FEATURES
load test1Day.mat

%% Get events from aggregate data
[onEventsAgg, offEventsAgg, allEventsAgg] = GLR_EventDetection(agg, 80,15,10,-20,1,0,4);

%% Get events from submetered data
[onEventsRef, offEventsRef, allEventsRef] = GLR_EventDetection(refrigerator, 80,15,10,-20,1,0,4);
[onEventsHot, offEventsHot, allEventsHot] = GLR_EventDetection(hotbox, 80,15,10,-20,1,0,4);
%[onEventsH10P, offEventsH10P, allEventsH10P] = GLR_EventDetection(h10p, 80,15,10,-20,1,0,4);
[onEventsHVAC1, offEventsHVAC1, allEventsHVAC1] = GLR_EventDetection(HVAC1, 80,15,10,-20,1,0,4);
[onEventsHVAC2, offEventsHVAC2, allEventsHVAC2] = GLR_EventDetection(HVAC2, 80,15,10,-20,1,0,4);

%% Preliminary visual comparisons of TRUE ON values vs Detected ON Events
figure(3)
hold on
subplot(2,1,1)
plot(offEventsAgg,'b')
title('All Aggregate OFF events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(offEventsRef,'r')
title('Submetered Refrigerator OFF events detected')
xlabel('Time of day (s)')
hold off

figure(4)
hold on
subplot(2,1,1)
plot(offEventsAgg,'b')
title('Aggregate OFF events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(offEventsHot,'r')
xlabel('Time of day (s)')
title('Submetered Hot Box OFF events detected')
hold off

% H10p removed from top appliances
% figure(5)
% hold on
% subplot(2,1,1)
% plot(onEventsAgg,'b')
% title('Aggregate ON events detected')
% xlabel('Time of day (s)')
% subplot(2,1,2)
% plot(onEventsH10P,'r')
% xlabel('Time of day (s)')
% title('Submetered H10P ON events detected')
% hold off


figure(6)
hold on
subplot(2,1,1)
plot(offEventsAgg,'b')
title('Aggregate OFF events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(offEventsHVAC1,'r')
xlabel('Time of day (s)')
title('Submetered HVAC1 OFF events detected')
hold off

figure(7)
hold on
subplot(2,1,1)
plot(offEventsAgg,'b')
title('Aggregate OFF events detected')
xlabel('Time of day (s)')
subplot(2,1,2)
plot(offEventsHVAC2,'r')
xlabel('Time of day (s)')
title('Submetered HVAC2 OFF events detected')
hold off

%% Create TRUTH vector of DCSID
offEventsAgg1 = [];
offEventsAgg1 = offEventsAgg;
for i = 31:length(offEventsAgg1)-30;
    if and(offEventsRef(1,i) == 1,offEventsAgg1(1,i) == 1);
        offEventsAgg1(1,i) = 2;
    elseif and(offEventsRef(1,i) == 1, not(isempty(find(offEventsAgg1(1,i-30:i+30),1))))
        offEventsAgg1(1,i-31 + find(offEventsAgg1(1,i-30:i+30),1)) = 2;
    elseif offEventsRef(1,i) == 1
        offEventsAgg1(1,i) = 2;
        offEventsAgg(1,i) = 1;
    end
end

figure(3)
subplot(2,1,1)
hold on
plot(offEventsAgg1,'b')
hold off

offEventsAgg2 = offEventsAgg1;
for i = 31:length(offEventsAgg2)-30;
    if and(offEventsHot(1,i) == 1,offEventsAgg2(1,i) == 1);
        offEventsAgg2(1,i) = 3;
    elseif and(offEventsHot(1,i) == 1, not(isempty(find(offEventsAgg2(1,i-30:i+30),1))))
        offEventsAgg2(1,i-31 + find(offEventsAgg2(1,i-30:i+30),1)) = 3;
    elseif offEventsHot(1,i) == 1
        offEventsAgg1(1,i) = 3;
        offEventsAgg(1,i) = 1;
    end
end

figure(4)
subplot(2,1,1)
hold on
plot(offEventsAgg2,'b')

% H10p removed from Top Appliances
% onEventsAgg3 = onEventsAgg2;
% for i = 31:length(onEventsAgg3)-30;
%     if and(onEventsH10P(1,i) == 1,onEventsAgg3(1,i) == 1);
%         onEventsAgg3(1,i) = 4;
%     elseif and(onEventsH10P(1,i) == 1, not(isempty(find(onEventsAgg3(1,i-30:i+30),1))))
%         onEventsAgg3(1,i-31 + find(onEventsAgg3(1,i-30:i+30),1)) = 4;
%     end
% end
% 
% figure(5)
% subplot(2,1,1)
% hold on
% plot(onEventsAgg3,'b')

offEventsHVAC1(1,39069) = 0; %incorrect off event detected

offEventsAgg4 = offEventsAgg2;
for i = 31:length(offEventsAgg4)-30;
    if and(offEventsHVAC1(1,i) == 1,offEventsAgg4(1,i) == 1);
        offEventsAgg4(1,i) = 4;
    elseif and(offEventsHVAC1(1,i) == 1, not(isempty(find(offEventsAgg4(1,i-30:i+30),1))))
        offEventsAgg4(1,i-31 + find(offEventsAgg4(1,i-30:i+30),1)) = 4;
    elseif offEventsHVAC1(1,i) == 1
        offEventsAgg1(1,i) = 4;
        offEventsAgg(1,i) = 1;
    end
end

figure(6)
subplot(2,1,1)
hold on
plot(offEventsAgg4,'b')

offEventsHVAC2(1,86358) = 1; %un-detected off event

offEventsAgg5 = offEventsAgg4;
for i = 31:length(offEventsAgg5)-30;
    if or(i == 27651, i == 83822)
        offEventsAgg5(1,i) = 5;
    elseif and(offEventsHVAC2(1,i) == 1,offEventsAgg5(1,i) == 1);
        offEventsAgg5(1,i) = 4;
    elseif and(offEventsHVAC2(1,i) == 1, not(isempty(find(offEventsAgg5(1,i-30:i+30),1))))
        offEventsAgg5(1,i-31 + find(offEventsAgg5(1,i-30:i+30),1)) = 4;
    elseif offEventsHVAC2(1,i) == 1
        offEventsAgg5(1,i) = 4;
        offEventsAgg(1,i) = 1;
    end
end

figure(7)
subplot(2,1,1)
hold on
plot(offEventsAgg5,'b')
subplot(2,1,2)
plot(offEventsAgg)

offEventsAgg(1,27651) = 1;
offEventsAgg(1,83822) = 1;

truthOffDCSID = offEventsAgg5;
% Remove non-events
truthOffDCSID(offEventsAgg == 0) = [];
% Make DCSID of "Others" 0, and "Ref" to "HVAC2" be 1 to 5
truthOffDCSID = truthOffDCSID - 1;

figure(8)
subplot(3,1,1)
plot(truthOffDCSID,'b')
hold on
title('True ON Appliance')
xlabel('OFF event index')
ylabel('Appliance Class No.')
hold off

%% Disaggregate and get dcsIDs
[ ONdcsID, OFFdcsID, TOTdcsID, MaxDistanceON, MaxDistanceOFF, MeanDistanceON, MeanDistanceOFF ] = FullDisaggregation( agg, onEventsAgg, offEventsAgg, allEventsAgg );

%% Create guess dcsID vector
guessOFFDCSID = OFFdcsID;
% Remove non-events
guessOFFDCSID(offEventsAgg == 0) = [];

%% Visualise results
figure(8)
subplot(3,1,2)
plot(guessOFFDCSID,'b')
hold on
title('ON Appliance Classification')
xlabel('ON event index')
hold off

difference = guessOFFDCSID - truthOffDCSID;
figure(8)
subplot(3,1,3)
plot(difference,'o')
hold on
plot(1:length(difference),zeros(length(difference)),'r')
title('Error in Classification')
ylabel('(Classified ID - Actual ID)')
xlabel('OFF event index')
hold off

figure(9)
subplot(3,1,1)
plot(truthOffDCSID)
hold on
title('True OFF Appliance')
xlabel('OFF event index')
ylabel('Appliance Class No.')
subplot(3,1,2)
plot(difference,'o')
hold on
plot(1:length(difference),zeros(length(difference)),'r')
title('Error in Classification')
xlabel('OFF event index')
ylabel('(Classified ID - Actual ID)')
subplot(3,1,3)
plot(MeanDistanceOFF)
title('Mean Euclidian Distance')
xlabel('OFF event index')
ylabel('Distance')

figure(11)
subplot(3,1,1)
plot(truthOffDCSID,'x')
hold on
title('True OFF Appliance')
xlabel('OFF event index')
ylabel('Appliance Class No.')
subplot(3,1,2)
plot(difference,'o')
hold on
plot(1:length(difference),zeros(length(difference)),'r')
title('Error in Classification')
ylabel('(Classified ID - Actual ID)')
xlabel('OFF event index')
subplot(3,1,3)
plot(MaxDistanceOFF)
title('Max Euclidian Distance')
xlabel('OFF event index')
ylabel('Distance')

%% Generate Confusion Matrix
truthOff = prtDataSetClass;
truthOff.targets = truthOffDCSID';
truthOff.data = truthOffDCSID';
guessOff = prtDataSetClass;
guessOff.targets = truthOffDCSID';
guessOff.data = guessOFFDCSID';
figure(13)
prtScoreConfusionMatrix(guessOff,truthOff)
axis square
