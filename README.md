# Argovis
You can try one of the examples, running one of the scripts that includes the word "example" in the file name.
Other scripts are functions that are needed to run the examples.
We are still working to provide a more detailed description for each script. Also, more scripts will be available in the future. PLEASE ASK US IF YOU HAVE ANY QUESTIONS! WE ARE HAPPY TO HELP!

BGC API in Python (work in progress)
argovis_bgc_python_api.ipynb
Retrieves BGC data, but does not plot it.

EC2020_argovis_python_api_js.ipynb
This is the same notebook as the one prepared for the meeting, seen here https://github.com/earthcube2020/ec20_tucker_etal, but uses basemap rather than cartopy to plot.  

All Matlab scripts (*.m) are written for Matlab2020.  Older versions of Matlab may work, especially with small changes related to creating pathways and directories. 

Most all scripts allow you to set the pathways for saved data and figures created when running a script.  Please adjust pathway names as needed and remember that the slashes go in different directions for Windows and Mac/Linux machines.   

Argovis_profile_example.m
This script retrieves one profile from Argovis, saves it as a netCDF file and plots the profiles based on available variables.
Inputs:  float WMO number and cycle number
Outputs:  data from profile comes back as a structure named 'data'.  This profile data is saved in a netCDF file(s) with float data, plots for available variables (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  

Argovis_platform_example.m
This script retrieves all the data available for a platform, saves it as a netCDF file and plots the data as a scatter plot and contour plot for each available variable.
Inputs:  platform number(float WMO number) and pressure axis values to be used for interpolation when making the contour plots.
Outputs: data from profile comes back as a structure named 'data_out'.  The data is saved in a netCDF file(s) for each variable. Three plots are made for each available variables (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  

Argovis_regional_query_example.m
This script retrieves profiles in a region and time period of interest.  You can choose to retrieve just the BGC profiles or all profiles with the core variables (temp/psal/pres).  Retrieving Deep Argo data is coming soon.  The data are saved as netCDF files and plots are made showing profile locations, profile plots and profile QC plots if you are using the BGC call.  
Inputs:  region, time period, pressure range and examples2run(either BGC or T/S/p).  The region can either be defined as a simple box (lon_min, lon_max, lat_min, lat_max) or it can be copied from the URL of a shape drawn in the Argovis browser.  Times can be entered in two different formats:  specific_months or from_to.  From_to is pretty straight forward:  you enter a starting and ending month. Specific months allows you to see the same specified months over the years of interested.  In other words, if you specificy 1:3 for months and 2017:2019, the data returned will be for the January, February and March of 2017, 2018 and 2019.  
Outputs:  data from the region comes back as a structure named 'data_out'.  The data is saved in a netCDF file(s) for each profile and for each variable. Plots are made showing the location of the profiles and profile plots for each available variable (temp, psal for core variables, and doxy, chla, etc. for BGC variables).  If it is a BGC profile, the profile QC plots will also be shown.




