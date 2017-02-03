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
%  Currently the default trial function is at -Inf so as long as this
%  module is between -Inf and Inf it should be fine...
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
    temp = properties('a2duino.adcSchedule');
    settings.a2duino.adc = cell2struct(cell(size(temp)),temp,1);
    settings.a2duino.adc.channelMapping = 'a2duino.adc.data';
    settings.a2duino.events.channelMapping = 'a2duino.adc.events';
else
    
    %  Execute the state dependent components
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen
            
            %  Create the a2duino object with the specified ADC parameters
            fprintf('****************************************************************\n');
            fprintf('Create a2duino object and initialize connection to Arduino.\n');
            inputArgs = [fieldnames(p.trial.a2duino.adc) struct2cell(p.trial.a2duino.adc)]';
            p.functionHandles.a2duinoObj = a2duino('verbose',inputArgs{:});
            fprintf('\n');
            p.functionHandles.a2duinoObj.setAdcSchedule;
            fprintf('ADC Schedule (read back from Arduino):\n');
            disp(p.functionHandles.a2duinoObj.getAdcSchedule);
            fprintf('****************************************************************\n');
            
            %  Get the channel mappings
            p = a2duino.setAdcChannelMappings(p);
            p = a2duino.setEventsChannelMapping(p);
            
            %  Capture time for both devices
            p.trial.a2duino.startA2duinoTime = p.functionHandles.a2duinoObj.getTicksSinceStart;
            p.trial.a2duino.startPldapsTime = GetSecs;
            
            %  Start the schedules
            p.functionHandles.a2duinoObj.startAdcSchedule;
            p.functionHandles.a2duinoObj.startEventListener0;
            
            
        case p.trial.pldaps.trialStates.experimentCleanUp
            
            %  stop the schedules
            p.functionHandles.a2duinoObj.stopAdcSchedule;
            p.functionHandles.a2duinoObj.stopEventListener0;
            
            %  Capture time for both devices
            p.trial.a2duino.adc.stopA2duinoTime = p.functionHandles.a2duinoObj.getTicksSinceStart;
            p.trial.a2duino.adc.stopPldapsTime = GetSecs;
            
            %  Close connection
            p.functionHandles.a2duinoObj.close;
            
        case p.trial.pldaps.trialStates.trialSetup
            
            %  The first frameUpdate will be reading the return buffer so
            %  load up the command queue here.
            p.functionHandles.a2duinoObj.addCommand('getAdcBuffer');
            p.functionHandles.a2duinoObj.addCommand('getEventListener0');
            %p.functionHandles.a2duinoObj.addCommand('getAdcVoltages');
            p.functionHandles.a2duinoObj.sendCommands;
            
        case p.trial.pldaps.trialStates.trialCleanUpandSave
            
            %  Retrieve data buffer from last frame cycle
            p.functionHandles.a2duinoObj.retrieveOutput;
            %  Trim out unused data array
            
        case p.trial.pldaps.trialStates.frameUpdate
            
            %  Retrieve data buffer from last frame cycle
            p.functionHandles.a2duinoObj.retrieveOutput;
            
            %  Insert data into a2duino.adc.data
            p = a2duino.getAdcData(p);
            p = a2duino.getEventsData(p);
            
            %  Queue commands for the next frame cycle
            p.functionHandles.a2duinoObj.addCommand('getAdcBuffer');
            p.functionHandles.a2duinoObj.addCommand('getEventListener0');
            %p.functionHandles.a2duinoObj.addCommand('getAdcVoltages');
            p.functionHandles.a2duinoObj.sendCommands;            
    end
end
end