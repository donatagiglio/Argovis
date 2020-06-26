To move an environment from a machine to the other

machine 1: create the yml file: conda env export > environment.yml


machine 2: create the environment using the .yml file (specify the python version): conda env create -f env_py38.yml python=3.8
 you could try and do step 2 directly using the .yml in this folder
