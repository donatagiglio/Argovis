% This script shows how to query an Atmospheric River and Argo profiles in a region and time period of
% interest and make a plot
%
% This script and some of the scripts called within need more work... it
% may look different in the future...
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
nc_path = [data_folder, 'Argovis_AR_nc'];
if ~isfolder(nc_path)
    mkdir data/Argovis_AR_nc
end

fig_path = [data_folder, 'Argovis_AR_fig'];
if ~isfolder(fig_path)
    mkdir data/Argovis_AR_fig
end


% set date of interest for AR
years     = 2017;
months    = 1;
dayAR      = 10;

delta_min = 3;
delta_max = 2;

% you want your last month to be
% set pressure range of interest
presRange='[0,2000]';

% decide if you want BGC or core data
bgc_mode = 1; %1 = BGC, 0 = core

opt = weboptions('Timeout',50,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/', 'CertificateFilename','');

url_beginning = ['https://argovis.colorado.edu/arShapes/findByDate?date='];

url = [url_beginning num2str(years) '-' num2str(months) '-' num2str(dayAR)];

disp(url)
tic;data = webread(url,opt);toc;

% loop through each AR
for a = 1:length(data)
    % find coordinates for each shape
    geotest = data(a).geoLocation(:);
    geocord = getfield(geotest,'coordinates');
    % must make longitude within -180 to 180
    outlong = find(geocord(:,1) < -180);
    geocord(outlong,1) = geocord(outlong,1)+360;
    clear outlong
    outlong = find(geocord(:,1) > 180);
    geocord(outlong,1) = geocord(outlong,1)-360;
    
    %geocords = mat2str(geocord);
    shape = [];
    for sh = 1:length(geocord)
        geobuf = mat2str(geocord(sh,:));
        geobufr = strrep(geobuf,' ',',');
        shape = [shape,geobufr];
        % need to close the shape loop
        if sh == length(geocord);
            geobuf = mat2str(geocord(1,:));
            geobufr = strrep(geobuf,' ',',');
            shape = [shape,geobufr];
        end
    end
    shape2 = strrep(shape,'][','],[');
    shape2use = [ 'shape=[[' shape2 ']]'];
    
    % set time limits for Argo profiles
    day_start = dayAR - delta_min;
    day_end   = dayAR + delta_max; % one day is always added to the time period, so end with one day prior to desired time period
    days = day_start:day_end;
    
    % get Argo data in AR shape
    
    if bgc_mode==1
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
            url_beginning        = ...
                ['https://argovis.colorado.edu/selection/bgc_data_selection?' ...
                'meas_1=' xaxis_var '&meas_2=' yaxis_var '&'];
            %%%% query profiles
            data_out             = ...
                Argovis_get_regional_days(years,months,days,...
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
                print('-dpng',[fig_path '/Argovis_AR_region_example_' xaxis_var '.png'],'-r150')
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    elseif bgc_mode == 0
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%%% EXAMPLE 2: query core/Deep Argo profiles in a region and time period
        %%%% of interest
        
        vars2query          = {'temp' 'psal'};% this could be any of the other bgc variables
        %%%% set parameters
        yaxis_var            = 'pres';
        % saving the variable of interest in a netcdf
        % file for each profile
        var2save_in_nc       = {'temp' 'psal'};% var2save_in_nc = {''} if you don't want to save anything
        var2save_in_nc_units = {'degC' 'psu'};
        path_out_nc          = [nc_path, '/core_'];
        %
        url_beginning        = 'https://argovis.colorado.edu/selection/profiles/?';
        
        %%%% plot profiles that were queried
        fig_pos  = [0.1        0.1       1420        700];
        for ivars2query=1:2
            %%%% query profiles
            data_out = Argovis_get_regional_days(years,months,days,...
            presRange,shape2use,url_beginning,bgc_mode,...
            var2save_in_nc{ivars2query},var2save_in_nc_units{ivars2query},path_out_nc);
            xaxis_var            = vars2query{ivars2query};
            
            figure('color','w','position',fig_pos.*[1 1 1 1]);
            subplot(1,2,1)
            if isempty(data_out) == 0
                Argovis_plot_profile_location_and_WMO(data_out,xaxis_var)
                %
                subplot(1,2,2)
                Argovis_plot_profiles(data_out,xaxis_var,yaxis_var)
                set(gcf,'PaperPositionMode','auto');
                print('-dpng',[fig_path '/Argovis_AR_region_example_' xaxis_var '.png'],'-r150')
            %pause
            end
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
