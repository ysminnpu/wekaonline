# List of Use cases #
  * Algorithms subsystem
    * Algorithms Handler
      1. Show list of Algorithms
      1. Read Algorithm
      1. Add Algorithm
      1. Delete Algorithm
      1. Load Algorithm in the experiment
  * Challenges subsystem
    * Challenge Handler
      1. Create challenge
      1. Read challenge
      1. Set challenge like resolved
  * Datasets subsystem
    * Dataset Handler
      1. Upload dataset
      1. Download dataset
      1. Delete dataset
      1. Apply filter in dataset
      1. Set private dataset
  * Experiments subsystem
    * Experiment Handler
      1. Read Experiment
      1. Run Experiment
      1. Set Experiment Settings.
  * Filter subsystem
    * Filter Handler
      1. Add filter
      1. Delete filter
      1. Read filter
      1. Apply filter in dataset
  * Rankings subsystem
  * Transactions subsystem
  * Users subsystem
    * Users Handler
      1. Register
      1. Set Premium user
      1. Login
      1. Rescue the pass by email
  * Documentation subsystem

# Descriptions #
## Algorithm subsystem ##
### Show list of algorithms ###
The system will can show every accessible algorithms in a list. The user will can select that he wants. This set is composed by algorithms that Weka provides and the algorithms that the users upload to the server(only the public algorithms).
## Dataset subsystem ##
### Delete dataset ###
When someone try to delete a dataset the system will check if someone else used this dataset in any experiment. Then the system will send a notification to those users to say them if they want to host this dataset(we will say to them that it will disappear if they don't accept). If someone say yes the dataset will be rest from the used memory in the deleter user account and he will have more free space. Who accepted the notification to own the dataset will spend memory from his account and he will be the new owner. If nobody wants to accept the dataset we will keep the file in the database with the "removed" field "true".

### Set private dataset ###
The premium user can change the visibility of own datasets. In this case nobody can see the private datasets, only the owner user. You can upload private files to the server if you are a premium user else (being free user)you will upload every dataset in public visibility.

## Experiment subsystem ##
### Run experiment ###
Steps:
  1. client sends the dataset from web interface, with algos he wants run
  1. we have a formhandler that inserts the dataset file name and classifiers into their spots in the rm xml file
  1. we execute this file--> output are either evaluation results or class predictions (or both)
  1. we attach another rm operator that inserts those results into mysql tables(attach into the rm template, last)
  1. we query database for what client has specified he wants to show
## User subsystem ##
### Register ###
The user will have to be registered to access to the tools that the webpage offer. So they can register himself through the registration web page. It will be needed to confirm the user registration by email. The login will be the email also. And the password will have to be secure. The fields that have to be fill are in the class diagram.(the user class). Note: When a user is registered we have to create the relation with the transaction table also(because he can use the **GoGrid** service).

### Set Premium user ###
Once the user is registered he can take the premium user by paying. It can be accessible easily from the WebPage. We will offer the new service that premium user offer if the client want to buy he will can do it. Then the user will change the profile to **PremiumUser**.