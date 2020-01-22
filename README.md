redmine_xtended_queries
=======================


Redmine plugin that adds new **Columns**, **Filters** and other features.

# How it works

## What it does

* **Issue Queries** :

  * New **Or Filters**, like Filters but cumulative not exclusive.

    With or filters you can for example select issues assigned to you, OR that you have created.

  * New columns :
    * **Issue Id.**
    * **Estimated hours**
    * Issues Tree :
      * **Root task**
      * **Parent task**
    * **Tracker**
    * **Target version**
    * **Category**
    * **Subject**
    * **Watchers**
    * **Position**
    * Issues Tree :
      * **Project of the parent isssue**
      * **Root task -- (Subject)**
      * **Root task -- (Position)**
      * **Parent task -- (Subject)**
      * **Parent task -- (Position)**
    * **Project Updated**
    * **Updated on**

  * New filters :
    * **Project updated on**
    * Filter on **Subproject** changed : current project not selected by default

      Available if on a project, and having children

    * **Parent Project** (if on a project)
    * If advanced checkbox is checked :
      * **Root task** (if on a project)
      * **Parent task** (if on a project)
      * **Issue** (if on a project)
      * **Children count**
      * **Level in tree**

* Time Entry Queries :
  * New columns :
    * **Position**
    * **Root task**
    * **Project of the parent isssue**
    * **Root task -- (Subject)**
    * **Root task -- (Position)**
    * **Parent task -- (Subject)**
    * **Parent task -- (Position)**
    * **Project Updated**
    * Date :
      * **Year**
      * **Month**
      * **Week**
    * **Updated on**
    * Cumulative Hours :
      * **Spent hours for issue and user**
      * **Spent hours for issue**
      * **Spent hours for user**
      * **Spent hours for issue and user this month**
      * **Spent hours for issue this month**
      * **Spent hours for user this month**
      * **Spent hours for issue and user previous month**
      * **Spent hours for issue previous month**
      * **Spent hours for user previous month**
    * New Cumulative Billable and Deviation :

      Only if **Billable** and **Deviation** called **Custom Fields** exist on Time Entries

      * **Billable hours for issue and user**
      * **Billable hours for issue**
      * **Billable hours for user**
      * **Billable hours for issue and user this month**
      * **Billable hours for issue this month**
      * **Billable hours for user this month**
      * **Billable hours for issue and user previous month**
      * **Billable hours for issue previous month**
      * **Billable hours for user previous month**

      * **Deviation hours for issue and user**
      * **Deviation hours for issue**
      * **Deviation hours for user**
      * **Deviation hours for issue and user this month**
      * **Deviation hours for issue this month**
      * **Deviation hours for user this month**
      * **Deviation hours for issue and user previous month**
      * **Deviation hours for issue previous month**
      * **Deviation hours for user previous month**
    * New Totalable columns :
      * **Spent Hours by Issue / User**
      * **Billable Hours by Issue / User**
      * **Deviation Hours by Issue / User**

  * New Filters :
    * **Spent hours for issue and user**
    * **Spent hours for issue**
    * **Spent hours for user**

    * **Spent hours for issue and user this month**
    * **Spent hours for issue this_month**
    * **Spent hours for user this month**

    * **Spent hours for issue and user previous month**
    * **Spent hours for issue previous_month**
    * **Spent hours for user previous month**

  * New Group totals fixed for
    * **Spent Hours by Issue / User**
    * **Billable Hours by Issue / User**
    * **Deviation Hours by Issue / User**

* Forbid setting **global query** public to other than me for non-admins
  * new validation callback method **validate_setting_public_query_for_all_projects_forbidden**