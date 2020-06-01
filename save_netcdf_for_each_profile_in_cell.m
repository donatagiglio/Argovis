function save_netcdf_for_each_profile_in_cell(data,var2save_in_nc,var2save_in_nc_units,path_out_nc)
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
% This function saves a netcdf file for each of the profiles in the cells 
% in data. The file's name is based on the platform and cycle number. 
% Variables to save are listed in var2save.


for i=1:length(data)
    clear filename_out mySchema
    if isfield(data,'pres') && ~isempty(data.pres{i})
        filename_out = [path_out_nc data.x_id{i} '.nc'];
        if exist(filename_out,'file')~=0
            eval(['! rm ' filename_out])
        end
        % create schema
        clear mySchema
        mySchema.Name   = '/';
        %mySchema.Format = 'classic';%'netcdf4';
        mySchema.Dimensions(1).Name   = 'LONGITUDE';
        mySchema.Dimensions(1).Length = 1;
        mySchema.Dimensions(2).Name   = 'LATITUDE';
        mySchema.Dimensions(2).Length = 1;
        mySchema.Dimensions(3).Name   = 'PRESSURE';
        mySchema.Dimensions(3).Length = length(data.pres{i});
        mySchema.Dimensions(4).Name   = 'TIME';
        mySchema.Dimensions(4).Length = 1;
        
        mySchema.Variables(1).Name   = 'LONGITUDE';
        mySchema.Variables(1).Dimensions = mySchema.Dimensions(1);
        mySchema.Variables(1).Datatype = 'double';
        mySchema.Variables(1).Attributes(1).Name = 'units';
        mySchema.Variables(1).Attributes(1).Value = 'degrees_east';
        mySchema.Variables(1).Attributes(2).Name = 'axis';
        mySchema.Variables(1).Attributes(2).Value = 'X';
        mySchema.Variables(1).Attributes(3).Name = 'point_spacing';
        mySchema.Variables(1).Attributes(3).Value = 'even';
        mySchema.Variables(1).Attributes(4).Name = 'modulo';
        mySchema.Variables(1).Attributes(4).Value = 360;
        mySchema.Variables(1).Attributes(5).Name = 'standard_name';
        mySchema.Variables(1).Attributes(5).Value = 'longitude';
        
        mySchema.Variables(2).Name   = 'LATITUDE';
        mySchema.Variables(2).Dimensions = mySchema.Dimensions(2);
        mySchema.Variables(2).Datatype = 'double';
        mySchema.Variables(2).Attributes(1).Name = 'units';
        mySchema.Variables(2).Attributes(1).Value = 'degrees_north';
        mySchema.Variables(2).Attributes(2).Name = 'axis';
        mySchema.Variables(2).Attributes(2).Value = 'Y';
        mySchema.Variables(2).Attributes(3).Name = 'point_spacing';
        mySchema.Variables(2).Attributes(3).Value = 'even';
        mySchema.Variables(2).Attributes(4).Name = 'standard_name';
        mySchema.Variables(2).Attributes(4).Value = 'latitude';

        mySchema.Variables(3).Name   = 'PRESSURE';
        mySchema.Variables(3).Dimensions = mySchema.Dimensions(3);
        mySchema.Variables(3).Datatype = 'double';
        mySchema.Variables(3).Attributes(1).Name = 'units';
        mySchema.Variables(3).Attributes(1).Value = 'dbar';
        mySchema.Variables(3).Attributes(2).Name = 'axis';
        mySchema.Variables(3).Attributes(2).Value = 'Z';
        mySchema.Variables(3).Attributes(3).Name = 'positive';
        mySchema.Variables(3).Attributes(3).Value = 'down';
        mySchema.Variables(3).Attributes(4).Name = 'point_spacing';
        mySchema.Variables(3).Attributes(4).Value = 'uneven';
        mySchema.Variables(3).Attributes(5).Name = 'standard_name';
        mySchema.Variables(3).Attributes(5).Value = 'depth';
        
        mySchema.Variables(4).Name   = 'TIME';
        mySchema.Variables(4).Dimensions = mySchema.Dimensions(4);
        mySchema.Variables(4).Datatype = 'double';
        mySchema.Variables(4).Attributes(1).Name = 'units';
        mySchema.Variables(4).Attributes(1).Value = 'days since 0000-00-00 00:00:00';
        mySchema.Variables(4).Attributes(2).Name = 'time_origin';
        mySchema.Variables(4).Attributes(2).Value = '00-00-0000 00:00:00';
        mySchema.Variables(4).Attributes(3).Name = 'axis';
        mySchema.Variables(4).Attributes(3).Value = 'T';
        mySchema.Variables(4).Attributes(4).Name = 'standard_name';
        mySchema.Variables(4).Attributes(4).Value = 'time';

        n = 5;
        for j=1:length(var2save_in_nc)
            mySchema.Variables(n).Name   = var2save_in_nc{j};
            mySchema.Variables(n).Dimensions = mySchema.Dimensions(1:4);
            mySchema.Variables(n).Datatype = 'double';
            mySchema.Variables(n).Attributes(1).Name = 'long_name';
            mySchema.Variables(n).Attributes(1).Value = var2save_in_nc{j};
            mySchema.Variables(n).Attributes(2).Name = 'units';
            mySchema.Variables(n).Attributes(2).Value = var2save_in_nc_units{j};
            mySchema.Variables(n).Attributes(3).Name = 'missing_value';
            mySchema.Variables(n).Attributes(3).Value = -999;
            n = n+1;
        end
        
        
        
        % write schema
        ncwriteschema(filename_out, mySchema);
        
        % write data
        dim2add      = {'LONGITUDE' 'LATITUDE' 'PRESSURE' 'TIME'};
        dim2add_name = {'data.lon{i}' 'data.lat{i}' 'data.pres{i}' 'data.date{i}'};
        for j=1:length(dim2add)
            clear var_bfr;eval(['var_bfr = ' dim2add_name{j} ''';'])
            ncwrite(filename_out,dim2add{j},var_bfr)
        end
        for j=1:length(var2save_in_nc)
            clear var_bfr*;eval(['var_bfr = data.' var2save_in_nc{j} '{i};'])
            var_bfr(isnan(var_bfr)) = -999;
            var_bfr4d          = nan(1,1,size(var_bfr,2),1);
            var_bfr4d(1,1,:,1) = var_bfr;
            ncwrite(filename_out,var2save_in_nc{j},var_bfr4d(:,:,:,1))
        end
    end
end
return