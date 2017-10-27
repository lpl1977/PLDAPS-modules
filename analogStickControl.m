function settings = analogStickControl(p,state)
%analogStickControl state dependent steps for analogStick object
%
%  Return configuration settings for module:
%  settings = analogStickControl
%
%  This is a PLDAPS module for the openreception branch.  This initializes
%  and updates analogStick object.
%
%  NB:  Generally speaking we want to update analog stick data prior to any
%  frame drawing or other updates, but after the default trial function has
%  been called (order -Inf).  Therefore set order high so that updates
%  occurr after default module but prior to the custom trial function
%  events (order NaN).
%
%  Lee Lovejoy
%  October 2017
%  ll2833@columbia.edu

if(nargin==0)

    %  Generate the settings structure
    stateFunction.order = 100;
    stateFunction.acceptsLocationInput = false;
    filename = mfilename;
    stateFunction.name = filename;
    requestedStates = {'experimentPostOpenScreen' 'frameUpdate'};    
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

            %  Initialize the analog stick object
            inputArgs = [fieldnames(p.trial.analogStick) struct2cell(p.trial.analogStick)]';
            p.functionHandles.analogStickObj = analogStick(p,inputArgs{:});
            fprintf('****************************************************************\n');
            fprintf('Initialized analog stick:\n\n');
            disp(p.functionHandles.analogStickObj);
            fprintf('****************************************************************\n');            
        
        case p.trial.pldaps.trialStates.frameUpdate
        
            %  Update the analog stick object
            p.functionHandles.analogStickObj.update(p);
    end
end
end
