# Requirements Architecture & System Specification
**Course:** Software Engineering Methods  
**System:** CrisisSync Emergency Management System
**Group Number:** 11 
**Github Link:** https://github.com/Zer0Hiro/CrysisSync

**Team Members:**
- Dima Chybisov (dima.chybisov@e.braude.ac.il)
- Itay Rosen (itay.rosen@e.braude.ac.il)
- Jacob Fumm (jacob.fumm@e.braude.ac.il)
- Tomer Pine (tomer.pine@e.braude.ac.il)

Requirements and acceptance tests for the two operations defined in Assignment 1, Part B:
1. **Reserving a resource package for a task (manually or by automatic allocation), including reporting the task's completion.**
2. **Producing the SLA (on-time / service level) report.**

Each requirement states one behaviour or one measurable quality. Use case names refer to the Visual Paradigm model (`UseCase/G11_Assignment1.vpp`).

## Requirements Traceability Matrix (RTM)

| Req ID     | Requirement Description                                                                                                                                                                                      |     Type (FR/NFR)     | Mapped Use Case                                              |          Test ID          |
|:-----------|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|:---------------------:|:-------------------------------------------------------------|:-------------------------:|
| **REQ-01** | The System shall set a task to the Active state only after all resources of the task's resource package have been reserved together.                                                                         |          FR           | Reserve Resources for Task                                   |     TEST-01, TEST-02      |
| **REQ-02** | If any resource of the package cannot be reserved, the System shall roll back the entire reservation, leaving none of the package's resources reserved.                                                      |          FR           | Reserve Resources for Task, Reject Unavailable Reservation   | TEST-02, TEST-03, TEST-04 |
| **REQ-03** | After a failed reservation, the System shall keep the task in the Ready state.                                                                                                                               |          FR           | Reject Unavailable Reservation                               | TEST-02, TEST-03, TEST-04 |
| **REQ-04** | The System shall let the Dispatcher request automatic allocation of a Ready task's resource package.                                                                                                         |          FR           | Request Automatic Allocation                                 |             —             |
| **REQ-05** | The System shall select each resource of the package according to the allocation criterion chosen by the Dispatcher.                                                                                         |          FR           | Request Automatic Allocation                                 |             —             |
| **REQ-06** | If a resource selected by automatic allocation is reserved by a concurrent allocation, the System shall automatically select the next-best available alternative for that resource.                          |          FR           | Retry with Alternative Resource                              |             —             |
| **REQ-07** | The System shall make no more than 2 alternative attempts per resource during an automatic allocation.                                                                                                       |          FR           | Retry with Alternative Resource                              |             —             |
| **REQ-08** | The System shall fail an automatic allocation only when no available alternative remains within the 2 alternative attempts.                                                                                  |          FR           | Retry with Alternative Resource                              |             —             |
| **REQ-09** | The System shall allow only the Field Commander assigned to a task to report that task's completion.                                                                                                         |          FR           | Report Task Completion                                       |             —             |
| **REQ-10** | When the assigned Field Commander reports a task's completion, the System shall set the task to the Completed state.                                                                                         |          FR           | Report Task Completion                                       |             —             |
| **REQ-11** | When a task is completed, the System shall return all of its resources to Available.                                                                                                                         |          FR           | Release Task Resources                                       |             —             |
| **REQ-12** | When a task is completed, the System shall set to Ready every dependent task whose prerequisites are all Completed.                                                                                          |          FR           | Report Task Completion                                       |             —             |
| **REQ-13** | The System shall let the Dispatcher reserve a complete resource package manually for a Ready task with no more than 3 clicks.                                                                                |    NFR (Usability)    | Reserve Resources for Task                                   |          TEST-01          |
| **REQ-14** | The System shall complete a reservation transaction and return a success or failure response to the Dispatcher within 1.5 seconds.                                                                           |   NFR (Performance)   | Reserve Resources for Task                                   |          TEST-01          |
| **REQ-15** | The System shall complete an automatic allocation, including its alternative attempts, within 3 seconds.                                                                                                     |   NFR (Performance)   | Request Automatic Allocation                                 |             —             |
| **REQ-16** | While an automatic allocation is running, the System shall respond to other users' requests within 1.5 seconds.                                                                                              |   NFR (Performance)   | Request Automatic Allocation                                 |             —             |
| **REQ-17** | After a task completion report, the System shall push the updated task and resource status to all relevant event status screens within 500 milliseconds.                                                     |   NFR (Performance)   | Report Task Completion, View Event Status Screen             |             —             |
| **REQ-18** | When two reservations request the same available resource at the same time, the System shall reserve the resource for at most one task, with 0 double reservations in 1,000 concurrent reservation attempts. |   NFR (Reliability)   | Reserve Resources for Task, Reject Unavailable Reservation   |          TEST-04          |
| **REQ-19** | The System shall reject 100% of reservation requests and completion reports that do not come from an authenticated session of an authorized role.                                                            |    NFR (Security)     | Reserve Resources for Task, Report Task Completion           |             —             |
| **REQ-20** | The System shall encrypt 100% of client-server traffic with TLS 1.3.                                                                                                                                         |    NFR (Security)     | Reserve Resources for Task, Report Task Completion           |             —             |
| **REQ-21** | At the end of each calendar month, the System shall automatically generate the SLA report for the month that ended.                                                                                          |           FR          | Generate Report, Produce SLA Compliance Report               |      TEST-05, TEST-06     |
| **REQ-22** | The SLA report shall group the events by event type.                                                                                                                                                         |           FR          | Produce SLA Compliance Report                                |          TEST-05          |
| **REQ-23** | For each event type, the SLA report shall show the average time from the opening of an event to the closure of its last task.                                                                                |           FR          | Produce SLA Compliance Report                                |          TEST-05          |
| **REQ-24** | The SLA report shall include only the events whose last task was closed in the reporting month.                                                                                                              |           FR          | Produce SLA Compliance Report                                |             —             |
| **REQ-25** | The System shall let the System Administrator request an SLA report on demand for a selected month.                                                                                                          |           FR          | Generate Report, Produce SLA Compliance Report               |             —             |
| **REQ-26** | The System shall accept an on-demand SLA report request only for a month that has ended.                                                                                                                     |           FR          | Generate Report                                              |             —             |
| **REQ-27** | The System shall let the System Administrator view the generated SLA report for a selected reporting month.                                                                                                  |           FR          | View Reports                                                 |             —             |
| **REQ-28** | The System shall generate the SLA report for a month with up to 10,000 events within 30 seconds.                                                                                                             |   NFR (Performance)   | Produce SLA Compliance Report                                |          TEST-05          |
| **REQ-29** | If the monthly SLA report cannot be generated because the server or the database is unavailable, the System shall generate the missing report within 5 minutes after both are available again.               |   NFR (Reliability)   | Generate Report                                              |          TEST-06          |
| **REQ-30** | The System shall deny 100% of SLA report access attempts by users other than an authenticated System Administrator.                                                                                          |     NFR (Security)    | View Reports                                                 |             —             |
| **REQ-31** | From the reports screen, the System shall let the System Administrator request and open an on-demand SLA report for a past month in no more than 3 user actions.                                             |    NFR (Usability)    | Generate Report, Produce SLA Compliance Report, View Reports |             —             |

**Coverage:** Operation 1 has 12 FR (REQ-01 to REQ-12) and 8 NFR (REQ-13 to REQ-20). Operation 2 has 7 FR (REQ-21 to REQ-27) and 5 NFR (REQ-28 to REQ-32). The report NFRs cover performance, security, reliability, usability, and maintainability with measurable thresholds.

---

## Acceptance Tests (Given-When-Then)

### Acceptance Test [TEST-01]: REQ-01, REQ-13, REQ-14 (Happy Path)
* **Given:** The task is in the Ready state, and the required resources are available.
* **When:** The Dispatcher reserves all required resources for the task, using no more than 3 clicks.
* **Then:** The task has moved to the Active state.
* **And:** The resources are marked as Reserved for the task.
* **And:** The Dispatcher receives the success response within 1.5 seconds.

### Acceptance Test [TEST-02]: REQ-01, REQ-02, REQ-03 (Exception)
* **Given:** The task is in the Ready state, one of the required resources is not available, and the others are available.
* **When:** The Dispatcher attempts to reserve the required resources for the task.
* **Then:** The task remains in the Ready state.
* **And:** None of the resources are marked as Reserved for the task.
* **And:** The Dispatcher receives a failure message.

### Acceptance Test [TEST-03]: REQ-02, REQ-03 (Error / Recovery)
* **Given:** The task is in the Ready state, and all required resources were available when the Dispatcher selected them.
* **When:** One of the selected resources is reserved by another task before the Dispatcher's reservation is committed.
* **Then:** The System rolls back the entire reservation.
* **And:** The System does not reserve any of the resources from the request.
* **And:** The System keeps the task in the Ready state, and the Dispatcher receives a clear failure notification.
* **When:** The Dispatcher selects an available alternative for that resource and reserves again.
* **Then:** The reservation succeeds and the task moves to the Active state.

### Acceptance Test [TEST-04]: REQ-02, REQ-03, REQ-18 (Concurrency)
* **Given:** Two different tasks are in the Ready state and both of their resource packages include the same available resource.
* **And:** Two Dispatchers are logged in at separate stations that show the tasks.
* **When:** Both of the Dispatchers attempt to reserve the packages of their task at the same time.
* **Then:** Exactly one of the reservations succeeds.
* **And:** The other task remains in the Ready state, with none of its resources reserved.
* **And:** The other Dispatcher receives a failure message.

### Acceptance Test [TEST-05]: REQ-21, REQ-22, REQ-23, REQ-28 (Happy Path)
* **Given:** The system contains completed events for the current calendar month.
* **When:** The system clock reaches the end of the current calendar month.
* **Then:** The System generates the SLA report for that month within 30 seconds.
* **And:** The report calculates the average time from event opening to the closure of the last task, categorized by event types.
* **And:** The generated report becomes available in the system for the System Administrator to view.

### Acceptance Test [TEST-06]: REQ-21, REQ-29 (Exception / Timeout)
* **Given:** The system clock reaches the end of the current calendar month, but the database is unavailable.
* **When:** The System attempts to automatically generate the SLA report.
* **Then:** The data retrieval process times out.
* **And:** The System safely aborts the report generation process and logs it.
* **And:** The System Administrator receives a failure alert indicating that the report could not be generated.
* **When:** The database becomes available again.
* **Then:** The System generates the missing SLA report within 5 minutes, and the report becomes available to the System Administrator.
