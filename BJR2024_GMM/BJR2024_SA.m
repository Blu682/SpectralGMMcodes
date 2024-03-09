function [T SA] = BJR2024_SA(FAS, Tsig)
%
%**************************************************************************
% Matlab function for predicting FAS for the HIM region, India 
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
% FAS........Fourier Amplitude Spectrum in g-s........0.1-100 Hz
% Tsig.......Significant duration (5-95% threshold) in s
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% OUTPUT PARAMETERS:
% Param.......|Description                          
% T...........Period range : 0.01 to 10s
% SA..........Spectral Acceleration in g
%**************************************************************************
%
T = [0,0.01,0.015,0.02,0.03,0.04,0.05,0.06,0.075,0.09,0.10,0.15,...
    0.2,0.3,0.4,0.5,0.6,0.7,0.75,0.8,0.9,1.0,1.2,1.5,2.0,2.5,...
    3.0,4.0,5.0,6.0,7.5,8.0,9.0,10.0];
%
% Local data characteristics ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
HIMdata_sa.mean_input = [-3.77447819313595,-3.68713525683471,...
    -3.63608033819887,-3.52257252157208,-3.44619406000648,-3.39022642351660,...
    -3.34360516137906,-3.30298329427872,-3.28092201260759,-3.25554996080493,...
    -3.23407762442943,-3.21149540671855,-3.18179623349212,-3.15933086665731,...
    -3.14200637141892,-3.12760126219755,-3.11565764182250,-3.08660271693177,...
    -2.91110643976527,-2.84272984342923,-2.85001406811854,-2.88109912165251,...
    -2.91887339219847,-2.98496881871757,-3.09379080664940,-3.18762325410827,...
    -3.26405175014609,-3.32888092200344,-3.39891745594493,-3.46283079581722,...
    -3.52210846996225,-3.57667457338044,-3.62641651574200,-3.67513817664974,...
    -3.72443179593199,-3.77311869532937,-3.82227965374231,-4.03269723429668,...
    -4.21702143086190,-4.37114881491388,-4.55759471352288,-4.80014120390033,...
    -5.04268710042378,-5.52777879963898,-6.01287052344129,-6.49796225051952,...
    -7.46814573586126,1.17261755807006];
HIMdata_sa.std_input = [0.965134199490970,1.03187915436572,...
    1.02898276661123,1.05714545196561,1.07349705778483,1.07415972262474,...
    1.06160480142818,1.04160557456737,1.02087398839276,1.00516442433658,...
    0.986857020711222,0.975300442542951,0.969715295763564,0.958787764582258,...
    0.944554926883553,0.934985751307699,0.926849400799875,0.901483286138241,...
    0.743423599119549,0.672047120140930,0.609651336320230,0.569670958420599,...
    0.555105319296203,0.527501086521058,0.521891557887010,0.527180401076444,...
    0.524222618938269,0.525351803643868,0.518387301937083,0.512634282636129,...
    0.513873628537542,0.512908468093423,0.509241576098613,0.504476496142394,...
    0.502289459950916,0.501579294568605,0.499036562039453,0.502956646691688,...
    0.535862672933950,0.562089612600697,0.605067276672942,0.610006532732666,...
    0.616260779556042,0.632547150396821,0.653544883713178,0.678816912016397,...
    0.740361249483790,0.275962665620464];
HIMdata_sa.mean_target = [-2.11603829324284,-2.10470439628202,...
    -2.09803185308605,-2.08838987247132,-2.05930935677856,-2.02229673160030,...
    -1.98399025954856,-1.95219637831796,-1.90991002508108,-1.86938889782522,...
    -1.84764661301131,-1.76582770040432,-1.79204399341388,-1.89752661702127,...
    -2.02986015964551,-2.14182324922216,-2.24468251945904,-2.32509752617752,...
    -2.37069394682700,-2.41082048479429,-2.48590643810229,-2.54962813692365,...
    -2.65534713106573,-2.79924520945232,-2.96434602164496,-3.09941958921219,...
    -3.20486701782719,-3.40395383308741,-3.56720049442844,-3.68162455078231,...
    -3.80628558804569,-3.84442837840399,-3.91089976662324,-3.97352790887352];
HIMdata_sa.std_target = [0.589071350773090,0.580149366679064,...
    0.576994483632612,0.576850708911847,0.578687388915709,0.582877819059783,...
    0.586228957057446,0.590488474510584,0.590465778687111,0.589288349742075,...
    0.584828514731036,0.585532124618133,0.610330986094900,0.670751181021139,...
    0.716611031058956,0.743967566024308,0.781060272271925,0.797176479795993,...
    0.799659067771852,0.807433694270543,0.830378628448041,0.849246175056865,...
    0.880601327020215,0.895078578673632,0.919797602548783,0.941241009563772,...
    0.954369031804419,0.946899809885663,0.920914676704896,0.909342339732171,...
    0.893567010086270,0.887339393702492,0.870146972037011,0.853413364289943];
%
% Input data ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Input = [log10(FAS) log10(Tsig)];
%
% Normalizing ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
NorInput = (Input-HIMdata_sa.mean_input)./HIMdata_sa.std_input;
%
% Predicted values ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
load myDNNsa.mat
pred = predict(myDNNsa,NorInput')'.*HIMdata_sa.std_target+...
       HIMdata_sa.mean_target; 
SA = 10.^pred;
%**************************************************************************
end

