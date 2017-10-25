function settings = analogStickControl(p,state)
%analogStickControl state dependent steps for initializing and acquiring
%analog stick data
%
%  settings = analogStickControl
%
%  This is a PLDAPS module for the openreception branch.  This module
%  controls various actions related to the analog stick that are done in
%  all cases, in particular initialization and capturing output.
%
%  Returns the configuration settings for the module if called without an
%  argument; you can use this as an argument to createRigPrefs.
%
%  NB:  this module calls functions from the analogStick class
%
%  NB:  generally speaking we want to capture analog stick data prior to
%  any frame drawing or other updates, but after the default trial function
%  has been called (order -Inf), so set order high so that it occurrs after
%  default module but prior to the custom trial function events (at
%  priority NaN).
%
%  Lee Lovejoy
%  January 2017
%  ll2833@columbia.edu

if(nargin==0)

    %  Generate the settings structure
    stateFunction.order = Inf;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = filename;
    requestedStates = {'experimentPostOpenScreen' 'trialSetup' 'frameUpdate'};    
    moduleName = strcat('module',strcat(upper(filename(1)),filename(2:end)));    
    settings.(moduleName).stateFunction = stateFunction;
    settings.(moduleName).use = true;
    settings.(moduleName).requestedStates = requestedStates;
    
    %  Settings structure for analogStick
    temp = properties('analogStick');
    settings.analogStick = cell2struct(cell(size(temp)),temp,1);
else
    
    %  Execute the state dependent components    
    switch state
        case p.trial.pldaps.trialStates.experimentPostOpenScreen

            %  Generate the analog stick object
            inputArgs = [fieldnames(p.trial.analogStick) struct2cell(p.trial.analogStick)]';
            p.functionHandles.analogStickObj = analogStick(p,inputArgs{:});            
            fprintf('****************************************************************\n');            
            fprintf('Initialized analog stick:\n\n');
            disp(p.functionHandles.analogStickObj);
            
            %  Confirm that analog stick is connected and producing output
            %  within the expected range; if not, quit.
            connected = p.functionHandles.analogStickObj.checkConnection;
            if(~connected)
                fprintf('ERROR!  Quitting protocol because analog stick was not correctly detected.\n');
                fprintf('Please fix this and restart.\n');
                p.trial.pldaps.quit = 2;
            else
                fprintf('Analog stick successfully detected.\n');
            end
            
            %  Start a windows manager object for the analog stick
            p.functionHandles.analogStickWindowManager = windowManager;
            fprintf('Initialized windows manager for analog stick.\n');
            fprintf('****************************************************************\n');            

        case p.trial.pldaps.trialStates.trialSetup
            
            %  Confirm that analog stick is still connected.            
            connected = p.functionHandles.analogStickObj.checkConnection;
            if(~connected)
                fprintf('****************************************************************\n');
                fprintf('ERROR!  Pausing protocol because analog stick is not correctly detected.\n');
                fprintf('Please fix this before we can continue.\n');
                fprintf('****************************************************************\n');
                p.trial.pldaps.pause.type = 1;
                p.trial.pldaps.quit = 1;
            end
            
        case p.trial.pldaps.trialStates.frameUpdate
        
            %  At each frameUpdate, update the analog stick object
            p.functionHandles.analogStickObj.update(p);
            
            %  Update the analog stick window manager            
            p.functionHandles.analogStickWindowManager.updateWindows(p.functionHandles.analogStickObj.normalizedPosition);
    end
end
end
