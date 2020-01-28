redmine_xtended_queries
=======================


Redmine plugin that adds new **Columns**, **Filters** and other features.

# How it works

## What it does

* **Issue Queries** :

  * New **Or Filters**, like Filters but cumulative not exclusive.

    With or filters you can for example select issues assigned to you, OR that you have created.

  * New columns :
    * **Project of the parent isssue**
    * **Estimated time**
    * Issues Tree :
      * **⊨ Parent task**
      * **⊨ Parent task -- (Position)**
      * **⊨ Parent task -- (Subject)**
      * **⊨ Root task**
      * **⊨ Root task -- (Position)**
      * **⊨ Root task -- (Subject)**
      * **⊨ Position**
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
    * **Tracker**
    * **Target version**
    * **Category**
    * **Subject**
    * **Watchers**
    * Issues Tree :
      * **⊨ Issue Id.**
      * **⊨ Root task**
      * **⊨ Parent task -- (Subject)**
      * **⊨ Parent task -- (Position)**
      * **⊨ Root task -- (Subject)**
      * **⊨ Root task -- (Position)**
      * **⊨ Position**
    * Date :
      * **🗓 Year**
      * **🗓 Month**
      * **🗓 Week**
    * **Updated on**
    * Cumulative Hours :
      * **🕝 Hours for issue and user**
      * **🕝 Hours for issue**
      * **🕝 Hours for user**
      * **🕝 Hours for issue and user this month**
      * **🕝 Hours for issue this month**
      * **🕝 Hours for user this month**
      * **🕝 Hours for issue and user previous month**
      * **🕝 Hours for issue previous month**
      * **🕝 Hours for user previous month**
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
    * **Hours for issue and user**
    * **Hours for issue**
    * **Hours for user**

    * **Hours for issue and user this month**
    * **Hours for issue this_month**
    * **Hours for user this month**

    * **Hours for issue and user previous month**
    * **Hours for issue previous_month**
    * **Hours for user previous month**

  * New Group totals fixed for
    * **Spent Hours by Issue / User**
    * **Billable Hours by Issue / User**
    * **Deviation Hours by Issue / User**

* Queries columns **selection boxes** : new prefix glyphs (utf8) for :
  * Time columns : 🕝
  * Date type columns : 🗓
  * Custom Fields : 🔧
  * Issue tree and position columns : ⊨

* Forbid setting **global query** public to other than me for non-admins : Fixed upstream with Redmine V3.0.4

# Changelog

* **V1.0.8** Small enhancements and fixes :

  * **{TimeStamp}QueryColumn.group_value** added for old Redmine versions

  * Use respond_to?(or_filters_provided?) instead of respond_to?(or_filters)

  * Queries columns **selection boxes** **sorted** and glyphs prefixes (utf8) added

    **Hooks available** for other plugins

  * lib/models/smile_models_time_{entry/report}_query.rb **cleaned**
  * Time Report Advanced queries : **filter issue** dropdown list like parent, root

* **V1.0.7** REMOVED : Forbid setting global query public to other than me for non-admins : **Fixed upstream**

* **V1.0.6** +Spent/Billable/Deviation hours for issue/user **this** / **previous month**
