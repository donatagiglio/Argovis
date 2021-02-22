function d = Argovis_get_profiles_in_box(shape2use,startDate,endDate,plev)
% shape2use,startDate,endDate,plev
% plev  is the pressure level at which you would like to interpolate the profile
% data

NaN_Argovis = -999;

% get the data
disp(datestr(now))
T_cell = {};
S_cell = {};
p_cell = {};
time_cell= {};
x_cell = {};
y_cell = {};
pos_qc_cell = {};

% set options for webread
opt = weboptions('Timeout',20,'UserAgent', 'http://www.whoishostingthis.com/tools/user-agent/');
tic;
clear url data

url = ['https://argovis.colorado.edu/selection/profiles/' ...
    '?presRange=[0,2000]&startDate=' startDate '&endDate=' endDate '&' ...
    shape2use];

data = webread(url,opt);

% bin the data
if ~isempty(data)
    clear T_bfr S_bfr flg_psal tr_sys_bfr
    
    for i=1:length(data)
        
        clear p0 T0 S0 I t0 x0 y0
        if iscell(data)
            p0 = return_field_from_cell({data{i}.measurements.pres});
            T0 = return_field_from_cell({data{i}.measurements.temp});
            t0 = return_field_from_cell({data{i}.date});
            
            flg_psal = isfield(data{i}.measurements,'psal');
            if flg_psal
                S0 = return_field_from_cell({data{i}.measurements.psal});
            end
            x0 = return_field_from_cell({data{i}.lon});
            y0 = return_field_from_cell({data{i}.lat});
            
            pos_qc0 = return_field_from_cell({data{i}.position_qc});
            
        elseif isstruct(data)
            %disp('In isstruct')
            p0 = return_field_from_cell({data(i).measurements.pres});
            T0 = return_field_from_cell({data(i).measurements.temp});
            t0 = return_field_from_cell({data(i).date});
            
            flg_psal = isfield(data(i).measurements,'psal');
            if flg_psal
                S0 = return_field_from_cell({data(i).measurements.psal});
                %                         S0 = [data(i).measurements.psal];
            end
            x0 = return_field_from_cell({data(i).lon});
            y0 = return_field_from_cell({data(i).lat});
            pos_qc0 = return_field_from_cell({data(i).position_qc});
           
        end
        
        % check for NaNs
        p0(p0==NaN_Argovis) = nan;
        T0(T0==NaN_Argovis) = nan;
        if flg_psal
            S0(S0==NaN_Argovis) = nan;
        end
        if length(T0)>2 && length(p0)>2
            T_cell{end+1} = interp1(p0,T0,plev);
            p_cell{end+1} = plev;
            if flg_psal
                S_cell{end+1} = interp1(p0,S0,plev);
            else
                S_cell{end+1} = nan;
            end
            time_cell{end+1} = datenum(str2num(t0(1:4)),str2num(t0(6:7)),str2num(t0(9:10)),...
                str2num(t0(12:13)),str2num(t0(15:16)),str2num(t0(18:19)));
            x_cell{end+1} = x0;
            y_cell{end+1} = y0;
            
            pos_qc_cell{end+1} = pos_qc0;
        end
    end
    
    
end

disp(datestr(now))
toc;

clear d
d.S_vec    = return_field_from_cell(S_cell);
d.T_vec    = return_field_from_cell(T_cell);
d.time_vec = return_field_from_cell(time_cell);
d.x_vec    = return_field_from_cell(x_cell);
d.y_vec    = return_field_from_cell(y_cell);
d.pos_qc_vec= return_field_from_cell(pos_qc_cell);
end
function data_out = return_field_from_cell(data_in)
fx=@(x)any(isempty(x));
ind=cellfun(fx,data_in);
data_in(ind)={nan};
data_out = cell2mat(data_in);
end