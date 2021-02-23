# made for Python 3.  It may work with Python 2.7, but has not been well tested

# libraries to call for all python API calls on Argovis

import requests
import pandas as pd
import os


#####
# Get current directory to save file into

curDir = os.getcwd()

#####
# Get a profile from Argovis and return it as a JSON object

def get_profile(profile_number):
    resp = requests.get('https://argovis.colorado.edu/catalog/profiles/'+profile_number)
    # Consider any status other than 2xx an error
    if not resp.status_code // 100 == 2:
        return "Error: Unexpected response {}".format(resp)
    profile = resp.json()
    return profile
####

# Get a profile from Argovis using pandas dataframe to get profile and save it as a csv file

profileDict = get_profile('3900737_279')
profileDf = pd.DataFrame(profileDict['measurements'])
profileDf['cycle_number'] = profileDict['cycle_number']
profileDf['profile_id'] = profileDict['_id']
profileDf.head()

# save file

profileDf.to_csv(os.path.join(curDir,'profile.csv'))

 


