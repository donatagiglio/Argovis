function data_out = Argovis_get_Argo_metadata(month_of_interest,year_of_interest)
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
% INPUT:
% month_of_interest: 1 to 12 according to what month you would like
% metadata for
% year_of_interest : e.g. 2006 according to what year you would like
% metadata for
%
% OUTPUT
% data_out is a structure and contains metadata for the month and year of interest
%
% query info
vars= {'x_id' 'POSITIONING_SYSTEM' 'PI_NAME' 'VERTICAL_SAMPLING_SCHEME' ...
    'DATA_MODE' 'PLATFORM_TYPE' 'station_parameters' 'date' 'date_added'  ...
    'date_qc' 'lat' 'lon' 'position_qc' 'cycle_number' 'dac' 'platform_number' ...
    'BASIN' 'containsBGC' 'isDeep' 'pres_max_for_TEMP' 'pres_min_for_TEMP' ...
    'pres_max_for_PSAL' 'pres_min_for_PSAL'};

for i=1:length(vars)
    eval([vars{i} ' = {};'])
end

url = ['http://argovis.colorado.edu/selection/profiles/' ...
                num2str(month_of_interest) '/' num2str(year_of_interest) '/'];
disp(url)
opt = weboptions('Timeout',40,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/', 'CertificateFilename','');
data = webread(url,opt);

data_out = [];
if ~isempty(data)
    for i=1:length(data)
        for j=1:length(vars)
            eval(['clear ' vars{j} '0'])
        end
        
        for j=1:length(vars)
            try
                eval([vars{j} '0 = data{i}.' vars{j} ';'])
            catch
                try
                    eval([vars{j} '0 = data(i).' vars{j} ';'])
                catch
                end
            end
        end
        %
        for j=1:length(vars)
            if exist([vars{j} '0'],'var') && ~strcmp([vars{j} '0'],'date0')
                eval([vars{j} '{end+1} = ' vars{j} '0;'])
            elseif ~strcmp([vars{j} '0'],'date0')
                eval([vars{j} '{end+1} = [];'])
            end
        end
        date{end+1} = datenum(str2num(date0(1:4)),str2num(date0(6:7)),str2num(date0(9:10)),...
            str2num(date0(12:13)),str2num(date0(15:16)),str2num(date0(18:19)));
    end
end

for i=1:length(vars)
    clear bfr; bfr = cellfun(@isempty,eval([vars{i} ]));
    if sum(bfr)~=length(bfr)
        eval(['data_out.' vars{i} ' = ' vars{i} ';'])
    end
end

end

% fx=@(x)x.lon;
% test = arrayfun(fx,data{:});
% function data_out = return_field_from_cell(data_in) %#ok<DEFNU>
% fx=@(x)any(isempty(x));
% ind=cellfun(fx,data_in);
% data_in(ind)={nan};
% data_out = cell2mat(data_in);
% end