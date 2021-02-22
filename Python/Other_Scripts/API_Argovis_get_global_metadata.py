# made for Python 3.  It may work with Python 2.7, but has not been well tested

# libraries to call for all python API calls on Argovis

import requests
import pandas as pd
import os


#####
# Get current directory to save file into

curDir = os.getcwd()

#####
# Get monthly metadata

def get_monthly_profile_pos(month, year):
    baseURL = 'https://argovis.colorado.edu/selection/profiles'
    url = baseURL + '/' + str(month) + '/' + str(year)
    resp = requests.get(url)
    # Consider any status other than 2xx an error
    if not resp.status_code // 100 == 2:
        return "Error: Unexpected response {}".format(resp)
    monthlyProfilePos = resp.json()
    return monthlyProfilePos

def parse_meta_into_df(profiles):
    #initialize dict
    df = pd.DataFrame(profiles)
    if df.shape[0] == 0:
        return 'error: no dataframes'
    return df


# set month and year for metadata
month = 1
year = 2004
metaProfiles = get_monthly_profile_pos(month, year)
metaDf = parse_meta_into_df(metaProfiles)


# save file

metaDf.to_csv(os.path.join(curDir,'meta.csv'))
