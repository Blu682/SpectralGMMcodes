function [Data] = DataStruc(Mw, R, H, Sc, ID, FAS)
%
%**************************************************************************
% Matlab function to create a formatted dataset for network training
%
%  AUTHOR   : Bhargavi Podili
%  DATE     : 7th March, 2024
%  REFERENCE: Bhargavi Podili, Jahnabi Basu and Raghukanth STG (2024), 
%             Spectral Ground Motion Models for Himalayas using Transfer 
%             learning technique, Journal of Earthquake Engineering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% INPUT PARAMETERS: 
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
% FAS........Fourier Amplitude Spectrum in g-s........0.1 - 100 Hz
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%******All the input parameters should be of equal length******
%**************************************************************************
%
%Normalizing 
    input = [Mw  R log(R) H Sc];
    target = log10(FAS);
    nor_input = (input-mean(input))./std(input);
    nor_target = (target-mean(target))./std(target);
%--------------------------------------------------------------------------
%
%Splitting the data into training, validation and testing groups
[Tr,V,Te] = dividerand(length(input),0.7,0.15,0.15);
for i=1:length(Tr)
    trainx(:,i)=nor_input(Tr(1,i),:);
    traint(:,i)=nor_target(Tr(1,i),:);
end
for i=1:length(V)
    valx(:,i)=nor_input(V(1,i),:);
    valt(:,i)=nor_target(V(1,i),:);
end
for i=1:length(Te)
    testx(:,i)=nor_input(Te(1,i),:);
    testt(:,i)=nor_target(Te(1,i),:);
end
%--------------------------------------------------------------------------
%
[~,EqID]=unique(ID);
f = [0.10,0.15,0.2,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,...
    0.75,0.80,0.85,0.90,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,...
    19,20,25,30,35,40,45,50,60,70,80,100];
%--------------------------------------------------------------------------
%
%Building Data structure
Data = struct('input', input, 'target', target, 'EqID', ID, 'f', f, ...
              'NoOfEQ',length(EqID),'Length',size(target,1),'NoOfOutput',...
              size(target,2),'nor_input',nor_input,'nor_target', nor_target,...
              'Tr',Tr,'V',V, 'Te', Te, 'trainx',trainx,'valx',valx,'testx',...
              testx,'traint',traint,'valt',valt,'testt',testt);
%**************************************************************************
end
