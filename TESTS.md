* Queries
  * Advanced filters :
    * root                                                     OK
    * parent                                                   OK
    * issue                                                    OK
    * children count                                           OK
    * level in tree                                            OK
    New checkbox in queries form
    * Enables new filters                                      OK

  * Show issue query owner for Admins in query edition         OK
  * SMILE SPECIFIC : Conversion in days
    * Issues list                                              OK
    * Issue show                                               OK
    * Time entries                                             OK
    * Time report                                              OK
    * CSV                                                      OK
    * Pdf                                                      OK
  * Time Report Queries
    * Specialized queries form :                               OK
      * No columns selection                                   OK
      * Criteria multiple values selection (arrows buttons)    OK
  * Or filters
    * Like filters but with non exclusive filters              OK
  * SMILE SPECIFIC : total F / G / D at the group level
    * Issues                                                   H.S.
  * SMILE SPECIFIC : sum time with children                    ?
  * Custom fields
    * + User Custom Fields values (value_object)               OK
  * Issues
    * New Issue query columns
      * Parent issue Projet                                    OK
      * SMILE SPECIFIC : BU Project                            OK
      * Watchers                                               OK
      * Project updated (date)                                 OK
      * SMILE SPECIFIC : Separate subject, tracker, status     OK
    * New Issue query filters
      * Parent issue Projet                                    OK
      * (B)usiness (U)nit                                      OK
      * Watchers                                               OK
      * Project updated (date)                                 OK
      * Subproject filter : remove current project by default  OK
  * Time entries
    * New Time entries columns
      * Tracker : + groupable                                  OK
      * Subject                                                OK
      * Root                                                   OK
      * Parent                                                 OK
      * Fixed version                                          OK
      * Category : + groupable                                 OK

        Test sort by Category                                  OK

      * Issue Id                                               OK
      * Subject                                                OK
      * Estimated hours                                        OK
      * Hours
        * Hours for issue and user                             OK
        * Hours for issue                                      OK
        * Hours for user                                       OK
        * Hours for issue and user this month                  OK
        * Hours for issue this month                           OK
        * Hours for user this month                            OK
        * Hours for issue and user previous month              OK
        * Hours for issue previous month                       OK
        * Hours for user previous month                        OK
      * Hours Totals
        * Hours for issue and user                             OK
        * Hours for issue                                      OK
        * Hours for user                                       OK
    * New Time entries filters
      * Project updated (date)                                 OK
      * Root                                                   ?
      * Parent                                                 ?
      * Issue                                                  ?
      * Issue created on                                       ?
      * Assignee's Member of group                             ?
      * User is me                                             ?
      * Author is me                                           ?
      * SMILE SPECIFIC : BU Project                            ?
      * Last Time entry
        * Is last Time Entry for issue and user                ?
        * Is last Time Entry for issue                         ?
        * Is last Time Entry for user                          ?
  * Time report
    * New Time report filters                                  ?
      * Project updated (date)                                 OK
      * Root                                                   ?
      * Parent                                                 ?
      * Issue                                                  ?
      * Issue created on                                       ?
      * Assignee's Member of group                             ?
      * User is me                                             ?
      * Author is me                                           ?
      * SMILE SPECIFIC : BU Project                            ?
* Error :
  https://redmine-projets-inte.vitry.intranet/projects/redmine-wf-v1/issues?utf8=%E2%9C%93&set_filter=1&sort=parent&f%5B%5D=status_id&op%5Bstatus_id%5D=o&f%5B%5D=estimated_hours&op%5Bestimated_hours%5D=%3E%3D&v%5Bestimated_hours%5D%5B%5D=0.01&f%5B%5D=&c%5B%5D=project&c%5B%5D=parent&c%5B%5D=tracker&c%5B%5D=status&c%5B%5D=subject&c%5B%5D=assigned_to&c%5B%5D=fixed_version&c%5B%5D=due_date&c%5B%5D=estimated_hours&c%5B%5D=done_ratio&hours_by_day=8.0&advanced_filters=1&group_by=&t%5B%5D=estimated_hours&t%5B%5D=
