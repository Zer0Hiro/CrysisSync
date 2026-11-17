# CrisisSync - Use Case Specifications

Specifications for the 33 use cases in the Visual Paradigm model (`G11_Assignment1.vpp`).
**Main use cases** (UC-01 to UC-15) are the central use cases; their specifications are entered in Visual Paradigm 18.1.
**Other use cases** (UC-16 to UC-33) are kept here for completeness.
Main flows are numbered actor-system interactions. Extensions branch from a numbered main-flow step (`4a` = alternative at step 4).
"Logged in" means the actor completed **Log In** and holds the role named.

# Main use cases

---

## UC-01 Log In
- **Actors:** User (System Administrator, Logistics & Resources Officer, Dispatcher, Field Commander, Field Crew Member)
- **Preconditions:** The user has an active account. The CrisisSync client is connected to the server.
- **Success end condition:** The user is authenticated, a session is open, and the main screen of the user's role is displayed.
- **Failure end condition:** The user is not authenticated and no session is opened.

**Main flow:**
1. The user opens the CrisisSync client.
2. The system displays the login screen.
3. The user enters a username and a password and submits them.
4. The system validates the credentials against the active accounts.
5. The system identifies the user's role, opens a session and displays the role's main screen.

**Extensions:**
- 4a. The username or password is wrong: **Reject Invalid Login** (extension point: credential validation).
<!-- not in project story: - 4b. The account is deactivated: the system refuses the login and displays "Account is not active"; the use case ends. -->

---

## UC-02 Open Event
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in.
- **Success end condition:** A new open event exists with name, type, location and an automatically recorded opening time, and its live status screen is available.
- **Failure end condition:** No event is created.

**Main flow:**
1. The Dispatcher chooses to open an event.
2. The Dispatcher enters the name, the type (building collapse, fire, road accident, hazmat leak, natural disaster) and the location.
3. The Dispatcher confirms.
4. The system validates the data, records the opening time automatically, creates the event and records it in the audit log.
5. The system displays the event's live status screen.

**Extensions:**
<!-- not in project story: - 4a. A required field is missing: the system highlights it and the flow returns to step 2. -->

---

## UC-03 Create Task
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in and the event is open.
- **Success end condition:** A new task is saved with its name, estimated duration,resource package (exactly one Field Commander), its state is Blocked or Ready, and the status screens show it.
- **Failure end condition:** No task is created.

**Main flow:**
1. The Dispatcher selects the open event and chooses to create a task.
2. The Dispatcher enters the name, the estimated duratio and the required resource package.
3. The system validates that the package contains exactly one Field Commander.
4. The system saves the task as Blocked if a prerequisite is open, or Ready if none is open.
5. The system pushes the updated task tree to the status screens.

**Extensions:**
- 3a. The package does not contain exactly one Field Commander: the system shows an error and the flow returns to step 2.

---

## UC-04 Manage Task Tree
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in, the event is open and the event has tasks.
- **Success end condition:** The task's new prerequisites are saved, the task graph has no cycle, and the task is Blocked or Ready according to its prerequisites.
- **Failure end condition:** The task tree is unchanged.

**Main flow:**
1. The Dispatcher opens the event's task tree.
2. The Dispatcher selects a Blocked task and adds or changes its prerequisite tasks.
3. The system checks the dependency graph for cycles.
4. The system saves the new dependencies.
5. The system sets the task to Ready if no prerequisite is open; otherwise the task stays Blocked.
6. The system pushes the updated task tree to the status screens.

**Extensions:**
- 2a. The selected task is not Blocked: the system refuses because its dependencies are locked; the flow returns to step 2.
- 3a. The new or changed dependency creates a cycle: **Reject Cyclic Dependency** (extension point: dependency change).

---

## UC-05 Reserve Resources for Task (Manual)
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in and the task is in the Ready state.
- **Success end condition:** All resources of the package are reserved together in a single transaction, the task transitions to Active, and all screens reflect the change within performance thresholds (REQ-01, REQ-13, REQ-14).
- **Failure end condition:** No resources are reserved, the transaction rolls back, and the task remains Ready.

**Main flow:**
1. The Dispatcher selects a Ready task on the event status screen.
2. The system displays the required resource package and available resources within a maximum of 3 clicks (REQ-13).
3. The Dispatcher selects the required resources and confirms the reservation.
4. In a single database transaction, the system locks the selected resource records, verifies availability, and marks them as Reserved (REQ-01, REQ-14).
5. The system sets the task to Active, logs the action in the audit log, and pushes the status update.

**Extensions:**
- 1a. The task is not Ready: the system does not offer reservation; use case ends.
- 3a. The Dispatcher chooses automatic allocation: **Request Automatic Allocation** (extension point: resource selection).
- 3b. A Field Commander already reserved for another task is shown as unavailable and cannot be selected.
- 4a. A selected resource becomes unavailable at commit time: **Reject Unavailable Reservation** (extension point: transaction commit).

---

## UC-06 Request Automatic Allocation
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in and the task is in the Ready state.
- **Success end condition:** The resource package is automatically selected according to the chosen criterion, reserved in a single transaction, and the task becomes Active (REQ-04, REQ-05).
- **Failure end condition:** Allocation fails after permitted retries, the task stays Ready, and the Dispatcher is notified.

**Main flow:**
1. The Dispatcher chooses automatic allocation for a Ready task (REQ-04).
2. The Dispatcher selects an allocation criterion (e.g., geographic proximity to the event).
3. The system selects the best available resource for each package item based on the criterion (REQ-05).
4. The system attempts to reserve the package in a single transaction.
5. Upon success, the system sets the task to Active and displays the allocated resources.

**Extensions:**
- 3a. A package item has no available resource: allocation fails, Dispatcher is notified, task stays Ready.
- 4a. A selected resource is taken by a concurrent transaction: **Retry with Alternative Resource** (extension point: resource conflict).

---

## UC-07 View Event Status Screen
- **Actors:** Dispatcher, Field Commander
- **Preconditions:** The actor is logged in. Field Commander: commands at least one task of the event.
- **Success end condition:** The live status screen is displayed and stays up to date by server push.
- **Failure end condition:** No status screen is displayed.

**Main flow:**
1. The actor selects an open event (Dispatcher: any open event; Field Commander: events where they command a task).
2. The system displays the event name, type, location and elapsed time, the progress (completed tasks out of all tasks), the task tree with dependencies, and for each task its state, Field Commander, reserved resources and elapsed time against the estimated duration, with overdue tasks highlighted.
3. The system pushes every task or resource change to the screen immediately, without polling.
4. The actor starts actions from the screen (Dispatcher: reserve, cancel task, cancel or close event; Field Commander: report task completion).

**Extensions:**
<!-- not in project story: - 1a. The Field Commander commands no task in an open event: the system displays "No active events". -->
<!-- not in project story: - 3a. The connection to the server is lost: the system shows "Disconnected" and reloads the screen when the connection returns. -->

---

## UC-08 Report Task Completion
- **Actors:** Field Commander
- **Preconditions:** The Field Commander is logged in, commands the task, and the task is Active.
- **Success end condition:** The task is Completed, its resources are Available, dependent tasks whose prerequisites are all completed are Ready, and all screens show the change.
- **Failure end condition:** The task stays Active.

**Main flow:**
1. The Field Commander opens the event status screen.
2. The Field Commander selects their Active task.
3. The Field Commander reports the task as completed.
4. The system sets the task to Completed with the completion time.
5. The system releases the task's resources (**Release Task Resources**).
6. The system sets to Ready every dependent task whose prerequisites are all completed.
7. The system records it in the audit log and pushes the change.

**Extensions:**
- 2a. The Field Commander does not command the task: the system does not offer completion.
- 2b. The task is not Active: the system does not offer completion.

---

## UC-09 Cancel Task
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in and the task is not in a final state.
- **Success end condition:** The task is Cancelled, its resources are released, and dependent non-final tasks are handled.
- **Failure end condition:** The task remains unchanged or it's resources are not released.

**Main flow:**
1. The Dispatcher selects a non-final task on the event status screen and initiates cancellation.
2. The system checks for non-final dependent tasks.
3. The system cancels the task, releases its resources (**Release Task Resources**), records the timestamp in the audit log, and pushes the update.

**Extensions:**
- 1a. The task is in a final state: cancellation is not offered.
- 2a. The task has non-final dependent tasks: invokes **Cancel Dependent Tasks** and requests confirmation before proceeding.

---

## UC-10 Cancel Event
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in and the event is open.
- **Success end condition:** The event is Cancelled with an automatically recorded cancellation time, all its non-final tasks are Cancelled and their resources are Available.
- **Failure end condition:** The event and its tasks are unchanged and their resources are not released.

**Main flow:**
1. The Dispatcher selects the open event on its status screen.
2. The Dispatcher chooses to cancel the event.
3. The system shows how many non-final tasks will be cancelled and asks for confirmation.
4. The Dispatcher confirms.
5. The system cancels every non-final task and releases its resources (**Release Task Resources**).
6. The system marks the event Cancelled, records the cancellation time automatically, records it in the audit log and pushes the change.

**Extensions:**
<!-- not in project story: - 4a. The Dispatcher declines: nothing changes; the use case ends. -->

---

## UC-11 Report Equipment Malfunction
- **Actors:** Field Personnel (Field Commander, Field Crew Member)
- **Preconditions:** The actor is logged in and is assigned to an active task and the item is one of the task’s reserved equipment resources..
- **Success end condition:** The item is Faulty/In repair immediately and the Dispatcher is alerted to allocate a replacement.
- **Failure end condition:** The item's status is unchanged.

**Main flow:**
1. The actor opens their task.
2. The actor selects the equipment item.
3. The actor reports a malfunction with a short description.
4. The system sets the item to Faulty/In repair immediately and records it in the audit log.
5. The system alerts the Dispatcher (**Allocate Replacement Equipment**) and pushes the change.

**Extensions:**
<!-- not in project story: - 2a. The item is not part of the actor's task: the system does not list it. -->

---

## UC-12 Allocate Replacement Equipment
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher is logged in. An equipment item reserved for an active task was marked faulty.
- **Success end condition:** An available item of the same type is reserved for the task and the task stays Active.
- **Failure end condition:** No replacement is reserved and the task is flagged as missing equipment.

**Main flow:**
1. The system alerts the Dispatcher on the status screen that the task lost an equipment item.
2. The Dispatcher selects the task.
3. The system lists the available items of the same type, nearest first.
4. The Dispatcher selects a replacement.
5. The system reserves it in one transaction, updates the task's resources, records it in the audit log and pushes the change.

**Extensions:**
<!-- not in project story: - 3a. No item of that type is available: the system informs the Dispatcher and flags the task as missing equipment. -->
- 5a. The item was reserved concurrently: the system rolls back, shows a message and the flow returns to step 3.

---

## UC-13 Close Event & Settle Costs
- **Actors:** Dispatcher, National Clearing & Settlement System
- **Preconditions:** The Dispatcher is logged in, the event is open and all its tasks are Completed or Cancelled.
- **Success end condition:** The settlement approval and transaction token are stored, and the event is Closed with an automatically recorded closing time.
- **Failure end condition:** The event stays open and the Dispatcher is alerted.

**Main flow:**
1. The Dispatcher selects the event and chooses to close it.
2. The system verifies that all tasks are in a final state.
3. The system calculates the operating costs (**Calculate Operating Costs**).
4. The system sends the billing and budget reimbursement request to the National Clearing & Settlement System.
5. The National Clearing & Settlement System returns an approval with a transaction token.
6. The system stores the approval and the token, closes the event, records the closing time and records it in the audit log.

**Extensions:**
- 2a. A task is not in a final state: the system refuses to close and lists the open tasks.
- 5a. The National Clearing & Settlement System rejects the settlement: **Handle Settlement Rejection** (extension point: settlement response).
<!-- not in project story: - 5b. No response arrives within the timeout: the event stays open and the Dispatcher is alerted to try again. -->

---

## UC-14 Generate Report
- **Actors:** Scheduler (primary, monthly), System Administrator (on demand)
- **Preconditions:** Scheduler: the system clock reached the end of a month. System Administrator: logged in.
- **Success end condition:** The Resource Utilization Report and the SLA Compliance Report for the month are stored and can be viewed.
- **Failure end condition:** No report is stored, the failure is logged and the System Administrator is notified.

**Main flow:**
1. The Scheduler triggers report generation at the end of the month, or the System Administrator requests reports for a selected past month.
2. The system determines the reporting month.
3. The system produces the resource utilization report (**Produce Resource Utilization Report**).
4. The system produces the SLA report (**Produce SLA Compliance Report**).
5. The system stores both reports with the generation time.

**Extensions:**
- 2a. The System Administrator selected the current or a future month: the system asks for a completed month and the flow returns to step 1.
<!-- not in project story: - 5a. The reports cannot be stored: the system logs the error and notifies the System Administrator; the use case ends. -->

---

## UC-15 Produce SLA Compliance Report
- **Actors:** Scheduler, System Administrator (through Generate Report)
- **Preconditions:** Generate Report determined the reporting month.
- **Success end condition:** An SLA report is produced with the average time from event opening to closure of its last task, for each event type.
- **Failure end condition:** No SLA report is produced and Generate Report fails at step 4.

**Main flow:**
1. The system selects the events whose last task was closed in the reporting month.
2. For each event, the system computes the time from event opening to closure of its last task.
3. The system groups the events by event type and computes the average time per type.
4. The system builds the SLA report as a table of event types and average times.

**Extensions:**
<!-- not in project story: - 1a. No event qualifies: the system produces the report with "no data" for every event type. -->
<!-- not in project story: - 1b. An event was cancelled: the system excludes it from the averages. -->

# Other use cases

---

## UC-16 Reject Invalid Login
- **Actors:** User
- **Preconditions:** The user submitted a username and password that do not match an active account.
- **Success end condition:** The login is refused, no session is opened, and the user can try again.
- **Failure end condition:** No session is opened and the user remains on the login screen, or a session is opened and the login is accepted.

**Main flow:**
1. The system detects that the username or password is wrong.
2. The system refuses the login and displays "Invalid username or password" without saying which field is wrong.
3. The system clears the password field.
4. The user enters the credentials again and the flow returns to **Log In** step 3.

**Extensions:**
<!-- not in project story: - 4a. The user closes the login screen: the use case ends without a session. -->

---

## UC-17 Manage User Accounts & Permissions
- **Actors:** System Administrator
- **Preconditions:** The System Administrator is logged in.
- **Success end condition:** The account is created, updated or deactivated with its role and permissions saved, and the change is recorded in the audit log.
- **Failure end condition:** No account data is changed.

**Main flow:**
1. The System Administrator opens user management.
2. The system lists all accounts with username, name, role and status.
3. The System Administrator chooses to create an account or selects an existing one.
4. The System Administrator enters or edits the username, name, role (closed list of five roles) and permissions.
5. The System Administrator saves.
6. The system validates the data (unique username, all required fields present).
7. The system saves the account, refreshes the list and records the change in the audit log.

**Extensions:**
<!-- not in project story: - 3a. The System Administrator chooses to deactivate a selected account: the system asks for confirmation, marks the account inactive and records the change; the use case ends. -->
<!-- not in project story: - 6a. The username already exists: the system shows an error and the flow returns to step 4. -->
<!-- not in project story: - 6b. A required field is missing: the system highlights it and the flow returns to step 4. -->

---

## UC-18 Load Initial Data
- **Actors:** System Administrator
- **Preconditions:** The System Administrator is logged in. A data file (SQL script, JSON or CSV) with users, crew members and equipment items is available.
- **Success end condition:** All records of the file are stored in the database and a load summary is displayed.
- **Failure end condition:** The database is unchanged and the error is displayed.

**Main flow:**
1. The System Administrator opens the data loading utility.
2. The System Administrator selects the data file.
3. The system validates the file format and every record.
4. The system stores all records in one database transaction.
5. The system displays a summary of the loaded users, crew members and equipment items.

**Extensions:**
<!-- not in project story: - 3a. The file format or a record is invalid: the system rejects the file, shows the first invalid record and its error, and loads nothing. -->
<!-- not in project story: - 4a. The database transaction fails: the system rolls back, displays the error and loads nothing. -->

---

## UC-19 View Event History
- **Actors:** System Administrator
- **Preconditions:** The System Administrator is logged in.
- **Success end condition:** The System Administrator has viewed the requested events. The history is unchanged (read-only).
- **Failure end condition:** No history is displayed and an error message is shown. The history is unchanged.

**Main flow:**
1. The System Administrator opens the event history.
2. The system lists all events (open, closed and cancelled).
3. The System Administrator filters by date range, event type and status.
4. The system displays the matching events.
5. The System Administrator selects an event.
6. The system displays the event's tasks, the resources reserved for each task, the settlement approvals and the full timeline of actions with the time and user of each action.

**Extensions:**
<!-- not in project story: - 4a. No event matches the filter: the system displays "No events found" and the flow returns to step 3. -->
<!-- not in project story: - 6a. The history cannot be loaded from the database: the system displays an error; the use case ends. -->

---

## UC-20 Produce Resource Utilization Report
- **Actors:** Scheduler, System Administrator (through Generate Report)
- **Preconditions:** Generate Report determined the reporting month.
- **Success end condition:** A utilization report is produced with the percentage of the month each resource’s utilization, by equipment type and by crew role, in graphical form.
- **Failure end condition:** No utilization report is produced and Generate Report fails at step 3.

**Main flow:**
1. The system collects the reservation intervals of every resource in the reporting month.
2. The system computes each resource's utilization as reserved time divided by the month's time.
3. The system aggregates utilization by equipment type and by crew role.
4. The system builds the report with charts and a table.

**Extensions:**
<!-- not in project story: - 1a. A resource had no reservation in the month: the system reports 0% for it. -->

---

## UC-21 View Reports
- **Actors:** System Administrator
- **Preconditions:** The System Administrator is logged in.
- **Success end condition:** The selected report is displayed.
- **Failure end condition:** No report is displayed.

**Main flow:**
1. The System Administrator opens the reports screen.
2. The system lists the stored reports by month and type.
3. The System Administrator selects a report.
4. The system displays the report (charts for utilization, a table for SLA).

**Extensions:**
<!-- not in project story: - 2a. No report exists: the system displays "No reports yet" and offers on-demand generation (**Generate Report**). -->

---

## UC-22 Update Equipment Maintenance Status
- **Actors:** Logistics & Resources Officer
- **Preconditions:** The Logistics & Resources Officer is logged in.
- **Success end condition:** The item's status is Faulty/In repair or Available, the change is in the audit log and all relevant screens show it.
- **Failure end condition:** The item's status is unchanged.

**Main flow:**
1. The Logistics & Resources Officer opens the equipment pool.
2. The system lists the items with ID, type, location and status.
3. The Logistics & Resources Officer selects an item.
4. The Logistics & Resources Officer sets the status to Faulty/In repair or to Available.
5. The system validates and saves the change.
6. The system pushes the change to the relevant screens and records it in the audit log.

**Extensions:**
<!-- not in project story: - 5a. The item is reserved for an active task and is set to Faulty: the system marks it faulty and alerts the Dispatcher to allocate a replacement (**Allocate Replacement Equipment**). -->
<!-- not in project story: - 5b. The new status equals the current status: the system shows "No change" and the flow returns to step 4. -->

---

## UC-23 Transfer Equipment Between Stations
- **Actors:** Logistics & Resources Officer
- **Preconditions:** The Logistics & Resources Officer is logged in.
- **Success end condition:** The item's current location is the destination station and the change is in the audit log.
- **Failure end condition:** The item's location is unchanged.

**Main flow:**
1. The Logistics & Resources Officer opens the equipment pool.
2. The Logistics & Resources Officer selects an item.
3. The Logistics & Resources Officer selects the destination station.
4. The Logistics & Resources Officer confirms the transfer.
5. The system updates the item's location, records it in the audit log and pushes the change.

**Extensions:**
<!-- not in project story: - 2a. The item is reserved for a task: the system refuses the transfer and shows the task; the use case ends. -->
<!-- not in project story: - 3a. The destination is the current station: the system shows an error and the flow returns to step 3. -->

---

## UC-24 Update Crew Member Exceptional Availability
- **Actors:** Logistics & Resources Officer
- **Preconditions:** The Logistics & Resources Officer is logged in.
- **Success end condition:** The crew member is Unavailable for the given reason and period, or Available again, and the change is in the audit log.
- **Failure end condition:** The crew member's status is unchanged.

**Main flow:**
1. The Logistics & Resources Officer opens the personnel list.
2. The Logistics & Resources Officer selects a crew member.
3. The Logistics & Resources Officer sets Unavailable with a reason (vacation or sickness) and a period, or sets Available.
4. The system saves the status, records it in the audit log and pushes the change to the Dispatchers.

**Extensions:**
<!-- not in project story: - 3a. The crew member is reserved for an active task: the system refuses the change and shows the task; the use case ends. -->

---

## UC-25 Reject Cyclic Dependency
- **Actors:** Dispatcher
- **Preconditions:** The Dispatcher added or changed a dependency that would create a cycle.
- **Success end condition:** The change is rejected, the task tree is unchanged and the Dispatcher knows which tasks form the cycle.
- **Failure end condition:** The task tree has a cycle.

**Main flow:**
1. The system detects the cycle in the dependency graph.
2. The system rejects the change and keeps the previous dependencies.
3. The system displays a message naming the tasks that form the cycle.
4. The Dispatcher returns to editing (**Manage Task Tree** step 2).

**Extensions:**
<!-- not in project story: - 4a. The Dispatcher closes the task tree: the use case ends with the tree unchanged. -->

---

## UC-26 Reject Unavailable Reservation
- **Actors:** Dispatcher
- **Preconditions:** At commit time at least one selected resource is not available (for example, another Dispatcher reserved it at the same moment).
- **Success end condition:** The whole transaction is rolled back, no resource is reserved, the task is Ready and the Dispatcher sees a clear message and the current state.
- **Failure end condition:** No resource is reserved and the task is Ready.

**Main flow:**
1. The system detects the unavailable resource.
2. The system rolls back the entire reservation transaction.
3. The system keeps the task Ready.
4. The system tells the Dispatcher which resource was unavailable.
5. The system refreshes the Dispatcher's screen to the current state.
6. The Dispatcher selects other resources (**Reserve Resources for Task** step 3).

**Extensions:**
<!-- not in project story: - 6a. The Dispatcher stops: the use case ends with the task Ready. -->

---

## UC-27 Retry with Alternative Resource (Automatic Allocation)
- **Actors:** Dispatcher
- **Preconditions:** Selected resource taken in concurrent allocation (REQ-06, REQ-07, REQ-08).
- **Success end condition:** Automatically cycles through up to 2 alternative resource attempts before succeeding or failing.

**Main flow:**
1. The system rolls back the failed attempt.
2. The system selects the next-best available alternative for the conflicting item.
3. The system tries the reservation again, without blocking the server for other users.
4. The reservation succeeds and flow returns to **Request Automatic Allocation** step 5.

**Extensions:**
- 3a. Reservation conflicts again and fewer than 2 alternatives tried: returns to step 2.
- 3b. Second alternative fails or none exist: allocation fails, Dispatcher notified, task stays Ready.

---

## UC-28 Cancel Dependent Tasks
- **Actors:** Dispatcher
- **Preconditions:** The task selected for cancellation has direct or indirect dependent tasks that are not final.
- **Success end condition:** After the Dispatcher's confirmation, the task and all its non-final dependent tasks are Cancelled and their resources are Available.
- **Failure end condition:** Not all tasks dependent are cancelled.

**Main flow:**
1. The system finds all direct and indirect dependent tasks that are not final.
2. The system displays a message with the number of tasks that will be cancelled.
3. The Dispatcher confirms.
4. The system cancels these tasks and releases their resources (**Release Task Resources**), and the flow returns to **Cancel Task** step 3.

**Extensions:**
- 3a. The Dispatcher declines: the whole cancellation is aborted; no task is cancelled.

---

## UC-29 Release Task Resources
- **Actors:** Dispatcher, Field Commander (through Cancel Event, Cancel Task, Report Task Completion)
- **Preconditions:** The task was completed or cancelled.
- **Success end condition:** Every resource reserved for the task is Available again (faulty items stay Faulty/In repair) and the release time is recorded.
- **Failure end condition:** The resources keep their previous status and the error is logged.

**Main flow:**
1. The system gets the resources reserved for the task.
2. The system sets each resource to Available and removes it from the task.
3. The system records the release time (used for utilization) in the audit log.
4. The system pushes the change to the relevant screens.

**Extensions:**
- 2a. An equipment item is Faulty/In repair: the system removes it from the task but keeps its status.

---

## UC-30 Calculate Operating Costs
- **Actors:** Dispatcher (through Close Event & Settle Costs)
- **Preconditions:** All tasks of the event are in a final state.
- **Success end condition:** The total operating cost and its breakdown are computed.
- **Failure end condition:** No cost is computed and closing stops at step 3.

**Main flow:**
1. The system sums the active hours of all personnel reserved for the event's tasks.
2. The system sums the engine hours of the engineering and medical equipment used.
3. The system adds the consumable materials.
4. The system produces a cost summary per category and a total.

**Extensions:**
<!-- not in project story: - 1a. A resource has no recorded hours: the system counts 0 hours for it and marks it in the summary. -->

---

## UC-31 Handle Settlement Rejection
- **Actors:** Dispatcher, National Clearing & Settlement System
- **Preconditions:** The National Clearing & Settlement System rejected the settlement request.
- **Success end condition:** The event stays open, the rejection is recorded and the Dispatcher is alerted with the reason.
- **Failure end condition:** The event stays open.

**Main flow:**
1. The system receives the rejection and its reason.
2. The system records the rejection in the audit log.
3. The system keeps the event open.
4. The system alerts the Dispatcher with the rejection reason.

**Extensions:**
- 4a. The Dispatcher tries to close the event again later: **Close Event & Settle Costs** starts again.

---

## UC-32 View Task Details
- **Actors:** Field Personnel (Field Commander, Field Crew Member)
- **Preconditions:** The actor is logged in and is assigned to a task.
- **Success end condition:** The details of the actor's task are displayed.
- **Failure end condition:** No task details are displayed.

**Main flow:**
1. The actor opens "My task".
2. The system displays the task name, the event and its location, the estimated duration, the Field Commander, the reserved crew and equipment, and the task state.

**Extensions:**
<!-- not in project story: - 1a. The actor is not assigned to a task: the system displays "No current task". -->

---

## UC-33 Report Shift Start & Readiness
- **Actors:** Field Crew Member
- **Preconditions:** The Field Crew Member is logged in.
- **Success end condition:** The shift start time is recorded and the member's status is Available or Unavailable as reported.
- **Failure end condition:** No shift start is recorded and the status is unchanged.

**Main flow:**
1. The Field Crew Member reports the start of the shift.
2. The system records the shift start time.
3. The Field Crew Member reports readiness: available or not available.
4. The system updates the member's status, records it in the audit log and pushes the change to the Dispatchers.

**Extensions:**
<!-- not in project story: - 3a. The member is currently reserved for a task: the system keeps the status Reserved and stores the readiness for when the reservation ends. -->
