clear all
close all

fig_path = '~/Desktop/';

date = '2013-06-01';

% region of interest for sea ice
yreg = [-90,-50];
xreg_ALL = -180:5:180;

fntsz = 20;
PLabelLocation = -80:20:0;

% set up the map
fig_pos   = [0.1    0.1    1500    1200];
figure('color','w','position',fig_pos.*[1 1 1 1]);
hax = axesm('stereo','Origin',[-90 0],'MapLatLimit',[-90 -50],...
    'Frame','on','Grid','on','MeridianLabel','off', ...
    'MLabelLocation',-150:30:180,'LabelRotation','off',...
    'PLabelLocation',PLabelLocation,...
    'ParallelLabel','on','fontweight','bold','PLineLocation',10,'MLineLocation',30,...
    'fontsize',fntsz);

for i=1:length(xreg_ALL)-1

    clear xreg;xreg = [xreg_ALL(i) xreg_ALL(i+1)];

    url = ['https://argovis.colorado.edu/griddedProducts/nonUniformGrid/window?' ...
        'gridName=sose_si_area_1_day_sparse&presLevel=0&' ...
        'latRange=[' num2str(min(yreg)) ', ' num2str(max(yreg)) ']&'...
        'lonRange=[' num2str(min(xreg)) ', ' num2str(max(xreg)) ']&'...
        'date=' date ];
    
    d   = webread(url);
    
    if ~isempty(d)
        lon = [d.data.lon];
        lat = [d.data.lat];
        data= [d.data.value];
        
        scatterm(lat,lon,5,data,'filled')
        
        hold on
    end

end
hcb = colorbar;
set(hcb,'position',[ 0.8    0.303    0.0107    0.4779])
colormap(cmocean('ice'))
geoshow('landareas.shp','FaceColor',[0.85 .85 0.85])
set(gca,'box','off','fontsize',fntsz)

%%%%%%%%%%%% load Argo profile location in a 6 day window starting on the date use for sea ice (this can be changed to any window of interest) 
deltat    = 5; % number of days to include after the start date
startDate = {[num2str(year(datenum(date))) '-' num2str(month(datenum(date))) '-' num2str(day(datenum(date)))] ...
    };
endDate   = {[num2str(year(datenum(date)+deltat)) '-' num2str(month(datenum(date)+deltat)) '-' num2str(day(datenum(date)+deltat))] ...
    };

cols      = {'r' 'g'};
mrk       = {'o' '^'};

delta_long = 10;
long_start = -180:delta_long:170;
lat_min  = max(yreg);
lat_max  = min(yreg);

plev = 20;%10;

tag_region = 'grid_custom';

for i=1:length(startDate)
    for j=1:length(long_start)
        clear shape2use prof
        long_min = long_start(j);
        long_max = long_min+delta_long;

        switch tag_region
            case 'grid_custom'
                shape2use = ['shape=[[[' num2str(long_min) ',' num2str(lat_min) '],['...
                    num2str(long_min) ',' num2str(lat_max) '],[' num2str(long_max) ','...
                    num2str(lat_max) '],[' num2str(long_max) ','...
                    num2str(lat_min) '],[' num2str(long_min) ',' num2str(lat_min) ']]]'];
        end
        
        prof = Argovis_get_profiles_in_box(shape2use,startDate{i},endDate{i},plev);
        
        hold on
        if sum(prof.pos_qc_vec>2)>0
            plotm(prof.y_vec(prof.pos_qc_vec>2),prof.x_vec(prof.pos_qc_vec>2),...
                '.','markersize',10,'marker',mrk{2},...
                'color',cols{i})
            prof.pos_qc_vec(prof.pos_qc_vec>2)
        end
        if sum(prof.pos_qc_vec<=2)>0
            plotm(prof.y_vec(prof.pos_qc_vec<=2),prof.x_vec(prof.pos_qc_vec<=2),...
            '.','markersize',10,'marker',mrk{1},...
            'color',cols{i},'markerfacecolor',cols{i})
        end
    end
end
set(gcf,'PaperPositionMode','auto');
print('-dpng',[fig_path 'SOSE_sea_ice_and_argo.png'])