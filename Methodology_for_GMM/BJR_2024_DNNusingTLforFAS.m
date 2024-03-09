%**************************************************************************
% 
% DEMO: Matlab code to derive a deep neural network for local data,
%             using a global dataset via transfer learning technique
%
% The code is written for building a prediction model for FAS using two
% datasets: Global (NGA-West2 for BJR2024) and Local (HIM for BJR2024)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%  AUTHOR   : Bhargavi Podili
%  DATE     : 7th March, 2024
%  REFERENCE: Bhargavi Podili, Jahnabi Basu and Raghukanth STG (2024), 
%             Spectral Ground Motion Models for Himalayas using Transfer 
%             learning technique, Journal of Earthquake Engineering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT PARAMETERS: (of both Global and Local datasets)
% Param.....|Description.............................|Range
% Mw.........Moment magnitude.........................[4.0 7.9]
% R..........Rupture distance (for Mw>=7) in km
%  ..........Hypocentral distance (for Mw<6) in km....[10 862]
% H..........Hypocentral depth in km..................[5 80]
% Sc.........site class
%            Sc = 0 for rock ground (Vs30 > 700m/s)
%            Sc = 1 for firm ground (375 < Vs30 ≤ 700m/s) 
%            Sc = 2 for soft soil (Vs30 ≤ 375m/s)
% ID.........Earthquake ID............................[1 No.of Earthquakes]
%            Unique value for records of each earthquake in the data
%
%TARGET PARAMETER: (of both Global and Local datasets)
% FAS........Fourier Amplitude Spectrum in g-s........0.1 - 100 Hz
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

%****** All the parameters should be of equal length *****
%****** Helper Funtion: DataStruc.m **********************
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%Network architecture can be finalized by varying the number of neurons in
%the first and second hidden layers: i and j
%
%For the current case,
 i=9; j=13;
%Refer to section 3.2 of the manuscript for deciding ranges for i and j
%for i=5:10   %(for Finalizing network architecture)
    %for j=5:20   %(for Finalizing network architecture)
        %------------------------------------------------------------------
        %Step-1 : Using Global data
        %Derive data structure for the global data:
         NGAfas = DataStruc(Mw, R, H, Sc, ID, FAS); %Input global data
        %Define the network 
         layers = [sequenceInputLayer(size(NGAfas.input,2),...
                                       'Normalization','none')
                   eluLayer
                   fullyConnectedLayer(i)
                   eluLayer
                   fullyConnectedLayer(j)
                   eluLayer
                   fullyConnectedLayer(NGAfas.NoOfOutput)
                   regressionLayer];
         options = trainingOptions('adam', 'InitialLearnRate',0.01,...
                                   'ValidationData',{NGAfas.valx,NGAfas.valt},...
                                   'MaxEpochs',750);
         %Train the network
         rng(320)
         net = trainNetwork(NGAfas.trainx,NGAfas.traint,layers,options);
         Pred = predict(net,NGAfas.nor_input')'.*std(NGAfas.target)+...
                mean(NGAfas.target); %For checking
         clear layers options Pred NGAfas
        %--------------------------------------------------------------------
        %Step 2 : Using Local Data
        %Derive data structure for the local data:
         HIMfas = DataStruc(Mw, R, H, Sc, ID, FAS); %Input local data
        %Define the network
         layers = [sequenceInputLayer(size(HIMfas.input,2),'Normalization',...
                                      'none','Name','Input Layer')
                   eluLayer('Name','Elu Activation 1')
                   fullyConnectedLayer(i,'Name','Hidden Layer 1','Weights',...
                                       net.Layers(3).Weights,'Bias',...
                                       net.Layers(3).Bias,...
                                       'WeightLearnRateFactor',0)
                   eluLayer('Name','Elu Activation 2')
                   fullyConnectedLayer(j,'Name','Hidden Layer 2','Weights',...
                                       net.Layers(5).Weights,'Bias',...
                                       net.Layers(5).Bias)
                   eluLayer('Name','Elu Activation 3')
                   fullyConnectedLayer(size(HIMfas.target,2),'Name',...
                                       'Output Layer')
                   regressionLayer('Name','Regression')];
          options = trainingOptions('adam','InitialLearnRate',0.01, ...
                                    'ValidationData',{HIMfas.valx,HIMfas.valt},...
                                    'MaxEpochs',750,'Verbose',0);
         %Train the network
         rng(320)
         myDNNfas = trainNetwork(HIMfas.trainx,HIMfas.traint,layers,options);
         Pred = predict(myDNNfas,HIMfas.nor_input')'.*std(HIMfas.target)+...
                mean(HIMfas.target); %For checking
        %------------------------------------------------------------------
        save myDNNfas myDNNfas
        f1='myDNNfas.mat';
        f2=sprintf('myDNNfas_%d_%d.mat',i,j);
        movefile(f1,f2)
%    end   %(for Finalizing network architecture)
%end   %(for Finalizing network architecture)
%**************************************************************************  