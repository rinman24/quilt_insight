function [] = cpr_annual_csv(filename, year, daysInYear, ulocs, daily_samples, res)

% These are the list of locations where data exists
lat_lon_pairs = csvread(filename);

% String used to programatically access the day of year from .mat files
doy = 'DOY';

% Calculate the length of the reshaped sample
reshape_coef = (1/res)^2; 

% Calculate the re-scale vector
scale_vec = ones(reshape_coef, 1);

% Make a vector for the year
yr_vec = year*scale_vec;

% Number of unique locations in the dataset
for coord = 1:ulocs
    % Placeholder the the result that will be returned
    result = [];
    
    % Grab the location from the from the strings in
    % 'SolarAnywhere_Lat_Lon.csv'
    lat = lat_lon_pairs(coord, 1);
    lon = lat_lon_pairs(coord, 2);
    
    % Build a meshgrid for location purposes
    [LAT, LON] = meshgrid([lon:-res:lon-1+res], [lat:res:lat+1-res])
    lat_vec = reshape(LAT, [reshape_coef, 1]);
    lon_vec = reshape(LON, [reshape_coef, 1]);
    
    % Build the location string
    loc_str = strcat('N', num2str(lat), 'W', num2str(abs(lon)));
    
    % Load the .mat file into variable 
    variable = load(strcat(loc_str, '.mat'));
    
    % Build a year string to access tables
    yr_str = strcat('Y', num2str(year));
    
    % For each hour in the samples
    for hour = 1:daily_samples
        % Build an hour vector
        hour_vec = (hour-1)/2*scale_vec;
        
        % For each day of the year
        for day = 1:daysInYear
            % Get ghi vector
            ghi = reshape(variable.(loc_str).(yr_str).(strcat(doy, num2str(day))).GHI(:,:,hour),...
                          [reshape_coef, 1]);
            % Get dni vector
            dni = reshape(variable.(loc_str).(yr_str).(strcat(doy, num2str(day))).DNI(:,:,hour),...
                          [reshape_coeff, 1]);
            % Build a day vector
            day_vec = day*scale_vec;
            
            % Construct the daily result
            daily_res = [ghi, dni, lat_vec, lon_vec, hour_vec, day_vec, yr_vec];
        end
        % Append the daily result
        result = [result; daily_res];
    end
    % Write the year for the given location to a csv.
    csvwrite(strcat('csv/',loc_str,'_',num2str(year),'.csv'), result);
end
end