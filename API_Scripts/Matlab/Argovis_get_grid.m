function [dgrid_ALL,xgrid,ygrid,dgrid_ALL_time,dgrid_ALL_1D] = ...
    Argovis_get_grid(long_min,long_max,lat_min,lat_max,years,plev,tag_product)
% get all the months for the years of interest in the lon/lat range of
% interest
clear dgrid_ALL xgrid ygrid
n = 0;
opt = weboptions('Timeout',20,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/');

for iyr=1:length(years)
    for mm=1:12
        clear data URL_grid dgrid
        URL_grid = ['https://argovis.colorado.edu/griddedProducts/grid/' ...
            'window?latRange=[' num2str(lat_min) ',' num2str(lat_max) ']&'...
            'lonRange=[' num2str(long_min) ',' num2str(long_max) ']&' ...
            'gridName=' tag_product '&monthYear=' num2str(mm) '-' num2str(years(iyr)) '&presLevel=' num2str(plev) ''];%Total
        try % we do this in case some months are not avilable in the time range selected
            data = webread(URL_grid,opt);
            xgrid = data.xllCorner:data.cellXSize:data.xllCorner+(data.cellXSize*(data.nCols-1));
            ygrid = data.yllCorner:data.cellYSize:data.yllCorner+(data.cellYSize*(data.nRows-1));
            dgrid= reshape(data.zs,length(xgrid),length(ygrid));
            % lat values are sorted from the top left corner so we have to do the next
            % step
            dgrid= dgrid(:,end:-1:1);
            n = n + 1;
            if ~exist('dgrid_ALL','var')
                dgrid_ALL = nan(size(dgrid,1),size(dgrid,2),length(years)*12);
                dgrid_ALL_time = nan(length(years)*12,1);
            end
            dgrid_ALL(:,:,n) = dgrid;
            dgrid_ALL_time(n)= datenum(years(iyr),mm,15);
        end
    end
end
% mask dgrid_ALL so that all the locations are available at all time steps
msk = ~isnan(squeeze(nanmean(squeeze(nanmean(dgrid_ALL,1)),1)));
dgrid_ALL(isnan(repmat(mean(dgrid_ALL(:,:,msk),3),[1 1 size(dgrid_ALL,3)]))) = nan;
% build a time series
clear dgrid_ALL_1D dx dy A A2 x2
dgrid_ALL_1D = nan(size(dgrid_ALL,3),1);
dx      = unique(xgrid(2:end)-xgrid(1:end-1));
dy      = unique(ygrid(2:end)-ygrid(1:end-1));
A       = area_of_grid_point(ygrid,dx,dy);
[A2,x2] = meshgrid(A,xgrid);
for l=1:length(dgrid_ALL_1D)
    clear data2D
    data2D = squeeze(dgrid_ALL(:,:,l));
    dgrid_ALL_1D(l) = area_weighted_ave(data2D(:),A2(:));
end
end
