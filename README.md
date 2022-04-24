 [![GitHub release](https://img.shields.io/github/release/jhubig/ioBrokerGoesTidbyt/all.svg?maxAge=1)](https://GitHub.com/jhubig/ioBrokerGoesTidbyt/releases/)
 [![GitHub tag](https://img.shields.io/github/tag/jhubig/ioBrokerGoesTidbyt.svg)](https://GitHub.com/jhubig/ioBrokerGoesTidbyt/tags/)
 [![GitHub license](https://img.shields.io/github/license/jhubig/ioBrokerGoesTidbyt.svg)](https://github.com/jhubig/ioBrokerGoesTidbyt/blob/master/LICENSE)
 [![GitHub issues](https://img.shields.io/github/issues/jhubig/ioBrokerGoesTidbyt.svg)](https://GitHub.com/jhubig/ioBrokerGoesTidbyt/issues/)
 [![GitHub issues-closed](https://img.shields.io/github/issues-closed/jhubig/ioBrokerGoesTidbyt.svg)](https://GitHub.com/jhubig/ioBrokerGoesTidbyt/issues?q=is%3Aissue+is%3Aclosed)
 [![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/jhubig/ioBrokerGoesTidbyt/issues)
 [![GitHub contributors](https://img.shields.io/github/contributors/jhubig/ioBrokerGoesTidbyt.svg)](https://GitHub.com/jhubig/ioBrokerGoesTidbyt/graphs/contributors/)
 [![Github All Releases](https://img.shields.io/github/downloads/jhubig/ioBrokerGoesTidbytl/total.svg)](https://github.com/jhubig/ioBrokerGoesTidbyt)
 [![Github All Releases](https://img.shields.io/github/watchers/jhubig/ioBrokerGoesTidbyt?style=social)](https://github.com/jhubig/ioBrokerGoesTidbyt)

 # ioBrokerGoesTidbyt
  A Tidbyt pixel app which displays data from ioBroker

 ![ioBroker_Tidbyt.jpeg](img/ioBroker_Tidbyt.jpeg?raw=true "ioBroker_Tidbyt.jpeg")

 ## Introduction

 First of all thanks a lot for the inspiration from the following article and the author Tom (https://gist.github.com/tmcw) behind it: https://macwright.com/2022/03/11/tidbyt-review.html

 This pixlet will enable to display data from your ioBroker on your Tidbyt device. This "self"-developed app needs to be pushed in a cycle to the Tidbyt in order not to be replaced by one of the community apps you have added in your active apps section in the mobile app. The process of how I did that is described in the following section.

 ## Installing, configuring and first script execution

 1. Copy the bash script and the star app to a machine which is online 24/7 (in my case I used the Raspberry PI which is also running my ioBroker instance) because you need to push your private app regularly to your Tidbyt
 2. make the pushToTidbyt.sh script executable by performing a chmod +x
 3. Add your API key and Device key in the mobile app and update the pushToTidbyt.sh file accordingly with that information
 4. Add the path to the folder where you stored the two files in your pushToTidbyt.sh file
 5. Add the execution of this script to your cronjobs
      At the end of the file add the following lines:

      # Cronjob for displaying data on Tidbyt permanently
      * * * * * sleep  0 ; <PATH_TO_YOUR_FILES>/pushToTidbyt.sh >/dev/null 2>&1
      * * * * * sleep 15 ; <PATH_TO_YOUR_FILES>/pushToTidbyt.sh >/dev/null 2>&1
      * * * * * sleep 30 ; <PATH_TO_YOUR_FILES>/pushToTidbyt.sh >/dev/null 2>&1
      * * * * * sleep 45 ; <PATH_TO_YOUR_FILES>/pushToTidbyt.sh >/dev/null 2>&1

 ## External Links

 * https://tidbyt.com/
