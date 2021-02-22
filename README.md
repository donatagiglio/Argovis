# Argovis

Welcome to the Argovis GitHub repository!  The scripts in this repository access Argovis (https://argovis.colorado.edu/), a RESTful web app, which contains Argo data, weather events and more. This directory is organized into folders by language, ie Matlab and Python.  Inside the folders are scripts to access Argovis; some scripts simply access the database, while others get data, manipulate it and produce plots.  Each script will be described in this README file, by language, with newer scripts being added at the bottom of each language section.  Further script develeopment is underway, so please check back in the future. PLEASE ASK US IF YOU HAVE ANY QUESTIONS! WE ARE HAPPY TO HELP!

# Python
**Python_Notebooks**

**EC2020_Argovis_Python.md**
This file contains a link to the Python Jupyter Notebook developed for the EarthCube 2020 meeting to demonstrate Argovis's API capabilities. Here is the link: https://github.com/earthcube2020/ec20_tucker_etal
This Jupyter notebook provides a set of functions for users to retrieve Argo float profiles, platforms, metadata, spatial-temporal selections, and gridded products (including weather events) stored on Argovis. Charts and simple calculations made by the output of these functions provide users the means to write their python scripts. We have bundled the required libraries into a Docker container so that users do not need to install python libraries manually. All software dependencies are installed in the Docker container and run the notebooks within the docker environment. Instructions on how to build and run the container are included.

**EC2020_argovis_python_api_js.ipynb**
This is the same notebook as prepared for the Earth Cube 2020 meeting, seen here https://github.com/earthcube2020/ec20_tucker_etal, but uses basemap rather than cartopy to plot. Here is the description of that 
We provide a set of functions in a Jupyter notebook for users to retrieve Argo float profiles, platforms, metadata, spatial-temporal selections, and gridded products (including weather events) stored on Argovis. Charts and simple calculations made by the output of these functions provide users the means to write their python scripts. We have bundled the required libraries into a Docker container so that users do not need to install python libraries manually. All software dependencies are installed in the Docker container and run the notebooks within the docker environment. Instructions on how to build and run the container are included.

**argovis_bgc_python_api.ipynb**
This BGC API in Python is a work in progress and it retrieves BGC data, but does not plot it.

**Other Scripts**

All scripts in this folder are written for Python 3.  They may work on Python 2.7, but they have not been tested.

**API_Argovis_get_profile.py**
This script retrieves an Argo profile from Argovis and saves it as a csv file.
Input:  float WMO number and cycle number
Output:  data from profile comes back as a dictionary named 'profileDict' and saves it to a csv file called 'profile.csv'.

**API_Argovis_get_platform.py**
This script retrieves all the profiles from an Argo platform/float in Argovis and saves it as a csv file.
Input:  float WMO number
Output:  data from platform comes back as a dictionary named 'platformDf' and saves it to a csv file called 'platform.csv'.

**API_Argovis_get_data_region.py**
This script retrieves all Argo profiles in a selected region and time from Argovis and saves it as a csv file.
Input:  start date and end date as well as a shape for the region.  The coordinates from a drawn shape on the Argovis browser can be copied from the URL and pasted in.
Output:  data from platform comes back as a dictionary named 'selectionProfiles' and saves it to a csv file called 'region.csv'.

**API_Argovis_get_global_metadata.py**
This script retrieves profile metadata globally for a time period of interest and saves it as a csv file.
Input:  month and year of interest
Output:  data from platform comes back as a dictionary named 'metaDf' and saves it to a csv file called 'meta.csv'.


# Matlab
All Matlab scripts (*.m) are written for Matlab2020.  Older versions of Matlab may work, especially with small changes related to creating pathways and directories. 

Most all scripts allow you to set the pathways for saved data and figures created when running a script.  Please adjust pathway names as needed and remember that the slashes go in different directions for Windows and Mac/Linux machines.   

Scripts with the word **'example'** in them are the main scripts and the other ones are functions called in the various 'example' scripts.

**Argovis_profile_example.m**
This script retrieves one profile from Argovis, saves it as a netCDF file and plots the profiles based on available variables.
Inputs:  float WMO number and cycle number
Outputs:  data from profile comes back as a structure named 'data'.  This profile data is saved in a netCDF file(s) with float data, plots for available variables (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  

**Argovis_platform_example.m**
This script retrieves all the data available for a platform, saves it as a netCDF file and plots the data as a scatter plot and contour plot for each available variable.
Inputs:  platform number(float WMO number) and pressure axis values to be used for interpolation when making the contour plots.
Outputs: data from profile comes back as a structure named 'data_out'.  The data is saved in a netCDF file(s) for each variable. Three plots are made for each available variables (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  

**Argovis_regional_query_example.m**
This script retrieves profiles in a region and time period of interest.  You can choose to retrieve just the BGC profiles or all profiles with the core variables (temp/psal/pres).  Retrieving Deep Argo data is coming soon.  The data are saved as netCDF files and plots are made showing profile locations, profile plots and profile QC plots if you are using the BGC call.  
Inputs:  region, time period, pressure range and examples2run(either BGC or T/S/p).  The region can either be defined as a simple box (lon_min, lon_max, lat_min, lat_max) or it can be copied from the URL of a shape drawn in the Argovis browser.  Times can be entered in two different formats:  specific_months or from_to.  From_to is pretty straight forward:  you enter a starting and ending month. Specific months allows you to see the same specified months over the years of interested.  In other words, if you specificy 1:3 for months and 2017:2019, the data returned will be for the January, February and March of 2017, 2018 and 2019.  
Outputs:  data from the region comes back as a structure named 'data_out'.  The data is saved in a netCDF file(s) for each profile and for each variable. Plots are made showing the location of the profiles and profile plots for each available variable (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  If it is a BGC profile, the profile QC plots will also be shown.

**Argovis_get_bgc_profiles_in_shape_example_v2.m**
This script retrieves BGC profiles in a region and time period of interest. The region can either be defined as a simple box (lon_min, lon_max, lat_min, lat_max) or it can be copied from the URL of a shape drawn in the Argovis browser.  A time period is set by entering years, months of interest as well as exact ending years and month.
Inputs:  region, time period, and maximum pressure.  The region can either be defined as a simple box (lon_min, lon_max, lat_min, lat_max) or it can be copied from the URL of a shape drawn in the Argovis browser.  Times are entered as years and months of interest as well as the exact ending month and year.  This allows users to look at partial years.  In other words, if you enter 2019:2020 as years, 1:12 as mm_ALL, end_month = 6, and end_year = 2020, data will be retried from January 2019 through June 2020.  
Outputs:  data from the region comes back as a structure named 'data'.  The data is saved in a netCDF file(s) for each profile and for each variable. Plots are made showing the location of the profiles and profile plots for each available BGC variable (doxy, chla, etc. for available BGC variables) as well as the profile QC plots. 

**Argovis_metadata_example.m**
This script retrieves profile metadata globally for a time period of interest and plots the location of the profiles, a histogram of the maximum pressure reached in the temperature profiles and the timeseries of positioning system used by the float.  
Inputs:  start and end times are entered in days, months and years.
Outputs:  metadata comes back as a structure named 'data_out'.  Plots are made showing the location of the profiles, the evolution of the positioning system for each profile over time and a histogram of the maximum pressure reached for each temperature profile.

**Argovis_AR_example.m**
This script retrieves Atmospheric River weather events in a 36-hour window and then also retrieves either core or BGC profiles in the same time and space. Plots are made showing the location of the profiles and profile plots for each available variable (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  If it is a BGC profile, the profile QC plots will also be shown.
Inputs:  Date for Atmospheric River weather event, desired pressure range to retrieve Argo profile data, and selection of either core or BGC Argo profiles to return.
Outputs: profile data comes back as a structure named 'data_out'.  Plots are made showing the location of the profiles and profile plots for each available variable (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  If it is a BGC profile, the profile QC plots will also be shown.

**Argovis_SOSE_sea_ice_coverage.m**
This script retrieves SOSE sea ice coverage in a region and time period of interest and plots it.  All Argo profiles in that region and time, including BGC, are also received and plotted on the same plot.  
Inputs:  Date and region of interest which is a box.
Outputs:  The SOSE sea ice coverage comes back as a structure named 'd' and the Argo profile data comes back in a structure named 'prof'.  Both the sea ice coverage and the Argo profile locations are plotted on a figure that is created and saved starting with the set variable name 'fig_path' and ending with 'SOSE_sea_ice_and_argo.png'.







