# Argovis API exposed in a Python Jupyter notebook: an easy access to Argo profiles, weather events, and gridded products

*Tyler Tucker, Donata Giglio, Megan Scanderbeg*

Web 2.0 data delivery and visualization services have improved Earth system science workflows, yet scientists and researchers working with these applications require customized features that are not available on an application running on the browser. Tailoring Argovis’s data throughput so that users can gather data for their myriad tasks requires us to expose the underworkings of our Application Programming Interface (API). We provide a set of functions in a Jupyter notebook for users to retrieve Argo float profiles, platforms, metadata, spatial-temporal selections, and gridded products (including weather events) stored on Argovis. Charts and simple calculations made by the output of these functions provide users the means to write their python scripts. We have bundled the required libraries into a Docker container so that users do not need to install python libraries manually. All software dependencies are installed in the Docker container and run the notebooks within the docker environment. Instructions on how to build and run the container are included. We encourage users to improve, and expand these routines, and even extend them to other languages such as R, Matlab, or Julia, and share their work with us and the community. We welcome community feedback on these tutorial notebooks and are happy to support community-developed software on our platform.

----

# EC-Argovis-API-Demo
[![Binder](https://mybinder.org/badge_logo.svg)](https://mybinder.org/v2/gh/tylertucker202/EC-Argovis-API-Demo/master?urlpath=https%3A%2F%2Fgithub.com%2Ftylertucker202%2FEC-Argovis-API-Demo%2Fblob%2Fmaster%2FEC2020_argovis_python_api.ipynb)
## Demonstration of Argovis Python API - For Earthcube 2020 meeting

You can run these notebooks using your own Jupyter kernel. 

The notebooks use some libraries that can take time to set up on some systems (e.g. Cartopy).

I've created a Dockerfile to make this install easier. 

This project assumes that [Docker](https://www.docker.com/) is installed on your PC, and that the daemon is running. Additionally, make sure that port 8888 is open. Check with `lsof -i :8888`.

First, open a terminal

Then build the image with the following command

`docker build --no-cache -t argovis_python_api_demo:1.0 .`

Run the image with this code in a Linux terminal or Windows PowerShell

`docker run  -v ${PWD}:/usr/src/av_py_env -p 8888:8888 argovis_python_api_demo:1.0`

Lastly, follow the provided link in the terminal. You may be prompted to set the kernel on a notebook. Just set the kernel to av_py_env. Good luck!
