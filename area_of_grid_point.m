function area_out = area_of_grid_point(latitude,dx,dy)
% area_of_grid_point(latitude,dx,dy) where
% latitude is a Nx1 vector and dx, dy are scalars
%
% area_out output is in km2
%%%%
% Example:
% dx = unique(LONGITUDE(2:end)-LONGITUDE(1:end-1));
% dy = unique(LATITUDE(2:end)-LATITUDE(1:end-1));
% A  = area_of_grid_point(LATITUDE,dx,dy);
% [A2,x2] = meshgrid(A,LONGITUDE);

area_out = nan(size(latitude));
for i=1:length(latitude)
    earthellipsoid = referenceSphere('earth','km');
    area_out(i) = areaquad(latitude(i)-(dy/2),...
        1-(dx/2),...
        latitude(i)+(dy/2),...
        1+(dx/2),earthellipsoid);
end

return