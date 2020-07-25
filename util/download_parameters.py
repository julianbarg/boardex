username = "julianba"

datasets = [
    # {'library': 'boardex', 'table': 'NA_DIR_PROFILE_DETAILS'},
    # {'library': 'boardex', 'table': 'EUR_DIR_PROFILE_DETAILS'},
    # {'library': 'boardex', 'table': 'ROW_DIR_PROFILE_DETAILS'},
    # {'library': 'boardex', 'table': 'UK_DIR_PROFILE_DETAILS'},
    {'name': 'na_summary', 'library': 'boardex', 'table': 'NA_WRDS_ORG_SUMMARY'},
    {'name': 'na_boards', 'library': 'boardex', 'table': 'NA_BOARD_DIR_COMMITTEES'},
    {'name': 'compa', 'library': 'compa', 'table': 'FUNDA'  # ,
     # 'columns': ['gvkey', 'fyear', 'cusip', 'apdedate', 'at', 'emp', 'dltt', 'ceq', 'act', 'lct', 'sic', 'gsector',
     #             'gsubind', 'spcindcd', 'spcseccd', 'bkvlps', 'csho']}  # ,
     },
    {'name': 'names', 'library': 'compa', 'table': 'NAMES'},
    # {'name': 'eur_summary', 'library': 'boardex', 'table': 'EUR_WRDS_ORG_SUMMARY'},
    # {'name': 'row_summary', 'library': 'boardex', 'table': 'ROW_WRDS_ORG_SUMMARY'},
    # {'name': 'uk_summary', 'library': 'boardex', 'table': 'UK_WRDS_ORG_SUMMARY'}
]
