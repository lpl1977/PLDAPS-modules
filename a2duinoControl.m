function settings = a2duinoControl(p,state)
%a2duinoControl state dependent steps for initializing and acquiring data
%with a2duino
%
%  settings = a2duinoControl
%
%  This is a PLDAPS module for the openreception branch.  This module
%  controls initialization and data acquisition for a2duino.
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  NB:  generally speaking we will want to capture data before calling
%  anything that might use the data, for example the analog stick.
%  Currently the default trial function is at NaN (always last) so as long
%  as this module is between -Inf and Inf we should be fine...
%
%  Lee Lovejoy
%  January 2017
%  ll2833@columbia.edu

if(nargin==0)
    
    %  Generate the settings structure for the module
    stateFunction.order = -Inf;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = filename;
    requestedStates = 'all';
    moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;
    
    %  Settings structure for a2duino
    settings.a2duino.adc = a2duino.getAdcScheduleStruct;
    settings.a2duino.adc.channelMapping = 'a2duino.adc.data';
    settings.a2duino.events.channelMapping = 'a2duino.adc.events';
    settings.a2duino.useForReward = true;
    settings.a2duino.rewardType = 'fluid';
else
    
    %  Execute the state dependent components
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Create the a2duino object with the specified ADC parameters
            fprintf('****************************************************************\n');
            fprintf('Create a2duino object and initialize connection to Arduino.\n');
            inputArgs = [fieldnames(p.trial.a2duino.adc) struct2cell(p.trial.a2duino.adc)]';
            p.functionHandles.a2duinoObj = a2duino(inputArgs{:});
            p.functionHandles.a2duinoObj.writeAdcSchedule;
            fprintf('Connection settings:\n');
            p.functionHandles.a2duinoObj.showConnectionSettings;
            fprintf('\n');
            fprintf('Device settings:\n');
            p.functionHandles.a2duinoObj.showDeviceSettings;
            fprintf('\n');
            fprintf('ADC Schedule:\n');
            p.functionHandles.a2duinoObj.showAdcSchedule;
            fprintf('\n');
            
            %  Get the channel mappings and start the schedules
            p = a2duino.setAdcChannelMapping(p);
            p.functionHandles.a2duinoObj.startAdcSchedule;
            fprintf('Started ADC schedule\n');
            p = a2duino.setEventsChannelMapping(p);
            p.functionHandles.a2duinoObj.startEventListener;
            fprintf('Started event listener\n');
            fprintf('****************************************************************\n');
            
            %  Capture time for both devices
            p.trial.a2duino.startA2duinoTime = p.functionHandles.a2duinoObj.readTicksSinceStart;
            p.trial.a2duino.startPldapsTime = GetSecs;
            
        case p.trial.pldaps.trialStates.experimentCleanUp
            
            %  stop the schedules
            p.functionHandles.a2duinoObj.stopAdcSchedule;
            p.functionHandles.a2duinoObj.stopEventListener;
            
            %  Capture time for both devices
            p.trial.a2duino.adc.stopA2duinoTime = p.functionHandles.a2duinoObj.readTicksSinceStart;
            p.trial.a2duino.adc.stopPldapsTime = GetSecs;
            
            %  Close connection
            p.functionHandles.a2duinoObj.close;
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  The first frameUpdate will be reading the return buffer so
            %  load up the command queue here.
            p.functionHandles.a2duinoObj.addCommand('readAdcBuffer');
            p.functionHandles.a2duinoObj.addCommand('readEventListener');
            if(p.trial.a2duino.useForReward && p.functionHandles.a2duinoObj.rewardInProgress)
                switch p.trial.a2duino.rewardType
                    case 'pellet'
                        p.functionHandles.a2duinoObj.addCommand('readPelletReleaseStatus');
                    case 'fluid'
                        p.functionHandles.a2duinoObj.addCommand('readFluidRewardStatus');
                end
            end
            
            %  Send the command queue
            p.functionHandles.a2duinoObj.sendCommands;
            
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            
            %  Retrieve data buffer from last frame cycle
            p.functionHandles.a2duinoObj.retrieveOutput;
            
        case p.trial.pldaps.trialStates.frameUpdate
            
            %  Retrieve data buffer from last frame cycle
            p.functionHandles.a2duinoObj.retrieveOutput;
            
            %  Insert data into a2duino.adc.data
            p = a2duino.getAdcData(p);
            p = a2duino.getEventsData(p);
            
            %  Queue commands for the next frame cycle
            p.functionHandles.a2duinoObj.addCommand('readAdcBuffer');
            p.functionHandles.a2duinoObj.addCommand('readEventListener');
            if(p.trial.a2duino.useForReward && p.functionHandles.a2duinoObj.rewardInProgress)
                switch p.trial.a2duino.rewardType
                    case 'pellet'
                        p.functionHandles.a2duinoObj.addCommand('readPelletReleaseStatus');
                    case 'fluid'
                        p.functionHandles.a2duinoObj.addCommand('readFluidRewardStatus');
                end
            end
            
            %  Send the command queue
            p.functionHandles.a2duinoObj.sendCommands;
    end
end
end