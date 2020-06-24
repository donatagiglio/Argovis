% This script shows how to query core or bgc Argo platforms and make
% several plots
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


disp('>>>> Argovis platform API running: ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% Query a platform and make plots. At this moment in time, this query returns
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
try
    vars_names = {};
    for i=1:length(data0)
        vars_names = unique({vars_names{:} data0(i).bgcMeasKeys{:}});
    end
    url_beginning = ['https://argovis.colorado.edu/catalog/bgc_platform_data/' ...
            platform_number '/?xaxis=pres&yaxis='];
    
catch
    url0      = ['https://argovis.colorado.edu/catalog/platforms/' ...
        platform_number '/?xaxis=pres&yaxis=temp'];
    opt = weboptions('Timeout',20,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/', 'CertificateFilename','');
    data0     = webread(url0,opt);
    bgc_mode = 0;
    % create a list of all the variables available
    
    vars_names = {};
    for i=1:length(data0)
        vars_names = unique({vars_names{:} data0(i).station_parameters{:}});
    end
    url_beginning = ['https://argovis.colorado.edu/catalog/platforms/' ...
            platform_number '/?xaxis=pres&yaxis='];
end
%%%% load data for each of the available variables and make a plot
fig_pos  = [0.1        0.1       1420        700];
for ivar=1:length(vars_names)
    if ~strcmp(vars_names{ivar},'pres')
        %subplot(ceil(length(vars_names)/2),2,ivar)
        clear dvar url cyclenum time
        
        url     = [url_beginning vars_names{ivar}];
        %%%% query profiles
        data_out = Argovis_get_profiles(url,bgc_mode);
        
        %%%% plots
        figure('color','w','position',fig_pos.*[1 1 1 1]);
        Argovis_scatter_plot(data_out,vars_names{ivar})
        set(gcf,'PaperPositionMode','auto');
        print('-dpng',['Argovis_' platform_number '_' vars_names{ivar} '_scatter.png'],'-r150')
        
        figure('color','w','position',fig_pos.*[1 1 1 1]);
        
        if ~strcmp(vars_names{ivar},'chla')
            Argovis_contourf_plot(data_out,vars_names{ivar},pressure_axis)
        else
            Argovis_contourf_plot(data_out,vars_names{ivar},pressure_axis,'cax',[0 4],'cf',0:.2:4)
        end
        set(gcf,'PaperPositionMode','auto');
        print('-dpng',['Argovis_' platform_number '_' vars_names{ivar} '_contourf.png'],'-r150')
        
        figure('color','w','position',fig_pos.*[1 1 1 1]);
        Argovis_pcolor_plot(data_out,vars_names{ivar},pressure_axis)
        set(gcf,'PaperPositionMode','auto');
        print('-dpng',['Argovis_' platform_number '_' vars_names{ivar} '_pcolor.png'],'-r150')
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% OTHER FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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