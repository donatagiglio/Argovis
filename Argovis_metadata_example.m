% This script shows how to query Argo metadata from Argovis
%
% This function was written in Matlab 2020a.
%
% Citation for the Argovis web application and the Argovis database: 
% Tucker, T., D. Giglio, M. Scanderbeg, and S.S.P. Shen, 0: Argovis: A Web 
% Application for Fast Delivery, Visualization, and Analysis of Argo Data. 
% J. Atmos. Oceanic Technol., 37, 401–416, https://doi.org/10.1175/JTECH-D-19-0041.1
%
% If using Argo data from Argovis in publications, please cite both the above 
% Argovis web application paper and the original data source reference below 
% in your paper.
%
% Argo data reference:
% " These data were collected and made freely available by the International 
% Argo Program and the national programs that contribute to it. 
% (http://www.argo.ucsd.edu, http://argo.jcommops.org). The Argo Program is 
% part of the Global Ocean Observing System. " 
% Argo (2000). Argo float data and metadata from Global Data Assembly Centre 
% (Argo GDAC). SEANOE. http://doi.org/10.17882/42182
%
clear all
close all
set(0, 'DefaultFigureVisible', 'off')

%%%%%%%%%%%% select start and end month of interest specifying a date
date_start = datenum(2015,2,3); % e.g. the starting month will be Feb 2008 
% (regardless of what you specify as "day" [in this example the "day" 
% is the 3rd of the month], metadata for the whole month
% will be returned; if intersted in restricting also based on the "day",
% you can code that in later (please ask us if you have any questions!)
date_end   = datenum(2016,4,10);% in this case, metadata will be queried up 
% to the full Jan 2009 included, even if the "day" is specified as the 10th
% of the month)

% create vectors for months and years of interest
tdaily_vec = datevec(date_start:date_end);

MMYY       = unique(tdaily_vec(:,1:2),'rows','first');
years      = MMYY(:,1);
months     = MMYY(:,2);

% loop through months and years in the period of interest
tic;
for i=1:size(MMYY,1)
    data_out{i} = Argovis_get_Argo_metadata(months(i),years(i));
end
toc;

%% plot a map for profile density in all the years
close all
dx = 1; dy= 1;
lon_edges  = -180:dx:180;lon_bin = lon_edges(1:end-1)+dx;
lat_edges  = -90:dy:90;lat_bin = lat_edges(1:end-1)+dy;
hist_map   = nan(length(lon_bin),length(lat_bin),size(MMYY,1));
for i=1:size(MMYY,1)
    hist_map(:,:,i) = histcounts2(cell2mat(data_out{i}.lon),...
        cell2mat(data_out{i}.lat),lon_edges,lat_edges);
end
% plot (to write in function)
% Rescale data 1-64
d       = sum(hist_map,3)';
d(d==0) = nan;
d       = log10(d);
mn      = min(d(:));
rng     = max(d(:))-mn;
d       = 1+63*(d-mn)/rng; % Self scale data

L       = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];%
L_tag   = {'0.01' '0.02' '0.05' '0.1' '0.2' '0.5' '1' '2' '5' '10' '20' '50' '100' '200' '500' '1000' '2000' '5000'};%];
% Choose appropriate or somehow auto generate colorbar labels
l       = 1+63*(log10(L)-mn)/rng; % Tick mark positions

fig_pos  = [0.1        0.1       1420        700];
figure('color','w','position',fig_pos.*[1 1 1 1]);
pcolor(lon_bin,lat_bin,d);shading flat;colorbar
hC = colorbar;
set(hC,'Ytick',l,'YTicklabel',L_tag);
set(hC,'position',[.925 .38 .02 .3],'fontsize',24)
set(gca,'fontsize',22,'linewidth',2,'fontweight','bold')

geoshow('landareas.shp', 'FaceColor', [.8 .8 .8],'edgecolor',[.25 .25 .25]); 
