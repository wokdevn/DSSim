upSample = 5;

%% pilot
pilot = [0 1];

upSamplePilot = zeros(1,length(pilot)*upSample);
for m = 1:length(pilot)
   upSamplePilot((m-1)*upSample+1 : m*upSample) = pilot(m); 
end
upSamplePilot