function data_out = Argovis_get_profiles(url,bgc_mode) %#ok<STOUT>
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
% url: url for API query of interest
% if bgc_mode is equal to 1, then we are in bgc mode, i.e. profiles for bgc
% Argo are returned, along with the QC flag. No QC-based selection is done
% for bgc Argo (Tucker et al. 2020). All the profiles are included, even if
% the QC flag is bad.
%
% OUTPUT
% this function returns measurements that can be accessed by the url query
% in input (along with their pressure, longitude, latitude, time for each 
% profile, and QC if available). More metadata can be read in for
% each profile: to do this, the function needs to be updated editing "vars". Please
% contact us if you have questions on how to do this: we are happy to help.
%
% webread options (for API query)
opt = weboptions('Timeout',30,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/', 'CertificateFilename','');
vars= {...
    'temp' 'temp_qc' ...
    'pres' 'pres_qc' ...
    'psal' 'psal_qc' ...
    'doxy' 'doxy_qc' ...
    'bbp' 'bbp_qc' ...
    'bbp470' 'bbp470_qc' ...
    'bbp532' 'bbp532_qc' ...
    'bbp700' 'bbp700_qc' ...
    'turbidity' 'turbidity_qc' ...
    'cp' 'cp_qc' ...
    'cp660' 'cp660_qc' ...
    'chla' 'chla_qc' ...
    'cdom' 'cdom_qc' ...
    'nitrate' 'nitrate_qc' ...
    'bisulfide' 'bisulfide_qc' ...
    'ph_in_situ_total' 'ph_in_situ_total_qc' ...
    'down_irradiance' 'down_irradiance_qc' ...
    'down_irradiance380' 'down_irradiance380_qc' ...
    'down_irradiance412' 'down_irradiance412_qc' ...
    'down_irradiance443' 'down_irradiance443_qc' ...
    'down_irradiance490' 'down_irradiance490_qc' ...
    'down_irradiance555' 'down_irradiance555_qc' ...
    'up_radiance' 'up_radiance_qc' ...
    'up_radiance412' 'up_radiance412_qc' ...
    'up_radiance443' 'up_radiance443_qc' ...
    'up_radiance490' 'up_radiance490_qc' ...
    'up_radiance555' 'up_radiance555_qc' ...
    'downwelling_par' 'downwelling_par_qc' ...
    'date' 'lon' 'lat' ...
    'cycle_number' 'platform_number' 'x_id'};
%
if bgc_mode==1
    meas_mode = 'bgcMeas';
else
    meas_mode = 'measurements';
end

for i=1:length(vars)
    eval([vars{i} ' = {};'])
end

disp(url)
tic;data = webread(url,opt);toc;

data_out = [];
if ~isempty(data)
    for i=1:length(data)
        for j=1:length(vars)
            eval(['clear ' vars{j} '0'])
        end
        
        for j=1:length(vars)
            if iscell(data)
                if eval(['isfield(data{i}.' meas_mode ',vars{j})'])
                    eval([vars{j} '0 = ' ...
                        'return_field_from_cell({data{i}.' meas_mode '.' ...
                        vars{j} '});'])
                else
                    try
                        eval([vars{j} '0 = return_field_from_cell({data{i}.' vars{j} '});'])
                    catch
                        %disp([vars{j} ' was not found: is the name entered correct?'])
                    end
                end
            elseif isstruct(data)
                if eval(['isfield(data(i).' meas_mode ',vars{j})'])
                    eval([vars{j} '0 = ' ...
                        'return_field_from_cell({data(i).' meas_mode '.' ...
                        vars{j} '});'])
                else
                    try
                        eval([vars{j} '0 = return_field_from_cell({data(i).' vars{j} '});'])
                    catch
                        %disp([vars{j} ' was not found: is the name entered correct?'])
                    end
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
        % check if there are variables that are not included in vars
        flds = {};
        try
            if iscell(data) && ~isempty(eval(['data{i}.' meas_mode]))
                flds = eval(['fieldnames(data{i}.' meas_mode ')']);
            elseif isstruct(data) && ~isempty(eval(['data(i).' meas_mode]))
                flds = eval(['fieldnames(data(i).' meas_mode ')']);
            end
            
            if length(unique({vars{:} flds{:}})) > ...
                    length(vars)
                disp('Check new (or not recognized) variable name')
%                 vars{:}
%                 flds{:}
                %pause
            end
        catch
            disp('Check error')
            %pause;
        end
        
    end
end

for i=1:length(vars)
    clear bfr; bfr = cellfun(@isempty,eval([vars{i} ]));
    if sum(bfr)~=length(bfr)
        eval(['data_out.' vars{i} ' = ' vars{i} ';'])
    end
end

end
function data_out = return_field_from_cell(data_in) %#ok<DEFNU>
fx=@(x)any(isempty(x));
ind=cellfun(fx,data_in);
data_in(ind)={nan};
data_out = cell2mat(data_in);
end