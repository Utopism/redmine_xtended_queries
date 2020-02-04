redmine_xtended_queries
=======================


Redmine plugin that adds new **Columns**, **Filters** and other features.

# How it works

## What it does

* **Issue Queries** :

  * New **Or Filters**, like Filters but cumulative (not exclusive).

    With or filters you can for example select issues assigned to you OR that you have created.

  * New columns :
    * Issues Tree :
      * **Project of the parent isssue**
      * **⊨ Parent task**
      * **⊨ Parent task -- (Position)**
      * **⊨ Parent task -- (Subject)**
      * **⊨ Root task**
      * **⊨ Root task -- (Position)**
      * **⊨ Root task -- (Subject)**
      * **⊨ Position**
    * **Project Updated**

      The Updated on value

    * Issue **Updated on**

  * New filters :
    * **Project updated**

      The Updated on value

    * Filter on **Subproject** changed : current project not selected by default

      Available if on a project, and having children
      Natively when you filter on Sub-projects, you always have the issues of the current project even if project is not selected.

    * **Parent Project** (if on a project)
    * If advanced checkbox is checked :
      * **Root task** (if on a project)
      * **Parent task** (if on a project)
      * **Issue** (if on a project)

        Input field replaced by **drop down list** if **Advanced Filers** is checked.

      * **Children count**
      * **Level in tree** (0 for root tasks)

* Time Entry Queries :
  * New columns :
    * **Estimated time**
    * **Tracker** + groupable
    * **Target version**
    * **Category** + groupable
    * **Subject**
    * **Watchers**
    * Issues Tree :
      * **⊨ Issue Id.**
      * **⊨ Root task**
      * **⊨ Parent task**
    * Date :
      * **+ 🗓 Year**
      * **+ 🗓 Month**
      * **  🗓 Week + groupable**
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

## How it is implemented

### Query partial views

* In **app/views/queries** :
  * 🔑 **REWRITTEN** **_filters.html.erb**
  * 🔑 **REWRITTEN** **_form.html.erb**
  * New **_or_filters.html.erb**
  * 🔑 **REWRITTEN** **_query_form.html.erb**

### Javascript assets for **Or Filters**

* New **assets/javascripts/custom_query.js**

### New **translations** (ca, en-GB, en, es, fr, uk)

### Migrations :

* **20150225140000_add_queries_or_filters** technical migration, can be ignored
* **20150225140000_add_queries_or_filters** to add **or_filters** to **queries table**

### Controllers / Helpers / Modelss

* **lib/controllers**
  * **smile_controllers_queries**
    * Module **AdvancedFilters**
      * 🔑 **REWRITTEN** filter method

* **lib/helpers**
  * **smile_helpers_application**
    * Module **ExtendedQueries**
      * 🔑 **REWRITTEN** filter methods
  * **smile_helpers_issues**
  * **smile_helpers_queries**

* **lib/models**
  * **smile_models_issue**
  * **smile_models_issue_query**
  * **smile_models_project**
  * **smile_models_query**
  * **smile_models_query_custom_field_column**
  * **smile_models_time_entry**
  * **smile_models_time_entry_query**
  * **smile_models_time_time_query**

# Changelog

* **V1.0.13** Bugfix : QueryCustomFieldColumn.value_object merged Behaviour of Localizable plugin

  Param addded : original to preserve compatibility with Localizable plugin

* **V1.0.12** **criteria selection** at the beginning
* **V1.0.11** + **Estimated Hours filter** for Time Entries / Report queries
* **V1.0.10** Re-introducing Query **watcher_values** method for Older Redmine versions
* **V1.0.9** Small fixes, + List of tests

  Parent project column grouped as tree column, Time entries category column sort fixed

* **V1.0.8** Small enhancements and fixes :

  * **QueryColumn.group_value** added for old Redmine versions

  * Use respond_to?(or_filters_provided?) instead of respond_to?(or_filters)

  * Queries columns **selection boxes** **sorted** and glyphs prefixes (utf8) added

    **Hooks available** for other plugins

  * lib/models/smile_models_time_{entry/report}_query.rb **cleaned**
  * Time Report Advanced queries : **filter issue** dropdown list like parent, root

* **V1.0.7** REMOVED : Forbid setting global query public to other than me for non-admins : **Fixed upstream**

* **V1.0.6** +Spent/Billable/Deviation hours for issue/user **this** / **previous month**
