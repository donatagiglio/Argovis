% This script shows different examples of API queries.
% EXAMPLE 1: query bgc Argo profiles in a region and time period of
% interest and make a plot
% EXAMPLE 2: query core/deep Argo profiles in a region and time period of
% interest and make a plot
% EXAMPLE 3: Query all profiles/variables (including bgc) from a
% platform and make plots. At this moment in time, this query returns
% all the data (no qc-based selection), along with the qc flag (as
% requested for bgc variables)
%
% If you are interested in creating a script based on only one of the
% examples, you can delete sections for other examples. Just make sure to
% keep functions and parameters that are needed.
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

% cd ~/Downloads/ % lets just keep the directory structure simple, ok?
examples2run = [1 2 3];
disp('>>>> Argovis examples running: ')
disp(num2str(examples2run))
disp('>>>> To change the examples running, edit the variable ''examples2run''')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% Parameters to set for querying Argo profiles in a region and time
%%%%% period of interest
% set shape/region
tag_region = 'LabradorSea';%'box_example'; % 
lon_min    = '-165';%'-135';
lon_max    = '-160';%'-130';
lat_min    = '38';%'40';
lat_max    = '40';%'45';
switch tag_region
    case 'LabradorSea'
        % this shape was drawn on the browser and then copied from the url
        shape2use = ['shape=[[[-58.697569,68.784144],[-60.806944,66.231457],' ...
            '[-63.267882,64.472794],[-63.971007,62.593341],[-62.916319,60.413852],' ...
            '[-61.158507,57.515823],[-57.291319,54.572062],[-52.369444,50.958427],' ...
            '[-49.556944,49.837982],[-46.744444,52.696361],[-44.635069,57.136239],' ...
            '[-44.283507,59.534318],[-51.314757,62.593341],[-54.127257,66.089364],' ...
            '[-58.697569,68.784144]]]'];
    case 'box_example'
        shape2use = ['shape=[[[' lon_min ',' lat_min '],[' ...
            lon_min ',' lat_max '],[' lon_max ',' lat_max '],[' ...
            lon_max ',' lat_min '],[' lon_min ',' lat_min ']]]'];
end
% set time period of interest (profiles for all the months in "years" will 
% loaded, until the "end_month" in "end_year"
years     = 2019:2019;
end_month = 12; % if not 12, set one month more than when you want your last month to be
% set pressure range of interest
presRange='[0,2000]';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==1)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% EXAMPLE 1: query bgc Argo profiles in a region and time period
    %%%% of interest
    %
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
        % flag to save a netcdf file for each profile
        flag_save_nc         = 1;% this saves the variable of interest in a netcdf
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
        url_beginning        = ...
            ['https://argovis.colorado.edu/selection/bgc_data_selection?' ...
            'xaxis=' xaxis_var '&yaxis=' yaxis_var '&'];
        %%%% query profiles
        data_out             = ...
            Argovis_regional_query(years,end_month,...
            presRange,shape2use,url_beginning,bgc_mode,...
            var2save_in_nc,var2save_in_nc_units,path_out_nc);
        %%%% plot profiles that were queried, if any
        if isfield(data_out,xaxis_var)
            close all
            fig_pos  = [0.1        0.1       1420        700];
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            subplot(1,3,1)
            Argovis_plot_profile_location_and_WMO(data_out,xaxis_var)
            %
            subplot(1,3,2)
            Argovis_plot_profiles(data_out,xaxis_var,yaxis_var)
            %
            subplot(1,3,3)
            Argovis_plot_bgc_qc(data_out,xaxis_var,yaxis_var,presRange)
            set(gcf,'PaperPositionMode','auto');
            print('-dpng',['Argovis_example01' xaxis_var '.png'],'-r150')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% EXAMPLE 2: query core/Deep Argo profiles in a region and time period
    %%%% of interest
    %
    %%%% set parameters
    xaxis_var            = 'temp';% this could be any of the other bgc variables
    yaxis_var            = 'pres';
    % flag to save a netcdf file for each profile
    flag_save_nc         = 1;% this saves the variable of interest in a netcdf
    % file for each profile
    var2save_in_nc       = {'temp' 'psal'};
    var2save_in_nc_units = {'degC' 'psu'};
    path_out_nc          = [nc_path, '/core_'];
    %
    bgc_mode             = 0;
    url_beginning        = 'https://argovis.colorado.edu/selection/profiles/?';
    %%%% query profiles
    data_out             = ...
        Argovis_regional_query(years,end_month,...
        presRange,shape2use,url_beginning,bgc_mode,...
        var2save_in_nc,var2save_in_nc_units,path_out_nc);
    %%%% plot profiles that were queried
    fig_pos  = [0.1        0.1       1420        700];
    figure('color','w','position',fig_pos.*[1 1 1 1]);
    subplot(1,2,1)
    Argovis_plot_profile_location_and_WMO(data_out,xaxis_var)
    %
    subplot(1,2,2)
    Argovis_plot_profiles(data_out,xaxis_var,yaxis_var)
    set(gcf,'PaperPositionMode','auto');
    print('-dpng',['Argovis_example02.png'],'-r150')
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==3)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% EXAMPLE 3: Query all profiles/variables (including bgc) from a
    %%%% platform and make plots. At this moment in time, this query returns
    %%%% all the data (no qc-based selection), along with the qc flag (as
    %%%% requested for bgc variables)
    %
    %%%% set parameters
    platform_number = '5904684';%'2903354'; %
    pressure_axis   = 5:10:6000;% (to be used for interpolation)
    bgc_mode        = 1;
    %%%% load variables available for that float
    % load data for one variable to look at the metadata (i.e. what variables
    % are available for the float of interest)
    url0      = ['https://argovis.colorado.edu/catalog/bgc_platform_data/' ...
        platform_number '/?xaxis=pres&yaxis=temp'];
    opt = weboptions('Timeout',20,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/', 'CertificateFilename','');
    data0     = webread(url0,opt);
    % create a list of all the variables available
    vars_names = {};
    for i=1:length(data0)
        vars_names = unique({vars_names{:} data0(i).bgcMeasKeys{:}});
    end
    %%%% load data for each of the available variables and make a plot
    fig_pos  = [0.1        0.1       1420        700];
    for ivar=1:length(vars_names)
        if ~strcmp(vars_names{ivar},'pres')
            %subplot(ceil(length(vars_names)/2),2,ivar)
            clear dvar url cyclenum time
            url      = ['https://argovis.colorado.edu/catalog/bgc_platform_data/' ...
                platform_number '/?xaxis=pres&yaxis=' vars_names{ivar}];
            %%%% query profiles
            data_out = Argovis_get_profiles(url,bgc_mode);
            
            %%%% plots
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            Argovis_scatter_plot(data_out,vars_names{ivar})
            set(gcf,'PaperPositionMode','auto');
            print('-dpng',['Argovis_example03_' platform_number '_' vars_names{ivar} '_scatter.png'],'-r150')
            
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            
            if ~strcmp(vars_names{ivar},'chla')
                Argovis_contourf_plot(data_out,vars_names{ivar},pressure_axis)
            else
                Argovis_contourf_plot(data_out,vars_names{ivar},pressure_axis,'cax',[0 4],'cf',0:.2:4)
            end
            set(gcf,'PaperPositionMode','auto');
            print('-dpng',['Argovis_example03_' platform_number '_' vars_names{ivar} '_contourf.png'],'-r150')
            
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            Argovis_pcolor_plot(data_out,vars_names{ivar},pressure_axis)
            set(gcf,'PaperPositionMode','auto');
            print('-dpng',['Argovis_example03_' platform_number '_' vars_names{ivar} '_pcolor.png'],'-r150')
        end
    end
end
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