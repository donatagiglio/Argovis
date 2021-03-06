function dataOUT = Argovis_get_regional_days(years,months,days,...
    presRange,shape2use,url_beginning,bgc_mode,...
    var2save_in_nc,var2save_in_nc_units,path_out_nc)
% Description to add for input/output
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
clear t M YR

end_year  = max(years);
end_month = max(months);
%mm_ALL   = min(months):end_month;

if ~isempty(days)
    % if days are included, use those
    end_day   = max(days);
    [YR,M,D]   = meshgrid(years,months,days);
    t        = datenum(YR(:),M(:),D(:));
    t_eomday = t;
    
else
    
    [YR,M]   = meshgrid(years,months);
    t        = datenum(YR(:),M(:),15);
    t_eomday = eomdate(YR(:),M(:));
end

% get the data
for l=1:length(t)
    if ~(year(t(l))==end_year && month((l))==end_month && end_month~=12 && ...
            day(t(l))==end_day )
        clear url data *bfr
        
        url = [url_beginning  ...
            'startDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-' num2str(day(t_eomday(l))) '&endDate=' num2str(year(t(l))) '-' ...
            num2str(month(t(l))) '-' num2str(day(t_eomday(l+1))) '&presRange=' presRange '&' ...
            shape2use];
        % now we upload variables
        data = Argovis_get_profiles(url,bgc_mode);
        
        if ~isempty(data)
            vars = fields(data);
            % need to make sure this float has the desired variable before
            % adding it to the matrix
            if isfield(data,var2save_in_nc)
                for i=1:length(vars)
                    % initialize
                    if ~exist('dataOUT','var') || ...
                            (exist('dataOUT','var') && ~isfield(dataOUT,vars{i}))
                        eval(['dataOUT.' vars{i} ' = {};'])
                    end
                    eval(['dataOUT.' vars{i} ' = cat(1,dataOUT.' vars{i} ',data.' vars{i} ''');'])
                end
            end
        end
    end
end
if exist('dataOUT','var')==1
    % save platform number
    dataOUT.platform_number = {};
    for i=1:length(dataOUT.x_id)
        clear bfr
        bfr = strsplit(dataOUT.x_id{i},'_');
        dataOUT.platform_number{i} = str2double(bfr{1});
    end
else
    dataOUT = [];
end
return
