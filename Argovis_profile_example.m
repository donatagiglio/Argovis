% This script shows how to query core or bgc Argo profiles and make a plot
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
fig_path = [data_folder, 'figures'];
if ~isfolder(fig_path)
    mkdir data/figures
end

% cd ~/Downloads/ % lets just keep the directory structure simple, ok?
examples2run = [2];% 2]; % 1 means bgc, 2 means core
disp('>>>> Argovis profile API running: ')

% set WMO number and cycle number
plat_bufr = '4902480';%'6902686';%'3901668';%
cyc_bufr  = '11';%'74';%'34';%


% set pressure range of interest
presRange='[0,2000]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==1)
    %%%%%%%%%%%%%%%%%%%%%%% query bgc Argo profiles
    
    vars2query= {...
        'temp' 'psal' 'doxy' 'bbp' 'bbp470' 'bbp532' 'bbp700' 'turbidity' ...
        'cp' 'cp660' 'chla' 'cdom' 'nitrate' 'bisulfide' 'ph_in_situ_total' ...
        'down_irradiance' 'down_irradiance380' 'down_irradiance412' ...
        'down_irradiance443' 'down_irradiance490' 'down_irradiance555' ...
        'up_radiance' 'up_radiance412' 'up_radiance443' 'up_radiance443_qc' ...
        'up_radiance490' 'up_radiance555' 'downwelling_par' ...
        };
    vars2query_units = {'degC' 'psu' 'mmol/kg'};
    for ivars2query=1:length(vars2query)
        %%%% set parameters
        xaxis_var            = vars2query{ivars2query};% this could be any of the other bgc variables
        yaxis_var            = 'pres';
        % saving the variable of interest in a netcdf
        % file for each profile
        var2save_in_nc       = vars2query(ivars2query);
        if length(vars2query_units)>=ivars2query
            var2save_in_nc_units = vars2query_units(ivars2query);
        else
            var2save_in_nc_units = {''};
        end
        path_out_nc          = [nc_path, '/', xaxis_var '_'];
        %
        bgc_mode             = 1;
        url        = ...
            ['https://argovis.colorado.edu/catalog/profiles/' plat_bufr '_' cyc_bufr '/'];
        %%%% query profiles
        data = Argovis_get_profiles(url,bgc_mode);
        
        if ~isempty(data)
            vars = fields(data);
            
            for i=1:length(vars)
                % initialize
                if ~exist(vars{i},'var')
                    eval(['dataOUT.' vars{i} ' = {};'])
                end
                eval(['dataOUT.' vars{i} ' = cat(1,dataOUT.' vars{i} ',data.' vars{i} ''');'])
            end
            
            if ~isempty(var2save_in_nc{1})
                % save one netcdf for each profile in the cells in data
                save_netcdf_for_each_profile_in_cell(...
                    data,var2save_in_nc,var2save_in_nc_units,path_out_nc);
            end
        end
        %%%% plot profiles that were queried, if any
        if isfield(data,xaxis_var)
            close all
            fig_pos  = [0.1        0.1       1420        700];
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            subplot(1,3,1)
            Argovis_plot_profile_location_and_WMO(data,xaxis_var)
            %
            subplot(1,3,2)
            Argovis_plot_profiles(data,xaxis_var,yaxis_var)
            %
            subplot(1,3,3)
            Argovis_plot_bgc_qc(data,xaxis_var,yaxis_var,presRange)
            set(gcf,'PaperPositionMode','auto');
            print('-dpng',[fig_path 'Argovis_example01' xaxis_var '.png'],'-r150')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% query core/Deep Argo profiles
    
    %%%% set parameters
    xaxis_var            = 'psal';% this could be any of the other bgc variables
    yaxis_var            = 'pres';
    % saving the variable of interest in a netcdf
    % file for each profile
    var2save_in_nc       = {'temp' 'psal'};% var2save_in_nc = {''} if you don't want to save anything
    var2save_in_nc_units = {'degC' 'psu'};
    path_out_nc          = [nc_path, '/core_'];
    %
    bgc_mode             = 0;
    url        = ...
        ['https://argovis.colorado.edu/catalog/profiles/' plat_bufr '_' cyc_bufr '/'];
    %%%% query profiles
    data = Argovis_get_profiles(url,bgc_mode);
    if ~isempty(data)
        vars = fields(data);
        
        for i=1:length(vars)
            % initialize
            if ~exist(vars{i},'var')
                eval(['dataOUT.' vars{i} ' = {};'])
            end
            eval(['dataOUT.' vars{i} ' = cat(1,dataOUT.' vars{i} ',data.' vars{i} ''');'])
        end
        
        if ~isempty(var2save_in_nc{1})
            % save one netcdf for each profile in the cells in data
            save_netcdf_for_each_profile_in_cell(...
                data,var2save_in_nc,var2save_in_nc_units,path_out_nc);
        end
    end
    %%%% plot profiles that were queried
    for j = 1:length(var2save_in_nc)
    if isfield(data,var2save_in_nc{j})
        close all
        fig_pos  = [0.1        0.1       1420        700];
        figure('color','w','position',fig_pos.*[1 1 1 1]);
        subplot(1,2,1)
        Argovis_plot_profile_location_and_WMO(data,var2save_in_nc{1})
        %
        subplot(1,2,2)
        Argovis_plot_profiles(data,xaxis_var,yaxis_var)
        set(gcf,'PaperPositionMode','auto');
        print('-dpng',[fig_path '/Argovis_example02' var2save_in_nc{j} '.png'],'-r150')
    end
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% OTHER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Argovis_plot_profile_location_and_WMO(data_out,xaxis_var)
platform_number_unique      = unique(cell2mat(data_out.platform_number));
platform_number_unique_cols = parula(length(platform_number_unique));
for i=1:length(platform_number_unique)
    clear msk;msk = cell2mat(data_out.platform_number) == platform_number_unique(i);
    plot(cell2mat(data_out.lon(msk)),cell2mat(data_out.lat(msk)),'.',...
        'markersize',30,'color',platform_number_unique_cols(i,:))
    hold on
    leg{i} = num2str(platform_number_unique(i));
    
end
hl = legend(leg,'location','northeast');
geoshow('landareas.shp', 'FaceColor', 'black');
set(gca,'xlim',[min(cell2mat(data_out.lon)) max(cell2mat(data_out.lon))]+[-5 8],...
    'ylim',[min(cell2mat(data_out.lat)) max(cell2mat(data_out.lat))]+[-5 8],...
    'fontsize',26)
xlabel('Longitude')
ylabel('Latitude')
title([xaxis_var ' profiles, WMO# in color'])
set(hl,'fontsize',14)
end
%%%%%%%%%%%%%
function Argovis_plot_profiles(data_out,xaxis_var,yaxis_var)
platform_number_unique      = unique(cell2mat(data_out.platform_number));
platform_number_unique_cols = parula(length(platform_number_unique));
eval(['bfrx = data_out.' xaxis_var ';']); eval(['bfry = data_out.' yaxis_var ';'])
for i=1:length(platform_number_unique)
    clear *msk;msk = cell2mat(data_out.platform_number) == platform_number_unique(i);
    bfrx_msk = bfrx(msk);bfry_msk = bfry(msk);
    for j=1:length(bfrx_msk)
        plot(bfrx_msk{j},bfry_msk{j},'-',...
            'color',platform_number_unique_cols(i,:))
        hold on
    end
end
set(gca,'fontsize',26)
axis ij
xlabel(xaxis_var)
ylabel(yaxis_var)
end
%%%%%%%%%%%%%
function Argovis_plot_bgc_qc(data_out,xaxis_var,yaxis_var,yaxisRange)
eval(['bfrc = data_out.' xaxis_var '_qc;'])
platform_number_unique      = unique(cell2mat(data_out.platform_number));
platform_number_unique_cols = parula(length(platform_number_unique));
eval(['bfrx = data_out.' xaxis_var ';']); eval(['bfry = data_out.' yaxis_var ';'])
n = 0;
for i=1:length(platform_number_unique)
    clear *msk;msk = cell2mat(data_out.platform_number) == platform_number_unique(i);
    bfrx_msk = bfrx(msk);bfry_msk = bfry(msk);bfrc_msk = bfrc(msk);
    for j=1:length(bfrx_msk)
        n = n + 1;
        scatter(n.*ones(size(bfrx_msk{j})),bfry_msk{j},8,bfrc_msk{j},'filled')
        colorbar
        hold on
        
        % mark each profile based on the WMO, consistent with the legend in
        % the first panel
        plot(n,min(eval(yaxisRange)),'.','markersize',30,...
            'color',platform_number_unique_cols(i,:))
        plot(n,max(eval(yaxisRange)),'.','markersize',30,...
            'color',platform_number_unique_cols(i,:))
    end
end
set(gca,'fontsize',26,'position',[0.7074    0.1100    0.1513*1.5    0.8150])
axis ij
xlabel('Index')
ylabel(yaxis_var)
colormap(jet(9));caxis([.5 9.5])
title([xaxis_var ' QC in color'])
axis tight
end
%%%%%%%%%%%%%
function Argovis_scatter_plot(data_out,var)
d    = eval(['data_out.'  var ';']);
date = cell2mat(data_out.date);
for i=1:length(data_out.date)
    scatter(date(i).*ones(size(d{i})),data_out.pres{i},30,d{i},'filled')
    hold on
end
axis ij;colorbar
set(gca,'fontsize',26)
axis tight
datetick('x')
title(var,'interpreter','none')
end
%%%%%%%%%%%%%
function Argovis_contourf_plot(data_out,var,pressure_axis,varargin)
% set 'cax' if you want to pass it to the function and set caxis, e.g. you
% would call the function using
% Argovis_contourf_plot(data_out,var,pressure_axis,'cax',[100 400])
% set 'cf' if you want to pass it to the function (can be a scalar for the
% number of contours or a vector indicating the actual contours)
for i=1:2:length(varargin)
    clear bfr;bfr = varargin{i+1};
    eval([varargin{i} ' = bfr;'])
end

if ~exist('cf','var')
    cf = 30;
end

d         = eval(['data_out.'  var ';']);
date      = cell2mat(data_out.date);
d_gridded = nan(length(pressure_axis),length(date));
pmn = [];
pmm = [];
for i=1:length(date)
    if ~isempty(data_out.pres{i})
        d_gridded(:,i) = interp1(data_out.pres{i},d{i},pressure_axis);
        pmn = min([pmn data_out.pres{i}]);
        pmm = max([pmm data_out.pres{i}]);
    end
end
[date,I] = unique(date);
contourf(date,pressure_axis,d_gridded(:,I),cf);colorbar
axis ij
axis tight
set(gca,'fontsize',26,'ylim',[floor(pmn) ceil(pmm)])
datetick('x')
title([var ' (data range=[' num2str(min(d_gridded(:))) ' ' ...
    num2str(max(d_gridded(:))) ']'],'interpreter','none')
if exist('cax','var')
    caxis(cax)
end
end
%%%%%%%%%%%%%
function Argovis_pcolor_plot(data_out,var,pressure_axis,varargin)
% set 'cax' if you want to pass it to the function and set caxis, e.g. you
% would call the function using
% Argovis_contourf_plot(data_out,var,pressure_axis,'cax',[100 400])
for i=1:2:length(varargin)
    clear bfr;bfr = varargin{i+1};
    eval([varargin{i} ' = bfr;'])
end
d         = eval(['data_out.'  var ';']);
date      = cell2mat(data_out.date);
d_gridded = nan(length(pressure_axis),length(date));
pmn = [];
pmm = [];
for i=1:length(date)
    if ~isempty(data_out.pres{i})
        d_gridded(:,i) = interp1(data_out.pres{i},d{i},pressure_axis);
        pmn = min([pmn data_out.pres{i}]);
        pmm = max([pmm data_out.pres{i}]);
    end
end
[date,I] = unique(date);
pcolor(date,pressure_axis,d_gridded(:,I));shading flat;colorbar
axis ij
axis tight
set(gca,'fontsize',26,'ylim',[floor(pmn) ceil(pmm)])
datetick('x')
title([var ' (data range=[' num2str(min(d_gridded(:))) ' ' ...
    num2str(max(d_gridded(:))) ']'],'interpreter','none')
if exist('cax','var')
    caxis(cax)
end
end
%%%%%%%%%%%%%