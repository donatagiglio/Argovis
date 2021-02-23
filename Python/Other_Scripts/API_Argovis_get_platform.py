# made for Python 3.  It may work with Python 2.7, but has not been well tested

# libraries to call for all python API calls on Argovis

import requests
import pandas as pd
import os


#####
# Get current directory to save file into

curDir = os.getcwd()



# Get a platform from Argovis using pandas dataframe to get profile and save it as a csv file

def get_platform_profiles(platform_number):
    resp = requests.get('https://argovis.colorado.edu/catalog/platforms/'+platform_number)
    # Consider any status other than 2xx an error
    if not resp.status_code // 100 == 2:
        return "Error: Unexpected response {}".format(resp)
    platformProfiles = resp.json()
    return platformProfiles

def parse_into_df(profiles):
    #initialize dict
    meas_keys = profiles[0]['measurements'][0].keys()
    df = pd.DataFrame(columns=meas_keys)
    for profile in profiles:
        profileDf = pd.DataFrame(profile['measurements'])
        profileDf['cycle_number'] = profile['cycle_number']
        profileDf['profile_id'] = profile['_id']
        profileDf['lat'] = profile['lat']
        profileDf['lon'] = profile['lon']
        profileDf['date'] = profile['date']
        df = pd.concat([df, profileDf])
    return df
 
platformProfiles = get_platform_profiles('3900737')
platformDf = parse_into_df(platformProfiles)
print('number of measurements {}'.format(platformDf.shape[0]))

platformDf.head()

# get the mean of the measurements

platformDf[['pres', 'psal', 'temp']].mean(0)

# save file

platformDf.to_csv(os.path.join(curDir,'platform.csv'))


