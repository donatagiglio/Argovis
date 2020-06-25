function output = area_weighted_ave(data,area_at_each_gridpoint)
% output = area_weighted_ave(data,area_at_each_gridpoint)
%
% area weigthed avereage of data, based on the area_at_each_gridpoint given
% in input. Both input variables should be 1D. The output is a number with
% the area weigthed average of the input vector (considering the points
% that are not nan)
%
% to find the area of a grid point you could use area_of_grid_point.m
% Example for 2D data (but data does not need to be 2D):
%   dx = unique(LONGITUDE(2:end)-LONGITUDE(1:end-1));
%   dy = unique(LATITUDE(2:end)-LATITUDE(1:end-1));
%   A = area_of_grid_point(LATITUDE,dx,dy);
%   [A2,x2] = meshgrid(A,LONGITUDE);
% then:
% data_area_weighted_ave = area_weighted_ave(data2D(:),A2(:))
if sum(isnan(area_at_each_gridpoint))~=0
    check
end
output = sum(data(~isnan(data)).*...
    area_at_each_gridpoint(~isnan(data)))/...
    sum(area_at_each_gridpoint(~isnan(data)));
return