This document describes how to replicate the data and the results of the paper "Ethereum Governance". 

# Data Collection Process.

## EIP DATA
1. *EIP List*: The data collection process begins with scraping the list of EIPs and related authors from the [Ethereum EIP page](https://eips.ethereum.org/all). This website contains information of all EIPs, their status and their authors. This data is collected using a web-scrapping code as of **06/21/2023**. The code *EIP list generating code.py* scrapes EIP Number, Authors, Status, and Title, and stores it into the file allEIPsandAuthorsv2.csv. (Note that the code was run on 6/21/2023. Rerunnign the code now would produce a different set of EIPs, as new EIPS have been added since then). 
2. *EIP Author ID*: The same EIP author name is sometime spelled differently in the EIP list. We thus take the EIP author list, and manually assign a unique author identidier (*Author id*) to each author and the related github handle. The file *unique_author_names_with_id.csv* includes the list of authors and id.   
3. *EIP List and Standardized Authors*: The python code *pythoncode to prepare data merging* takes the EIP list from *allEIPsandAuthorV2.csv* and perform following actions:
   - replace multiple author_names with one standardized author name
   - add the author id to each author
   - save the file as *Ethereum_Cross-sectional_Data_beg.csv*.
5. *EIP Implementation*. We manually went throguh all EIPs, and classified them on whether Whether an EIP requires a client implementation or not, and in which fork it was implemented. The information is saved in *eip_implementation.csv*
6. *EIP Start Date*: *startdate_scraping.py* collect start date of all eips and stores it into *eip_startdates.csv*  
7. *EIP End Date*: end date of all EIPs that have reached final stage stored in file *finaleip_enddates.csv*
## CENTRALITY MEASURES
9. We use python code *centrality_code.py* to create several centrality measures amongs all co-authors of EIPs. These measures are subsequently merged in the data

## SOCIAL DATA
8. *Github Followers*: *Github Follower Extract.py* scrapes the github followers for each EIP authors with a github handle. The code generates an interim file which is stored in *author_github_following_raw.csv*. We apply python code *github data reconciliation* to reconcile an older version of this data and match it with author_ids in this code to create a final github data stored in *GitHub_Data.csv*  
9. *Twitter Data*: We manually collected information on the authors' Twitter following and Twitter followers, if available. This data is in *Twitter_Data.csv*.
10. *LinkedIn Data:* We also manually collected data from LinkedIn, capturing details of up to four current companies where the authors are presently employed, along with their job titles. This also includes employees of Ethereum Foundation Additionally, we gathered information on up to the last 10 companies where they had previously worked, including their past job titles. This is in *LinkedIn_Data.csv*

## COMMIT DATA
11. *EIP Commit*. Each EIP has a github repository. We collect all commitments made by any contributor to the EIP, whether they are an author or a contributor who may not be an author. This collection is done through a python code *???????.py* the output of this code is a file *eip_commit_beg.xlsx* We merge this data in the cross-sectional data using eip_number as the key
    - To flag whether the commitor to the eip repository is an eip author or not we merge it with *author.dta* (which is stata conversion of unique_author_names_with_id.csv). If the merged value matches author.dta we flag the github_username *eip_author = 0/1*.  We then aggregate this data to create cross-sectional equivalent based on eip_number to get the following three values:
    - Total number of commits to each EIP and merge it with the cross-sectional data in the *data merging code.do* and call it *total_commits*
    - Author Commits which is number of commits made by EIP Authors and merge it with the cross-sectional data in the *data merging code.do* and call it *author_commits*
    - Unique number of commitors excluding author that are commiting to the eip github for each eip. We call this variable *contributors* and merge this with the cross-sectional data in the *data merging code.do*
12. *Client Commit*. We also download all commit to the 4 largest client repositories: besu, erigon, geth, and nethermind. *???????.py* scrapes the data, and stores it into four stata files *commitsbesu.dta*,*commitserigon.dta*,*commitsgeth.dta*, and "commitnethermind.dta".
  - We then aggregate all commits by each github username
  - We match github usernames with authors to see how many commits are done by eip authors
  - We then merge this to the cross-sectional data for each author 1 to 11
  - We create a maximum of all authors for eip. This process is repeated for 4 clients so we get *geth_commits*, *besu_commits*, *erigon_commits*, and *nethermind_commits* as four variables in the cross-sectional data. The process is included in the *data merging code.do*

## Merge and Prepare files for regressions
13. *Merge all files* We use a stata code called *data merging code.do* to create the cross-sectional data organized by EIP_Number. The following steps describe the process:
* The cross-sectional data is generated by first importing *Ethereum_Crossectional_Data_beg.csv*. This is the output of running python code *pythoncode to prepare data merging*
* The code import all the collected data which includes Github, Twitter, LinkedIn, Eip Commit, Start Dates, End Dates, Implementation, and Author
* After downloading the above files, we merge the following data:
  - Eip commits and three measures created for eip commits for each eip
  - twitter data for each author and create a tw_follower variable which is the maximum twitter follower of any of the authors listed in the EIP.
  - Github Follower data on each author and create a gh_follower variable which is the maximum github follower of any of the authors listed in the EIP.
  - Linkedin data for each author which includes, upto 4 companies in which author may be working and 10 past companies where authors might have worked along with their job titles. We later create dummy varibles representing top 10 companies where authors worked
  - create a variable n_authors which represents the number of authors for each EIP
  - merge centrality data which includes three centrality measures : betweenness, closeness, and eigen value centrality. Each author has a centrality measure so we create betweenness_centrality, Closeness_centrality, and eigen_value_centrality measure as the maximum of respective centrality measure of all authors
  - merge start dates and end dates of all eips
  - merge implementation data
  - merge client commit data by adding client commits of each author for four clients (Besu, Erigon, Geth, and Nethermind) and then calculate four variables that represent the maxiumum commits by authors who contributed to client repository for each eip.
  - rearrange variables
  - create total client commit variables representing summ of four client commits
  - create success variable that assigns the value of 1 if eip is final and 0 if eip is withdrawn or stagnant. It creates a missing value if eip's status is last call, review, or draft (in-progress)
  - create implementation variable that assigns the value of 1 if eip is implemented in a Fork
  - replace all missing values of tw_follower and gh_follower with 0
  - create time to final variables as number of days between end date and start date
  - create log_tw and log_gh as log( 1+gh/tw follower)
14. *Replication Steps*
    - Make sure you have all the files in the correct directory
    - Assign proper directory to the *data merging code.do*
    - Run *data merging code.do*
