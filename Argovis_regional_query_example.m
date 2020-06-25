% This script shows how to query bgc and core/deep Argo profiles in a region and time period of
% interest and make a plot
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

examples2run = 2;%[1 2];% 1 is only BGC profiles. 2 is T/S/p for all profiles
disp('>>>> Argovis examples running: ')
disp(num2str(examples2run))
disp('>>>> To change whether bgc or core is running, edit the variable ''examples2run''')
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
months    = 1:3; % except for 12, set the ending month toone month more than

% you want your last month to be
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
        url_beginning        = ...
            ['https://argovis.colorado.edu/selection/bgc_data_selection?' ...
            'xaxis=' xaxis_var '&yaxis=' yaxis_var '&'];
        %%%% query profiles
        data_out             = ...
            Argovis_get_regional(years,months,...
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
            print('-dpng',['Argovis_region_example_' xaxis_var '.png'],'-r150')
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if any(examples2run==2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% EXAMPLE 2: query core/Deep Argo profiles in a region and time period
    %%%% of interest
    for ivars2query=1:2
         vars2query          = {'temp' 'psal'};% this could be any of the other bgc variables
        %%%% set parameters
        xaxis_var            = vars2query{ivars2query};
        yaxis_var            = 'pres';
        % saving the variable of interest in a netcdf
        % file for each profile
        var2save_in_nc       = {'temp' 'psal'};% var2save_in_nc = {''} if you don't want to save anything
        var2save_in_nc_units = {'degC' 'psu'};
        path_out_nc          = [nc_path, '/core_'];
        %
        bgc_mode             = 0;
        url_beginning        = 'https://argovis.colorado.edu/selection/profiles/?';
        %%%% query profiles
        data_out             = ...
            Argovis_get_regional(years,months,...
            presRange,shape2use,url_beginning,bgc_mode,...
            var2save_in_nc{ivars2query},var2save_in_nc_units{ivars2query},path_out_nc);
        %%%% plot profiles that were queried
        fig_pos  = [0.1        0.1       1420        700];
        figure('color','w','position',fig_pos.*[1 1 1 1]);
        subplot(1,2,1)
        Argovis_plot_profile_location_and_WMO(data_out,xaxis_var)
        %
        subplot(1,2,2)
        Argovis_plot_profiles(data_out,xaxis_var,yaxis_var)
        set(gcf,'PaperPositionMode','auto');
        print('-dpng',['Argovis_region_example_' xaxis_var '.png'],'-r150')
        %pause
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
       % if ~isempty(bfrx_msk{j})
       try
           plot(bfrx_msk{j},bfry_msk{j},'-',...
               'color',platform_number_unique_cols(i,:))
           hold on
       catch
           
       end
       % end
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

