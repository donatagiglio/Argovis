% this script gets data in a region of interest and makes some plots

clear all



%cd ~/Desktop/plots

set(0, 'DefaultFigureVisible', 'on')


tag_region = 'LabradorSea';%'AR_test'; %

switch tag_region
    
    case 'LabradorSea'
        
        shape2use = ['shape=[[[-58.697569,68.784144],[-60.806944,66.231457],' ...
            '[-63.267882,64.472794],[-63.971007,62.593341],[-62.916319,60.413852],' ...
            '[-61.158507,57.515823],[-57.291319,54.572062],[-52.369444,50.958427],' ...
            '[-49.556944,49.837982],[-46.744444,52.696361],[-44.635069,57.136239],' ...
            '[-44.283507,59.534318],[-51.314757,62.593341],[-54.127257,66.089364],' ...
            '[-58.697569,68.784144]]]'];
        
    case 'AR_test'
        
        shape2use = ['shape=[[[-135,40],[-135,45],[-130,45],[-130,40],[-135,40]]]'];
        
end



years   = 2004:2019;
mm_ALL  = 1:12;
end_month = 8;
end_year  = 2019;

NaN_Argovis = -999;

clear t M YR

[YR,M]   = meshgrid(years,mm_ALL);
t        = datenum(YR(:),M(:),15);
t_eomday = eomdate(YR(:),M(:));
xtickall = [t(1:24:end)' datenum(year(t(end)+30),month(t(end)+30),1)];

pressure           = [5:10:2005];
pressure_edges     = [0 (pressure(2:end)+pressure(1:end-1))/2 2010];
pressure_bins      = 200:200:2000;

T        = nan(length(pressure),length(t));
S        = T;
T_NUM    = T;
S_NUM    = T;

p_max_hist = nan(length(pressure_bins),length(t));

tr_sys_types     = {'ARGOS' 'GPS' 'IRIDIUM' 'OTHER'};
tr_sys_types_NUM = nan(length(tr_sys_types),length(t));

% get the data

disp(datestr(now))
T_cell = {};
S_cell = {};
p_cell = {};
time_cell= {};

% set options for webread

% options = weboptions('Timeout',20);

opt = weboptions('Timeout',40,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/');



for l=1:length(t)
    
    if ~(year(t(l))==end_year && month((l))==end_month)
        
        clear url data
        
        url = ['https://argovis.colorado.edu/selection/profiles/' ...
            '?presRange=[0,2000]&startDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-01&endDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-' num2str(day(t_eomday(l))) '&' ...
            shape2use];
        
        data = webread(url,opt);
        
        % bin the data
        
        if ~isempty(data)
            
            clear T_bfr S_bfr flg_psal tr_sys_bfr
            
            T_bfr        = nan(length(pressure),length(data));
            S_bfr        = T_bfr;
            T_bfr_NUM    = T_bfr;
            S_bfr_NUM    = T_bfr;
            p_max        = nan(length(data),1);
            
            for i=1:length(data)
                clear p0 T0 S0 I t0
                if iscell(data)
                    p0 = return_field_from_cell({data{i}.measurements.pres});
                    T0 = return_field_from_cell({data{i}.measurements.temp});
                    t0 = return_field_from_cell({data{i}.date});
                    
                    flg_psal = isfield(data{i}.measurements,'psal');
                    
                    if flg_psal
                        S0 = return_field_from_cell({data{i}.measurements.psal});
                    end
                    
                    tr_sys_bfr{i} = data{i}.POSITIONING_SYSTEM;
                    
                elseif isstruct(data)
                    disp('In isstruct')
                    pause
                    p0 = return_field_from_cell({data(i).measurements.pres});
                    T0 = return_field_from_cell({data(i).measurements.temp});
                    t0 = return_field_from_cell({data(i).date});
                    
                    flg_psal = isfield(data(i).measurements,'psal');
                    if flg_psal
                        S0 = return_field_from_cell({data(i).measurements.psal});
                    end
                    tr_sys_bfr{i} = data(i).POSITIONING_SYSTEM;
                end
                
                p_max(i) = max(p0);
                
                % check for NaNs
                
                p0(p0==NaN_Argovis) = nan;
                T0(T0==NaN_Argovis) = nan;
                
                if flg_psal
                    S0(S0==NaN_Argovis) = nan;
                end
                
                % find to what bin data belong
                
                I = discretize(p0,pressure_edges);
                
                for k=1:length(pressure)
                    
                    T_bfr(k,i)     = nanmean(T0(I==k));
                    T_bfr_NUM(k,i) = sum(~isnan((T0(I==k))));
                    if flg_psal
                        S_bfr(k,i)     = nanmean(S0(I==k));
                        S_bfr_NUM(k,i) = sum(~isnan((S0(I==k))));
                    end
                end
                
                %
                
                T_cell{end+1} = T0;
                p_cell{end+1} = p0;
                if flg_psal
                    S_cell{end+1} = S0;
                end
                
                time_cell{end+1} = datenum(str2num(t0(1:4)),str2num(t0(6:7)),str2num(t0(9:10)),...
                    str2num(t0(12:13)),str2num(t0(15:16)),str2num(t0(18:19)));
            end
            
            
            
            % hist of pmax
            p_max_hist(:,l) = hist(p_max,pressure_bins);
            
            % positioning system
            
            for ips=1:length(tr_sys_types)
                tr_sys_types_NUM(ips,l) = sum(contains(upper(tr_sys_bfr),tr_sys_types{ips}));
            end
            
            tr_sys_types_NUM(contains(tr_sys_types,'OTHER'),l) = ...
                tr_sys_types_NUM(contains(tr_sys_types,'OTHER'),l) + ...
                sum(~contains(tr_sys_types,'ARGOS') & ...
                ~contains(tr_sys_types,'GPS') & ...
                ~contains(tr_sys_types,'IRIDIUM'));
            
            T(:,l)     = nanmean(T_bfr,2);
            T_NUM(:,l) = nansum(T_bfr_NUM,2);
            
            if flg_psal
                S(:,l)     = nanmean(S_bfr,2);
                S_NUM(:,l) = nansum(S_bfr_NUM,2);
            end
        end
        
        if mod(l,12)==0
            disp([year(t(l)) ': ' datestr(now)])
        end
        
    else
        
        break
        
    end
    
end

disp(datestr(now))



%%

close all

[TIME,PRESSURE] = meshgrid(t,pressure);

fig_pos  = [0.1        0.1       1420        700];

% plot some info about the data in the region

figure('color','w','position',fig_pos.*[1 1 .65 1]);
subplot(2,1,1)
p_max_hist_new = p_max_hist;
p_max_hist_new(p_max_hist_new==0) = nan;

[TB,PB] = meshgrid(t,pressure_bins);
%pcolor(t,pressure_bins,p_max_hist_new);shading flat;colorbar
scatter(TB(:), PB(:), 20, p_max_hist_new(:),'filled','marker','s')
colormap(jet(64))
set(gca,'linewidth',2,'fontsize',22,'xtick',xtickall(1:end-1),'xlim',...
    [xtickall(1) xtickall(end)])
datetick('x','yyyy','keepticks','keeplimits')
axis ij
ylabel('p, dbar')
colorbar('horizontal')

subplot(2,1,2)
%cbfr = single(load('/Users/giglio/Desktop/ACC_JISAO/code/CBR_set3_cbar.dat')./255);
cbfr = jet;
set(0,'DefaultAxesColorOrder',cbfr)

%bar(t,tr_sys_types_NUM','stacked','edgecolor','k')
bar(t,tr_sys_types_NUM','stacked','linestyle','none','barwidth',1)
set(gca,'linewidth',2,'fontsize',22,'xtick',xtickall(1:end-1),'xlim',...
    [xtickall(1) xtickall(end)])

datetick('x','yyyy','keepticks','keeplimits')
legend(tr_sys_types,'location','best')
set(gcf,'PaperPositionMode','auto');
print('-dpng',['meta_info_in_region_' tag_region...
    '_NEW.png'],'-r150')



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%

close all

clear d2pl*

d2pl_tags     = {'T, degC' 'S, psu'};
d2pl(:,:,1,1) = T;
d2pl(:,:,2,1) = S;
d2pl(:,:,1,2) = T;
d2pl(:,:,2,2) = S;
d2pl(:,:,1,3) = T_NUM;
d2pl(:,:,2,3) = S_NUM;
d2pl(:,:,1,4) = T_NUM;
d2pl(:,:,2,4) = S_NUM;

subj = {1 2 3 4};%{1:2 3 4:5 6};
mrk_sz = [7 3 7 3];
flag_lg= [0 0 1 1];

cbar_TS_shallow  = jet(24);%[flipud(cbrewer('seq','YlGnBu',24)); (cbrewer('seq','YlOrRd',24))];
cbar_TS_deep     = jet(24);%[flipud(cbrewer('seq','YlGnBu',20)); (cbrewer('seq','YlOrRd',20))];
cbar_num         = jet(24);%[flipud(cbrewer('seq','YlGnBu',24)); (cbrewer('seq','YlOrRd',24)); flipud(cbrewer('seq','PuRd',24))];

for i=1:size(d2pl,3)
    
    figure('color','w','position',fig_pos.*[1 1 .65 1.2]);
    
    for j=1:size(d2pl,4)
        hs = subplot(4,1,subj{j});
        clear d
        d = reshape(d2pl(:,:,i,j),[],1);
        
        if flag_lg(j)==1
            % Rescale data 1-64
            d(d==0) = nan;
            d       = log10(d);
            mn      = min(d(:));
            rng     = max(d(:))-mn;
            d       = 1+63*(d-mn)/rng; % Self scale data
            
            L       = [0.01 0.02 0.05 0.1 0.2 0.5 1 2 5 10 20 50 100 200 500 1000 2000 5000];
            L_tag   = {'0.01' '0.02' '0.05' '0.1' '0.2' '0.5' '1' '2' '5' '10' '20' '50' '100' '200' '500' '1000' '2000' '5000'};%];
            
            % Choose appropriate or somehow auto generate colorbar labels
            l       = 1+63*(log10(L)-mn)/rng; % Tick mark positions
        end
        
        
        
        scatter(TIME(:),PRESSURE(:),mrk_sz(j),d,'filled');
        hC = colorbar('horizontal');
        axis ij
        set(gca,'linewidth',2,'fontsize',22,'xtick',xtickall(1:end-1),'xlim',...
            [xtickall(1) xtickall(end)])
        datetick('x','yyyy','keepticks','keeplimits')
        ylabel('p, dbar')
        
        
        
        switch j
            case 1
                set(gca,'ylim',[0 300])
                colormap(hs,jet(24))
                if i==1;caxis([ 1 9]);end
            case 2
                set(gca,'ylim',[300 2000])
                colormap(hs,jet(24))
                if i==1;caxis([ 3 5]);end
            case 3
                %title('Number of data averaged in each bin','fontsize',20)
                set(gca,'ylim',[0 300])
                colormap(hs,jet(24))
            case 4
                set(gca,'ylim',[300 2000])
                colormap(hs,jet(24))
        end
        
        
        
        if flag_lg(j)==1
            set(hC,'Ytick',l,'YTicklabel',L_tag);
        end
        
        set(hC,'fontsize',22)
        set(gca,'position',get(gca,'position')+[0 -.035 0 .05])
        
    end
    
    
    set(gcf,'PaperPositionMode','auto');
    print('-dpng',[d2pl_tags{i}(1) '_in_region_' tag_region...
        '_NEW.png'],'-r150')
    
end



function data_out = return_field_from_cell(data_in)

fx=@(x)any(isempty(x));
ind=cellfun(fx,data_in);
data_in(ind)={nan};
data_out = cell2mat(data_in);

end