# Primary-care-SACT-use

This project defined a code list of SACT (systemic anti-cancer treatment) which we would not expect to see routinely prescribed in primary care.  It then downloaded the prescribing data from primary care issues (OpenPrescribing) and provided some analysis.

The finished product - a poster is available on [fig.share](https://doi.org/10.6084/m9.figshare.23995524.v1)

## Structure of the code

We provide the code here for re-producability.  It wasn't written to be hyper-readable; but we have tried to provide some context.  Our code is released on GNU GPL v3 license (see: LICENSE file). 

Folders:

- Data: Contains data! These are a mixture of csv files and RDS R binary files. They might save you needing to actually extract data from external sources.

- DemoCode: Exists for bits of code we testing things out with or pulled from other projects Expect them to break

- Functions: contains a couple of functions to extract data from both the WHO Website and The Open Prescribing Website

- MapShape: contains the data for building the maps.  The code is also available to get those shapes. Data is (c) Ordnance Survey and licensed under OpenGov v3.

- Outputs: our data analysis for the first draft of the asbtract and poster contents.

- _extensions: a wordcount function from @andrewwheiss

## Files
For each of the files in the root directory we've tried to provide some context to their use.

**merge_drug_lists.R** converts the RDS file with the drugs from WHO website to a merged CSV file, which is a good starting place for creating the list on opencodelist.

**Download_and_Save_OpenPrescribingData.R** collects the codelist from [OpenCodelist](https://opencodelists.org/user/chloewaterson/oral-sact/) and then uses the OpenPrescribing API to download the data for these drugs.  Check the dependencies at the start of the file.

**analyse_openprescribing_data.R** does as you would expect and provides some summary analaysis of the data downloaded above.

**EstimateSmallestPackSize.R** tries to estimate the smallest packsize for a given drug, allowing some estimate of cost paid including borken bulk.

**ImageNotes.R** allows production of a bar chart similar to our poster with on bar annotation.  (The one on the poster was actually produced in Powerpoint!)

## Output Files

**BOPA_Abstract.qmd** produces a draft BOPA Asbtract as submitted.

**subICBmap.R** will produce a map of spending at subICB level.  We decided to merge the data to regional level; and so **ICBmap.R** is the version displayed on the poster.  (it is commented more fully)





