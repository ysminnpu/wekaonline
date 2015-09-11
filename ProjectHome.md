# WEB INTERFACE #
  * Making the web interface "classifiers" textarea so that client can select (rather than write) the algorithm to run.
    * either by emulating weka like "windows" style
    * or a structured view showing all configurable parameters in one 'window'

  * Enabling n fold cross-validation instead of default 10-fold mode (client should be enabled to run leave-one-out cv)

  * Uploaded dataset validator, i.e. that if it's csv or arff, that we validate that they are correct format (there should be weka api for that but can be done elsewise e.g. by testrunning J48 classifier and catching errors)

# WEKA API HANDLERS #
  * For calling results and uploading the results to MySQL database (using Weka's jdbc connectivity, if possible)

  * For executing Weka commandline runs (instead of current "parsing")

# OTHER #
  * Cron script for running WOnline e.g. every day at noon as soon as there are projects to run.

  * Compiling weka into native code so that the current server can run gcj of weka commandlines.