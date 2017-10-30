function frameDrawingFinished(p)
%defaultTrialFunction.frameDrawingFinished steps prior to frame flip.
%
%  frameDrawingFinished includes steps done immediately prior to the frame
%  flip.  This function extracts components from pldapsDefaultTrialFunction.
%
%  Lee Lovejoy
%  ll2833@columbia.edu
%  October 2017

Screen('DrawingFinished', p.trial.display.ptr);
end

