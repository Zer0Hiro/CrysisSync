# Requirements Architecture & System Specification
**Course:** Software Engineering Methods  
**System:** CrisisSync Emergency Management System
**Group Number:** 11

## Requirements Traceability Matrix (RTM)

| Req ID     | Requirement Description                                                                                                                                                                                              | Type (FR/NFR)     | Operation | Mapped Use Case                                         | Test ID                   |
|:-----------|:---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:-----------------:|:---------:|:--------------------------------------------------------|:-------------------------:|
| **REQ-01** | The System shall set a task to the Active state only after the Dispatcher has reserved all resources of the task's resource package in a single transaction.                                                       | FR                | 1         | Reserve Resources for Task                              | TEST-01, TEST-02          |
| **REQ-02** | If any resource of the package cannot be reserved, the System shall roll back the entire reservation transaction, reserve none of the resources and keep the task in the Ready state.                              | FR                | 1         | Reserve Resources for Task, Reject Unavailable Reservation | TEST-02, TEST-03, TEST-04 |
| **REQ-03** | The System shall let the Dispatcher reserve a complete resource package for a Ready task with no more than 3 clicks.                                                                                               | NFR (Usability)   | 1         | Reserve Resources for Task                              | TEST-01                   |
| **REQ-04** | The System shall complete the reservation transaction and return a success or failure response to the Dispatcher within 1.5 seconds.                                                                               | NFR (Performance) | 1         | Reserve Resources for Task                              | TEST-01, TEST-02          |
| **REQ-05** | After a task completion report, the System shall push the updated task and resource status to all relevant event status screens within 500 milliseconds.                                                           | NFR (Performance) | 1         | Report Task Completion, View Event Status Screen        | TEST-07                   |
| **REQ-06** | The System shall allow only the Field Commander assigned to a task to report that task's completion.                                                                                                                 | FR                | 1         | Report Task Completion                                  | TEST-08                   |
| **REQ-07** | At the end of each calendar month, the System shall automatically generate the SLA report for the month that ended.                                                                                                 | FR                | 2         | Generate Report, Produce SLA Compliance Report          | TEST-05, TEST-06          |
| **REQ-08** | When the assigned Field Commander reports a task's completion, the System shall set the task to Completed, return all its resources to Available, and set to Ready every dependent task whose prerequisites are all Completed. | FR | 1 | Report Task Completion, Release Task Resources          | TEST-07                   |
| **REQ-09** | When two reservation transactions request the same resource at the same time, the System shall reserve the resource for at most one task, with 0 double reservations in 1,000 concurrent reservation attempts.     | NFR (Reliability) | 1         | Reserve Resources for Task, Reject Unavailable Reservation | TEST-04                |
| **REQ-10** | The System shall reject 100% of reservation requests and completion reports that do not come from an authenticated session of an authorized role, and shall encrypt all client-server traffic with TLS 1.2 or higher. | NFR (Security) | 1         | Reserve Resources for Task, Report Task Completion      | TEST-08                   |
| **REQ-11** | The SLA report shall show, for each event type, the average time from the opening of an event to the closure of its last task, for the events whose last task was closed in the reporting month.                 | FR                | 2         | Produce SLA Compliance Report                           | TEST-05                   |
| **REQ-12** | The System shall let the System Administrator produce the SLA report on demand for a selected month in the past.                                                                                                     | FR                | 2         | Generate Report, Produce SLA Compliance Report          | TEST-09, TEST-10          |
| **REQ-13** | The System shall generate the SLA report for a month with up to 10,000 events within 30 seconds.                                                                                                                    | NFR (Performance) | 2         | Produce SLA Compliance Report                           | TEST-05, TEST-09          |
| **REQ-14** | If the monthly SLA report cannot be generated because the server or the database is unavailable, the System shall generate the missing report within 5 minutes after both are available again.                    | NFR (Reliability) | 2         | Generate Report                                         | TEST-06                   |
| **REQ-15** | The System shall display SLA reports only to authenticated System Administrator sessions.                                                     | NFR (Security)    | 2         | View Reports                                            | TEST-11                   |

**Coverage:** Operation 1 has 4 FR (REQ-01, 02, 06, 08) and 5 NFR (REQ-03, 04, 05, 09, 10). Operation 2 has 3 FR (REQ-07, 11, 12) and 3 NFR (REQ-13, 14, 15). The NFRs cover performance, security, reliability and usability, each with a measurable threshold.

---

## Acceptance Tests (Given-When-Then)

### Operation 1: Reserving a resource package and reporting task completion

### Acceptance Test [TEST-01]: Reserve a complete package (Happy Path) - REQ-01, REQ-03, REQ-04
* **Given:** A task is in the Ready state, and every resource of its resource package is available.
* **When:** The Dispatcher selects a resource for each package item and confirms the reservation, using no more than 3 clicks.
* **Then:** The task moves to the Active state.
* **And:** All selected resources are marked as Reserved for the task.
* **And:** The Dispatcher receives the success response within 1.5 seconds.

### Acceptance Test [TEST-02]: Package with an unavailable resource (Exception) - REQ-01, REQ-02, REQ-04
* **Given:** A task is in the Ready state, one resource of its package is not available, and the others are available.
* **When:** The Dispatcher attempts to reserve the package.
* **Then:** The task remains in the Ready state.
* **And:** None of the resources are marked as Reserved for the task.
* **And:** The Dispatcher receives a failure message naming the unavailable resource within 1.5 seconds.

### Acceptance Test [TEST-03]: Resource taken during the transaction, then recovery (Error / Recovery) - REQ-02
* **Given:** A task is in the Ready state, and all resources of its package were available when the Dispatcher selected them.
* **When:** One of the selected resources becomes reserved by another task before the Dispatcher's transaction commits.
* **Then:** The System rolls back the entire reservation transaction and reserves none of the resources.
* **And:** The task stays in the Ready state, and the Dispatcher's screen is refreshed to show the current availability.
* **When:** The Dispatcher selects an available alternative for that item and confirms again.
* **Then:** The reservation succeeds and the task moves to the Active state.

### Acceptance Test [TEST-04]: Two Dispatchers reserve the same resource at once (Concurrency) - REQ-02, REQ-09
* **Given:** Two different tasks are in the Ready state, and both of their resource packages include the same available bulldozer.
* **And:** Two Dispatchers are logged in at separate stations.
* **When:** Both Dispatchers confirm the reservation of their task's package at the same moment.
* **Then:** Exactly one of the reservations succeeds and its task moves to the Active state.
* **And:** The other task remains in the Ready state with none of its resources reserved, and its Dispatcher receives a failure message.
* **And:** The bulldozer is reserved for exactly one task (no double reservation).

### Acceptance Test [TEST-07]: Report task completion (Happy Path) - REQ-08, REQ-05
* **Given:** Task A is in the Active state with its resources reserved, and its assigned Field Commander is logged in.
* **And:** Task B depends only on Task A and is in the Blocked state.
* **When:** The Field Commander reports Task A as completed.
* **Then:** Task A moves to the Completed state.
* **And:** All resources of Task A return to Available.
* **And:** Task B moves to the Ready state.
* **And:** All relevant event status screens show the change within 500 milliseconds.

### Acceptance Test [TEST-08]: Completion reported by an unauthorized user (Exception) - REQ-06, REQ-10
* **Given:** A task is in the Active state, and a Field Commander who is not assigned to it is logged in.
* **When:** That Field Commander attempts to report the task as completed.
* **Then:** The System rejects the report.
* **And:** The task stays in the Active state and its resources stay Reserved.
* **And:** The rejected attempt is recorded in the audit log.

### Operation 2: Producing the SLA report

### Acceptance Test [TEST-05]: Automatic monthly SLA report (Happy Path) - REQ-07, REQ-11, REQ-13
* **Given:** The system contains events of several event types whose last task was closed during the current calendar month.
* **When:** The system clock reaches the end of the calendar month.
* **Then:** The System generates the SLA report for that month within 30 seconds.
* **And:** The report shows, for each event type, the average time from event opening to the closure of its last task.
* **And:** The report is available for the System Administrator to view.

### Acceptance Test [TEST-06]: Database unavailable at month end, then recovery (Exception / Timeout) - REQ-07, REQ-14
* **Given:** The system clock reaches the end of the calendar month, but the database is unavailable.
* **When:** The System attempts to generate the SLA report automatically.
* **Then:** The data retrieval times out, and the System safely aborts the generation and logs the failure.
* **And:** The System Administrator receives an alert that the report could not be generated.
* **When:** The database becomes available again.
* **Then:** The System generates the missing SLA report within 5 minutes, and the report is available to view.

### Acceptance Test [TEST-09]: SLA report on demand for a past month (Happy Path) - REQ-12, REQ-13
* **Given:** The System Administrator is logged in, and the system contains closed events from a past month.
* **When:** The System Administrator requests the SLA report for that past month.
* **Then:** The System generates the report for the selected month within 30 seconds.
* **And:** The report is displayed to the System Administrator.

### Acceptance Test [TEST-10]: SLA report requested for a month that has not ended (Error) - REQ-12
* **Given:** The System Administrator is logged in.
* **When:** The System Administrator requests the SLA report for the current month.
* **Then:** The System refuses the request and asks for a month in the past.
* **And:** No report is generated or stored.

### Acceptance Test [TEST-11]: SLA report accessed by another role (Security) - REQ-15
* **Given:** A Dispatcher is logged in, and an SLA report exists.
* **When:** The Dispatcher attempts to open the SLA report.
* **Then:** The System denies access.
* **And:** The denied attempt is recorded in the audit log.
