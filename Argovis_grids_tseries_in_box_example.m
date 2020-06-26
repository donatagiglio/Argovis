% script to query a gridded product on Argovis and plot the timeseries of
% temprature averaged in a region

clear all
close all

%%%% set parameters
tag_product        = 'rgTempTotal';
tag_product_title1 = 'Time Mean Temperature, degC';
tag_product_title2 = 'Temperature anomaly, degC';

% settings for regions of interest
cols     = {'k' 'b' 'r'};
% tags     = {'Global' 'SH' 'NH'};
% long_min = [-180 -180 -180];
% long_max = [180 180 180];
% lat_min  = [-90 -90 0];
% lat_max  = [90 0 90];
tags     = {'NH'};
long_min = [-180 ];
long_max = [180 ];
lat_min  = [0];
lat_max  = [65];
plev     = 10; % pressure level of interest (this should be one of the levels...
% currenlty available on Argovis for the product of interest)
years       = 2004:2018;
years_tmean = 2004:2018;

%%%%%%%%%% START %%%%%%%%%%%%%%%
fig_pos  = [0.1        0.1       1420        700];
figure(10)
set(gcf,'color','w','position',fig_pos.*[1 1 1 1]);
    
for i=1:length(long_min)
    tic;
    % get the data from Argovis
    clear data lon lat time data1D
    [data,lon,lat,time,data1D] = Argovis_get_grid(long_min(i),long_max(i),...
        lat_min(i),lat_max(i),years,plev,tag_product);
    
    data1D_ALL(:,i) = data1D;
    toc;
    
    %%%%%%% organize the data to have long from 20.5 to 379.5
    lon(lon<20.5) = lon(lon<20.5) + 360;
    [lon,isort] = sort(lon);
    data = data(isort,:,:);
    %%%%%%% plot map of time mean (using available timesteps)
    figure(22)
    set(gcf,'color','w','position',fig_pos.*[1 1 1 1]);
    
    axesm('robinson', 'maplonlimit', [20 380],'frame', 'on');
    %
    clear d2pl;d2pl = mean(data(:,:,year(time)>=min(years_tmean) & ...
        year(time)<=max(years_tmean)),3)';
    %pcolorm(lat,[lon lon(1)],[d2pl d2pl(:,1)]);shading flat;hb = colorbar;
    pcolorm(lat,lon,d2pl);shading flat;hb = colorbar;
    set(hb,'position',[.875 .3 .025 .4])
    gs = geoshow('landareas.shp', 'FaceColor', [.8 .8 .8],...
        'edgecolor',[.25 .25 .25]);
    set(gca,'linewidth',2,'fontsize',40)
    axis off
    title(tag_product_title1)
    set(gcf,'PaperPositionMode','auto');
    print(22,'-dpng',['~/Desktop/Argovis_grid_region_map_' tags{i} '.png'],'-r150')
    close(22)
end

% create yearly timeseries
for l=1:length(years_tmean)
    data1D_ALL_yearly(l,:) = mean(data1D_ALL(year(time)==years_tmean(l),:),1) - ...
        mean(data1D_ALL(year(time)>=min(years_tmean) & ...
        year(time)<=max(years_tmean),:),1);
end
bar(years_tmean,data1D_ALL_yearly,'grouped')
legend(tags,'location','best')
set(gca,'linewidth',2,'fontsize',40);
set(gca,'xtick',years(1:2:end))

title(tag_product_title2)

set(gcf,'PaperPositionMode','auto');
print('-dpng','~/Desktop/Argovis_grid_tseries_in_region.png','-r150')
