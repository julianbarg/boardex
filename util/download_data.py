#!/usr/bin/env python3

import wrds
import download_parameters as parameters
import sys

from os import listdir


def download_table(_db, name, _library, _table):
    table = db.get_table(library=_library, table=_table)
    table.to_pickle(f'data/{name}.pickle')
    del table


redownload = "--redownload" in sys.argv


db = wrds.Connection(wrds_username=parameters.username)


for dataset in parameters.datasets:
    if not redownload and dataset['name'] + '.pickle' in listdir('data'):
        continue
    else:
        download_table(db, dataset['name'], dataset['library'], dataset['table'])
        print(f'Downloaded dataset {dataset["name"]}.')
