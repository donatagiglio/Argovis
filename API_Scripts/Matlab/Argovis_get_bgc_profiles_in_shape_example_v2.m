% this script gets data in a region of interest and saves each profile as a
% .nc file if needed, or it stores data in a cell
clear all

cd ~/Downloads/

xaxis_var       = 'doxy';
xaxis_var_units = 'mmol/kg';
yaxis_var       = 'pres';

% flag to store variables in matlab cells (1 if yes)
flag_store_in_cell = 1;

pmax = 2000; % for the plots

disp('Pressure range is now [0 pmax], should be not hard coded in')

% flag to save a netcdf file for each profile
flag_save_nc         = 0;    
var2save_in_nc       = {'doxy'};
var2save_in_nc_units = {'mmol/kg'};
path_out_nc          = '~/Downloads/Argovis_nc/bgc_';

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
years     = 2020:2020;
mm_ALL    = 7;%1:12
end_month = 12;
end_year  = 2020;

%%%%%%%% START %%%%%%%%%
clear t M YR
[YR,M]   = meshgrid(years,mm_ALL);
t        = datenum(YR(:),M(:),15);
t_eomday = eomdate(YR(:),M(:));

% get the data
for l=1:length(t)
    if ~(year(t(l))==end_year && month((l))==end_month && end_month~=12)
        clear url data *bfr
        
        url = ['https://argovis.colorado.edu/selection/bgc_data_selection?' ...
            'meas_1=' xaxis_var '&meas_2=' yaxis_var  ...
            '&startDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-01&endDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-' num2str(day(t_eomday(l))) '&presRange=[0,' num2str(pmax) ']&' ...
            shape2use];
        % now we upload variables
        data = Argovis_get_bgc_profiles_in_shape(url);
        vars = fields(data);
        
        if flag_store_in_cell==1
            % concatenate cells to store all the profiles
            for i=1:length(vars)
                % initialize
                if ~exist(vars{i},'var')
                    eval([vars{i} ' = {};'])
                end
                eval([vars{i} ' = cat(1,' vars{i} ',data.' vars{i} ''');'])
            end
        end
        if flag_save_nc==1
            % save one netcdf for each profile in the cells in data
            save_netcdf_for_each_profile_in_cell(...
                data,var2save_in_nc,var2save_in_nc_units,path_out_nc);
        end
    end
end
% save platform number
platform_number = {};
for i=1:length(x_id)
    clear bfr
    bfr = strsplit(x_id{i},'_');
    platform_number{i} = str2num(bfr{1});
end

%% make a plot
close all
fig_pos  = [0.1        0.1       1420        700];
fntsz = 22;

figure('color','w','position',fig_pos.*[1 1 1 1]);

tiledlayout(1,4,'padding','compact','TileSpacing','none')
nexttile() %subplot(1,3,1)

platform_number_unique      = unique(cell2mat(platform_number));
platform_number_unique_cols = parula(length(platform_number_unique));
for i=1:length(platform_number_unique)
    clear msk;msk = cell2mat(platform_number) == platform_number_unique(i);
    plot(cell2mat(lon(msk)),cell2mat(lat(msk)),'.','markersize',30,'color',platform_number_unique_cols(i,:))
    hold on
    leg{i} = ['#' num2str(platform_number_unique(i))];
    
end
geoshow('landareas.shp', 'FaceColor', 'black');  
set(gca,'xlim',[min(cell2mat(lon)) max(cell2mat(lon))]+[-5 8],...
    'ylim',[min(cell2mat(lat)) max(cell2mat(lat))]+[-5 8],...
    'fontsize',fntsz)
xlabel('Longitude')
ylabel('Latitude')
title([xaxis_var ' profiles'])
legend(leg,'location','northwest','fontsize',.8*fntsz,'NumColumns',2)

%
nexttile() %subplot(1,3,2)
eval(['bfrx = ' xaxis_var ';']); eval(['bfry = ' yaxis_var ';'])
for i=1:length(platform_number_unique)
    disp(num2str(platform_number_unique(i)))
    clear *msk;msk = cell2mat(platform_number) == platform_number_unique(i);
    bfrx_msk = bfrx(msk);bfry_msk = bfry(msk);
    for j=1:length(bfrx_msk)
        plot(bfrx_msk{j},bfry_msk{j},'-',...
            'color',platform_number_unique_cols(i,:),'linewidth',1.5)
        hold on
    end
%     pause
end
set(gca,'fontsize',fntsz)%,'xscale','log')
axis ij
xlabel([xaxis_var ', ' xaxis_var_units])
ylabel(yaxis_var)
title('WMO # in color')

% add one more panel

nexttile() %axes('position',[.55    0.25    0.15    0.75])
eval(['bfrc = ' xaxis_var '_qc;'])
n = 0;
for i=1:length(platform_number_unique)
    clear *msk;msk = cell2mat(platform_number) == platform_number_unique(i);
    bfrx_msk = bfrx(msk);bfry_msk = bfry(msk);bfrc_msk = bfrc(msk);
    disp([num2str(platform_number_unique(i)) ' = ' num2str(length(bfrx_msk)) ';'])
    
    for j=1:length(bfrx_msk)
        n = n + 1;
        scatter(bfrx_msk{j},bfry_msk{j},8,bfrc_msk{j},'filled')
        hcb = colorbar('horizontal');
        hold on
        
    end

end
axis ij
%ylabel(yaxis_var)
colormap(jet(9));caxis([.5 9.5])
xlabel([xaxis_var ', ' xaxis_var_units])
title(['QC flag in color'])
axis tight
set(gca,'fontsize',fntsz)%,'xscale','log')
%
nexttile() %subplot(1,3,3)
n = 0;

hpl = [];

col_txt = .3.*[1 1 1];
mrk     = {'s' '^'};
for i=1:length(platform_number_unique)
    clear *msk;msk = cell2mat(platform_number) == platform_number_unique(i);
    bfrx_msk = bfrx(msk);bfry_msk = bfry(msk);bfrc_msk = bfrc(msk);
    disp([num2str(platform_number_unique(i)) ' = ' num2str(length(bfrx_msk)) ';'])
    
    for j=1:length(bfrx_msk)
        n = n + 1;
        scatter(n.*ones(size(bfrx_msk{j})),bfry_msk{j},16,bfrc_msk{j},'filled','marker',mrk{mod(i,2)+1})
        hcb = colorbar('horizontal');
        hold on
        if j==1 && j~=length(bfrx_msk) 
            ind_start_bfr = n;
        elseif j==1 && j==length(bfrx_msk) 
            ind_start_bfr = n;
            plot(ind_start_bfr.*[1 1],[-10 -10],'s','markersize',10,'MarkerFaceColor','k','MarkerFaceColor',platform_number_unique_cols(i,:))
            
        elseif j==length(bfrx_msk)
            
            plot(ind_start_bfr.*[1 1],[-10 -10],'s','markersize',10,'MarkerFaceColor','k','MarkerFaceColor',platform_number_unique_cols(i,:))
            
            
        end
    end

end
set(gca,'fontsize',fntsz)%,'position',get(gca,'position')+[-dx 0 dx 0])
axis ij
xlabel('Index')
colormap(jet(9));caxis([.5 9.5])
title('QC flag in color')
axis tight

set(gcf,'PaperPositionMode','auto');
print('-dpng',[xaxis_var '_' tag_region '_' ...
    datestr(min(t),'mmmyyyy') '_' datestr(max(t),'mmmyyyy') '.png'],'-r150')

