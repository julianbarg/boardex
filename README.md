# boardex

Use https://github.com/julianbarg/pgpass_setup to setup .pgpass file.

## Process

i. Before we can create the sample, we need to obtain the data from WRDS. The util folder contains a python script for this purpose, or we can directly start with predownloaded .feather files in the data folder. The compa file is very unwieldy, and any computer with less than 24GB of RAM or with no SSD will fail when downloading it.