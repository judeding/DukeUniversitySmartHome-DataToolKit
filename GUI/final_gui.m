function SmartHomeGUI
%% Initialize Data:
clear; clc;

%% Global Variables
option = 'Refridgerator';
load('anomalyMatrix.mat','anomalyMatrix')
%% GUI setup
%  Create and then hide the GUI as it is being constructed.
f = figure('Visible','off','Position',[270,1000,1200,700]);


%  Construct the components.
hstart = uicontrol('Style','togglebutton','String','Start',...
    'Position',[200,330,200,50],...
    'Callback',{@start_Callback},'FontSize',20);
ha = axes('Units','Pixels','Position',[150,450,600,200],'Visible','off');
hb = axes('Units','Pixels','Position',[150, 50, 600, 200],'Visible','off');
hpanel = uipanel('Units','Pixels','Title','Appliance Status','FontSize',20,'FontWeight','Bold',...
    'Position',[150,290,300,140],'BackgroundColor','w','FontName','Helvetica');
hrf = uicontrol('Parent',hpanel,'Style','text','String','Refridgerator',...
    'Position',[60,95,120,20],'FontSize',18,'FontName','Helvetica','BackgroundColor','w');
hhb = uicontrol('Parent',hpanel,'Style','text','String','Hot Box',...
    'Position',[60,65,120,20],'FontSize',18,'FontName','Helvetica','BackgroundColor','w');
hhv1 = uicontrol('Parent',hpanel,'Style','text','String','HVAC 1',...
    'Position',[60,35,120,20],'FontSize',18,'FontName','Helvetica','BackgroundColor','w');
hhv2 = uicontrol('Parent',hpanel,'Style','text','String','HVAC 2',...
    'Position',[60,5,120,20],'FontSize',18,'FontName','Helvetica','BackgroundColor','w');
hpopup = uicontrol('Style','popupmenu',...
    'String',{'Refridgerator','Hot Box','HVAC System'},...
    'Position',[200,230,200,50],...
    'Callback',{@popup_menu_Callback},...
    'FontSize',20);
hanomaly = uicontrol('Style','text','String','Anomaly Log','FontSize',20,'FontWeight','Bold',...
    'Position',[800,630,300,50],'BackgroundColor','w','FontName','Helvetica');
hlist = uicontrol('Style','List','Position',[800,50,300,600]);



% Initialize the GUI.
% Change units to normalized so components resize automatically.
set([f,hstart,ha,hb,hpanel,hpopup,hanomaly,hlist],...
    'Units','normalized');
% Assign the GUI a name to appear in the window title.
set(f,'Name','Test GUI')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on' ,'Color','w');
align([ha,hpanel,hpopup,hstart],'distribute','none');

a = 'OFF'; b ='OFF'; c ='OFF'; d = 'OFF';

%% Dropdown menu
    function popup_menu_Callback(source,eventdata)
        % Determine the selected data set.
        str = get(source, 'String');
        val = get(source,'Value');
        switch str{val}
            case 'Refridgerator'
                option = 'Refridgerator';
            case 'Hot Box'
                option = 'Hot Box';
            case 'HVAC System'
                option = 'HVAC System';
        end
    end

%% initial plot
shData = importdata('../../DukeSmartHome_DataStreamDemo/dataCollectors/shData.csv');
aggregData = shData(:,2)+shData(:,3)-shData(:,4)-shData(:,5);
current_data = aggregData(end-299:end,1);  %% latest 300 seconds data
current_time = shData(end-299:end,1); %% latest 300 seconds time

event = importdata('../../DukeSmartHome_DataStreamDemo/EventDetection/eventData.csv');

greenEventTime = event(find(event(:,3)~=0&event(:,4)==1),1);
greenEventValue = zeros(length(greenEventTime),1);
for i = 1:length(greenEventTime)
    greenEventValue(i,1)=current_data(find(current_time==greenEventTime(i,1)));
end

redEventTime = event(find(event(:,3)~=0&event(:,4)==0),1);
redEventValue = zeros(length(greenEventTime),1);
for i = 1:length(redEventTime)
    redEventValue(i,1)=current_data(find(current_time==redEventTime(i,1)));
end

axes(ha);
plot_Aggreg = plot(linspace(numel(current_data),1,numel(current_data)), current_data,'w');
% hold on
% plot_greenEvent = plot(greenEventTime,greenEventValue,'go');
% plot_redEvent = plot(redEventTime,redEventValue,'ro');
% hold off
% halegend = legend([plot_greenEvent plot_redEvent],'ON Event','OFF Event');
title('Smart Home Aggregate Power Data','FontSize',20,'FontWeight','bold','FontName','Helvetica');
ylabel('Power (W)','FontSize',14);



current_actual = anomalyMatrix(:, 2);
current_predict = anomalyMatrix(:, 3);
axes(hb);
plot_predict=plot(anomalyMatrix(:,1),current_predict,'w-');
hold on
plot_actual=plot(anomalyMatrix(:,1), current_actual,'w-');
title('Predicted vs Actual Power Data of                          ','FontSize',20,'FontWeight','bold','FontName','Helvetica');
hold off


%% WHILE LOOP
    function start_Callback(hObject,eventdata,handles)

        if get(hObject,'Value')
            set(hObject,'String','Streaming');
        else set(hObject,'String','Start');
        end
        
        while(get(hObject, 'Value'))         
            %% Input Data
            shData = importdata('../../DukeSmartHome_DataStreamDemo/dataCollectors/shData.csv');
            aggregData = shData(:,2)+shData(:,3)-shData(:,4)-shData(:,5);
            current_data = aggregData(end-299:end,1);  %% latest 300 seconds data
            current_time = shData(end-299:end,1); %% latest 300 seconds time
            
            event = importdata('../../DukeSmartHome_DataStreamDemo/EventDetection/eventData.csv');
            
%             greenEventTime = event(find(event(:,3)~=0&event(:,4)==1),1);
%             greenEventValue = zeros(length(greenEventTime),1);
%             for i = 1:length(greenEventTime)
%                 greenEventValue(i,1)=current_data(find(current_time==greenEventTime(i,1)));
%             end
%             
%             redEventTime = event(find(event(:,3)~=0&event(:,4)==0),1);
%             redEventValue = zeros(length(greenEventTime),1);
%             for i = 1:length(redEventTime)
%                 redEventValue(i,1)=current_data(find(current_time==redEventTime(i,1)));
%             end
            
            disagData = importdata('../../DukeSmartHome_DataStreamDemo/EventDetection/DisaggregatedPower.csv');
            
            if disagData(end, 2) == 0 %refridgerator
                a = 'OFF'; rfcolor = 'r';
            else
                a = 'ON'; rfcolor = 'g';
            end
            
            if disagData(end, 3) == 0 %hotbox
                b = 'OFF'; hbcolor = 'r';
            else
                b = 'ON'; hbcolor = 'g';
            end
            
            if disagData(end, 4) == 0 %hvac1
                c = 'OFF'; hv1color = 'r';
            else
                c = 'ON'; hv1color = 'g';
            end
            
            if disagData(end, 5) == 0 %hvac2
                d = 'OFF'; hv2color = 'r';
            else
                d = 'ON'; hv2color = 'g';
            end
            
            
            appStatus={a,b,c,d};  % data input
            hrfs = uicontrol('Parent',hpanel,'Style','text','String',appStatus(1),...
                'Position',[180,95,60,20],'FontSize',18,'FontName','Helvetica','BackgroundColor',rfcolor);
            hhbs = uicontrol('Parent',hpanel,'Style','text','String',appStatus(2),...
                'Position',[180,65,60,20],'FontSize',18,'FontName','Helvetica','BackgroundColor',hbcolor);
            hhv1s = uicontrol('Parent',hpanel,'Style','text','String',appStatus(3),...
                'Position',[180,35,60,20],'FontSize',18,'FontName','Helvetica','BackgroundColor',hv1color);
            hhv2s = uicontrol('Parent',hpanel,'Style','text','String',appStatus(4),...
                'Position',[180,5,60,20],'FontSize',18,'FontName','Helvetica','BackgroundColor',hv2color);

            
            %% Live plot
            axes(ha);
            set(plot_Aggreg, 'YData', current_data,'Color','b');
            set(gca,'FontSize',12,'XTick',[0,100,200,300],...
                'XTickLabel',{datestr(current_time(1,1)/86400+719529,13),...
                datestr(current_time(100,1)/86400+719529,13),...
                datestr(current_time(200,1)/86400+719529,13),...
                datestr(current_time(300,1)/86400+719529,13)});
%           set(halegend,'show')
            drawnow
            
%             hold on
%             plot_greenEvent = plot(greenEventTime,greenEventValue,'go')
%             plot_redEvent = plot(redEventTime,redEventValue,'ro')
%             hold off


%             xlabel(datestr(current(200,1)/86400+719529,1),'FontSize',14);
            %         set(gca,'FontSize',12,'XTick',[0,200],...
            %             'XTickLabel',{datestr(latest_time(1,1)/86400+719529,13),...
            %             datestr(latest_time(200,1)/86400+719529,13)});
            
            %         while(1)
            %             axes(ha);
            %             axis([0, 200, 0 , 8000]);
            % %             xlabel(datestr(latest_time(200,1)/86400+719529,1),'FontSize',14);
            %             ylabel('Power (W)','FontSize',14);
            %             set(gca,'FontSize',12,'XTick',[0,200],...
            %                 'XTickLabel',{datestr(latest_time(1,1)/86400+719529,13),...
            %                 datestr(latest_time(200,1)/86400+719529,13)});
            %             counter = counter + 1;
            %             if counter == 20
            %                 pause(0.01);
            %             else
            %                 pause(0.5);
            %             end
            %             drawnow;
            %         end
            
            
            
            %% Prediction Plot
            axes(hb);
            % Set current data to the selected data set.
            switch option
                case 'Refridgerator'
                    current_actual = anomalyMatrix(:, 2);
                    current_predict = anomalyMatrix(:, 3);
                case 'Hot Box'
                    current_actual = anomalyMatrix(:, 4);
                    current_predict = anomalyMatrix(:, 5);
                case 'HVAC System'
                    current_actual = anomalyMatrix(:, 6);
                    current_predict = anomalyMatrix(:, 7);
            end
            set(plot_predict,'YData',current_predict,'Color','r');
            set(plot_actual,'YData',current_actual,'Color','k');
%             set(gca,'FontSize',12,'XTick',[0,100,200,300],...
%                 'XTickLabel',{datestr(anomalyMatrix(1,1)/86400+719529,13),...
%                 datestr(anomalyMatrix(end,1)/86400+719529,13)});
% legend(hb,'show');
%             drawnow
        end
    end
end