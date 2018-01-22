## Final Assignment for 'Getting and Cleaning Data'


### The attached R script (run_analysis.R) does the following:

1. Downloads the zip file from source. The code to unzip hasn't been included as it was done separately.

2. Loads all the datasets: features, subject, X and Y for both test and train sets.

3. Merges x_test and x_train (rbind) to get X and y_test and y_train to get Y tables. X columns are renamed with feature names from feature table. Then X and Y are cbinded to get combined table.

4. Then keeps only those columns in combined, which are identified to be mean/standard dev. columns in features table.

5. Activity labels are merged in and renamed descriptively.

6. All column names are renamed to satisfy descriptive variable naming convention by removing symbols and expanding short-hand notations.

7. Activity and subject are converted to factors.


8. A tidy dataset is created by finding the mean of each variable for each activity-subject pair.

9. The tidy dataset is output into a file called tidy.txt.