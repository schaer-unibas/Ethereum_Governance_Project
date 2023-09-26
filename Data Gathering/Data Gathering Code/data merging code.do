// This is the code to merge disparate data on Ethereum Governance Project.
// There are several independently collected data sources. We have manually collected twitter following and twitter follower data for EIP authors
// We begin with a file that contains all EIPs on Github with author names. We assigned a unique author id for each authors
// In addition, there is a separate data manually collected on companies where they worked and author's job titles 
// Also there is a manual collection of github followers
// Once these data were collected, we matched author names using a fuzzy logic. We added author_ids for matched names and for those that did not match we manually added author_ids
// The following code is a way to merger twitter, github, company, and jobs data into the beginning file with EIP numbers, author names, and author_ids

// Import EIP data

cd "C:\Users\khojama\Box\Fintech Research Lab\Ethereum Governance Project\Ethereum Project Data\"
clear
import delimited "AllEIPS.csv"


// save this imported file as a stata file

save "Ethereum_Cross-sectional_Data.dta", replace

// import twitter data and create a stata file

import delimited "twitter_data.csv", numericcols(5) clear 
save "twitter_data.dta", replace

// Merge the data by author_id one author at a time

clear
use "Ethereum_Cross-sectional_Data.dta"

forvalues id = 1/11{
rename author`id'_id author_id
merge m:1 author_id using "twitter_data.dta",keepusing(follower following)
drop if _merge == 2
drop _merge
rename author_id author`id'_id
rename follower author`id'_follower
rename following author`id'_following
}

// create max twitter follower variable

egen tw_follower = rowmax(author1_follower author2_follower author3_follower author4_follower author5_follower author6_follower author7_follower author8_follower author9_follower author10_follower author11_follower)

save "Ethereum_Cross-sectional_Data.dta", replace

// merge github 

// import github following data and save it as a stata file
import delimited "GitHub_Data.csv", numericcols(6) clear 
save "Github_data.dta", replace

// merge with ethereum data
clear
use "Ethereum_Cross-sectional_Data.dta"

forvalues id = 1/11{
rename author`id'_id author_id
merge m:1 author_id using "Github_data.dta",keepusing(github_followers)
drop if _merge == 2
drop _merge
rename author_id author`id'_id
rename github_follower author`id'_gh_follower
}

// create a maximum github following variable
egen gh_follower = rowmax(author1_gh_follower author2_gh_follower author3_gh_follower author4_gh_follower author5_gh_follower author6_gh_follower author7_gh_follower author8_gh_follower author9_gh_follower author10_gh_follower author11_gh_follower)

save "Ethereum_Cross-sectional_Data.dta", replace


// merge LinkedIn Data

//import linkedin data and save it as a stata file
import delimited "linkedin_data.csv", clear
save "linkedin_data.dta",replace

// merge linkedin data
clear
use "Ethereum_Cross-sectional_Data.dta"

forvalues id = 1/11{
rename author`id'_id author_id
merge m:1 author_id using "linkedin_data.dta",keepusing(company1 company2 company3 company4 pastcompany1 pastcompany2 pastcompany3 pastcompany4 pastcompany5 pastcompany6 pastcompany7 pastcompany8 pastcompany9 pastcompany10 jobtitle1_company1 jobtitle2_company1 jobtitle3_company1 jobtitle1_company2 jobtitle1_company3 jobtitle1_company4 jobtitle1_pastcompany1 jobtitle1_pastcompany2 jobtitle1_pastcompany3 jobtitle1_pastcompany4 jobtitle1_pastcompany5 jobtitle1_pastcompany6 jobtitle1_pastcompany7 jobtitle1_pastcompany8 jobtitle1_pastcompany9 jobtitle1_pastcompany10)
drop if _merge == 2
drop _merge
rename author_id author`id'_id
rename company1 author`id'_company1
rename company2 author`id'_company2
rename company3 author`id'_company3
rename company4 author`id'_company4
rename pastcompany1 author`id'_pastcompany1
rename pastcompany2 author`id'_pastcompany2
rename pastcompany3 author`id'_pastcompany3
rename pastcompany4 author`id'_pastcompany4
rename pastcompany5 author`id'_pastcompany5
rename pastcompany6 author`id'_pastcompany6
rename pastcompany7 author`id'_pastcompany7
rename pastcompany8 author`id'_pastcompany8
rename pastcompany9 author`id'_pastcompany9
rename pastcompany10 author`id'_pastcompany10
rename jobtitle1_company1 author`id'_jobtitle1_company1
rename jobtitle2_company1 author`id'_jobtitle2_company1
rename jobtitle3_company1 author`id'_jobtitle3_company1
rename jobtitle1_company2 author`id'_jobtitle1_company2
rename jobtitle1_company3 author`id'_jobtitle1_company3
rename jobtitle1_company4 author`id'_jobtitle1_company4
rename jobtitle1_pastcompany1 author`id'_jobtitle1_pastcompany1
rename jobtitle1_pastcompany2 author`id'_jobtitle1_pastcompany2
rename jobtitle1_pastcompany3 author`id'_jobtitle1_pastcompany3
rename jobtitle1_pastcompany4 author`id'_jobtitle1_pastcompany4
rename jobtitle1_pastcompany5 author`id'_jobtitle1_pastcompany5
rename jobtitle1_pastcompany6 author`id'_jobtitle1_pastcompany6
rename jobtitle1_pastcompany7 author`id'_jobtitle1_pastcompany7
rename jobtitle1_pastcompany8 author`id'_jobtitle1_pastcompany8
rename jobtitle1_pastcompany9 author`id'_jobtitle1_pastcompany9
rename jobtitle1_pastcompany10 author`id'_jobtitle1_pastcompany10
}

// create number of authors

gen n_authors = 1 if author1 != ""

forvalues i = 2/11{
replace n_authors = n_authors + 1 if author`i' != ""	
}

save "Ethereum_Cross-sectional_Data.dta", replace

// add number of total commits and eip_contributors 
clear 
use "ethereum_commit.dta"
collapse (mean) total_commit eip_contributors author_commit, by (eip_number)
save "total_commit.dta", replace

// merge
use "Ethereum_Cross-sectional_Data.dta", clear

merge 1:1 eip_number using "total_commit.dta"
drop if _merge ==2 // remove one additional EIP that is in commit data but not in cross-sectional
drop _merge

save "Ethereum_Cross-sectional_Data.dta", replace


// Add betweenness_centrality measure for each EIPs

clear
import delimited "betweenness.csv"
save "betweenness.dta", replace

use "Ethereum_Cross-sectional_Data.dta"
merge 1:1 eip_number using "betweenness.dta", keepusing(betweenness_centrality)
save "Ethereum_Cross-sectional_Data.dta", replace

// add start and end dates of all EIPs that have been finalized
clear
import delimited "allEIPswithdates.csv"
rename number eip_number
save "alleipswithdates.dta", replace

use "Ethereum_Cross-sectional_Data" , clear
drop _merge
merge 1:1 eip_number using "alleipswithdates.dta", keepusing(start end)
drop if _merge == 2
drop _merge


// move variables
move eip_number author11
move status author11
move start author11
move end author11
move n_authors author11
move tw_follower author11
move gh_follower author11 
move total_commit author11
move author_commit author11
move eip_contributors author11
move betweenness_centrality author11


save "Ethereum_Cross-sectional_Data.dta", replace

// prepare files collapsing client commits and matching them with eip authors


// add client repository commits by author 
local path "C:\Users\khojama\Box\Fintech Research Lab\Ethereum Governance Project\Ethereum Project Data\client_commit\"
cd "`path'"
local files : dir "`path'" files "*.dta" // Get the list of .dta files in the directory
di `files'
foreach file of local files {
    use "`file'", clear
	local newvar = substr("`file'", 8, strlen("`file'")-11)
	di "`newvar'"
    collapse (count) date, by(login)
	rename date `newvar'_commits
    rename login github_username
    drop if github_username == "" 
    cd "C:\Users\khojama\Box\Fintech Research Lab\Ethereum Governance Project\Ethereum Project Data\"
    merge 1:m github_username using "author", keepusing(author_id)
    keep if _merge == 3
    drop _merge
    cd "C:\Users\khojama\Box\Fintech Research Lab\Ethereum Governance Project\Ethereum Project Data\"
    save "`file'_author_commits.dta", replace
	cd "`path'"
}
cd "C:\Users\khojama\Box\Fintech Research Lab\Ethereum Governance Project\Ethereum Project Data\"
use "Ethereum_Cross-sectional_Data.dta", clear

local files = "besu erigon geth nethermind"
foreach file in `files' {
  forvalues id = 1/11{
    rename author`id'_id author_id
    merge m:1 author_id using "commits`file'.dta_author_commits.dta",keepusing(`file'_commits)
    drop if _merge == 2
    drop _merge
    rename author_id author`id'_id
    rename `file'_commits author`id'_`file'_commits
  }
  egen `file'_commits = rowmax(author1_`file'_commits author2_`file'_commits author3_`file'_commits author4_`file'_commits author5_`file'_commits author6_`file'_commits author7_`file'_commits author8_`file'_commits author9_`file'_commits author10_`file'_commits author11_`file'_commits)
  move `file'_commits author11
}

save "Ethereum_Cross-sectional_Data.dta", replace


