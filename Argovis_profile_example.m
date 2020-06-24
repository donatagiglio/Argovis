% This script shows an example of how to query one profile in Argovis, save
% to netcdf all the variables available and plot them
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

%make dirs to store data
data_folder = [pwd, '/data/'];
if ~isfolder(data_folder)
    mkdir data
end
nc_path = [data_folder, 'Argovis_nc'];
if ~isfolder(nc_path)
    mkdir data/Argovis_nc
end

% set WMO number and cycle number
% example for a bgc profile: 
plat_bufr = '4902480';%'2902534';%'6902686';%'3901668';%
cyc_bufr  = '2';%'11';%'74';%'34';%
% % % example for a core profile: 
% plat_bufr = '2902534';%'4902480';%'6902686';%'3901668';%
% cyc_bufr  = '2';%'11';%'74';%'34';%

%%%%%%%%%%%%%%%%

url        = ...
    ['https://argovis.colorado.edu/catalog/profiles/' plat_bufr '_' cyc_bufr '/'];
%%%% query profile: try first with bgc_mode=1 in case it is a bgc profile
bgc_mode  = 1;
data = Argovis_get_profiles(url,bgc_mode);
if ~isfield(data,'pres')
    bgc_mode  = 0;
    data = Argovis_get_profiles(url,bgc_mode);
end

%%%% find and store variable names returned by the query
vars       = {};
vars_units = {};
flds       = fields(data);

other_vars_names = {'date' 'lon' 'lat' ...
            'cycle_number','platform_number','x_id'};
for i=1:length(flds)
    if ~strcmp(flds{i}(end-2:end),'_qc') && ...
            sum(contains(other_vars_names,flds{i}))==0 && ...
            length(eval(['data.' flds{i} '{1}']))==length(data.pres{1}) && ...
            ~strcmp(flds{i},'pres')
        vars{end+1} = flds{i};
        % units should be assigned based on the variable name (not yet
        % implemented in this script)
        vars_units{end+1} = '';
    end
end

% save one netcdf for each profile in the cells in data
save_netcdf_for_each_profile_in_cell(data,vars,vars_units,[nc_path '/']);

%%%% plot variables and save netcdf file
fig_pos  = [0.1        0.1       1420        700];
figure('color','w','position',fig_pos.*[1 1 1 1]);
for i=1:length(vars)
    subplot(ceil(length(vars)/4),4,i)
    clear bfr;bfr = eval(['data.' vars{i} ';']);
    plot(bfr{1},data.pres{1},'k','linewidth',2)
    set(gca,'fontsize',20)
    axis ij
    xlabel(vars{i})
    ylabel('Pressure, dbar')
    axis tight
end
set(gcf,'PaperPositionMode','auto');
print('-dpng',['./data/Argovis_profile_' data.x_id{1} '.png'],'-r150')