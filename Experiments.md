# DONE #

# TODO #

## Filters ##
We will provide the filters to apply changes to the datasets uploaded in the server. We will allow to save the changes in the server as a new dataset (with different name). It would be necessary to handle the missing values for example.

## Analysis ##
Once the experiment is done we will count the results if it is mean something. Normally the normal execution without cross-validation doesn't mean anything. When an user run an experiment with a cross-validation with the folds number higher than ln(x)(logarithm) (x is the number of instances) we will consider this experiment with meaning. And it will entry in the ranking analysis.

If we have 1000 instances the number of folds has to be ln(1000) = 6,9 (7) to consider the experiment in the analysis. In other case the experiment will not be counted in the analysis. Because someone can use an experiment with 2 fold and get 0.90 of accuracy. It is not meaning anything.