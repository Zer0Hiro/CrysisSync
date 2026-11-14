# Requirements Architecture & System Specification
**Course:** Software Engineering Methods  
**System:** CrisisSync Emergency Management System
**Submission Date:** `TBD`
**Group Number:** 11

## Requirements Traceability Matrix (RTM)

| Req ID     | Requirement Description (Clean English with "shall")                                                                                                            | Type (FR/NFR) | Mapped Use Case |     Test ID      |
|:-----------|:----------------------------------------------------------------------------------------------------------------------------------------------------------------|:-------------:|:---------------:|:----------------:|
| **REQ-01** | The System shall transition a task to an Active state only once a Dispatcher booked all required resources in a single transaction.                             |      FR       |      `TBD`      | TEST-01, TEST-02 |
| **REQ-02** | In the event of a failure to reserve a resource for a task, the System shall roll back the entire allocation transaction and keep the task in the Ready state.  |      FR       |      `TBD`      | TEST-03, TEST-04 |
| **REQ-03** | The System shall not require the Dispatcher to perform more than 3 clicks to successfully book a complete resource package for a Ready task.                    |      NFR      |      `TBD`      | N/A |
| **REQ-04** | The System shall execute the resource allocation database transaction and return a success or failure response to the Dispatcher within 1.5 seconds.            |      NFR      |      `TBD`      | N/A |
| **REQ-05** | Upon receiving a task completion report, the System shall push the updated status to all active relevant event status screens within 500 milliseconds.          |      NFR      |      `TBD`      | N/A |
| **REQ-06** | The System shall allow only the Field Commander assigned to a task to report its completion.                                                                    |      FR       |      `TBD`      | N/A |
| **REQ-07** | The System shall automatically generate an SLA report for the month that ended, at the end of each calendar month.                                              |      FR       |      `TBD`      | TEST-05, TEST-06 |

<!-- TODO: Figure if this is relevant. -->
[//]: # (| **REQ-08** | If the server is unavailable at the end of a calendar month, the System shall generate the missing SLA report within 5 minutes after the server starts again. |      FR       |      `TBD`      | N/A |)

[//]: # (Notes regarding the Acceptance Tests:
         We only need 2 tests for two requierments, but I've done 3 just for padding.
         TEST-01 through TEST-04 are for `Resource booking and tast completion`,
         while TEST-05 and 06 are for `Generating the SLA report`.)

## Acceptance Tests (Given-When-Then)
### Acceptance Test [TEST-01]: REQ-01 (Happy Path)
* **Given:** The task is in the Ready state, and the required resources are available.
* **When:** The Dispatcher reserves all required resources for the task.
* **Then:** The task has moved to the Active state.
* **And:** The resources are marked as Reserved for the task.

### Acceptance Test [TEST-02]: REQ-01 (Exception / Timeout)
* **Given:** The task is in the Ready state, one of the required resources is not available, and the others are available.
* **When:** The Dispatcher attempts to reserve the required resources for the task.
* **Then:** The task remains in the Ready state.
* **And:** None of the resources are marked as Reserved for the task. The Dispatcher receives a failure message.

### Acceptance Test [TEST-03]: REQ-02 (Happy Path)
* **Given:** The task is in the Ready state, and one of the required resources is unavailable.
* **When:** The Dispatcher attempts to reserve the resource for the task.
* **Then:** The System rolls back the entire allocation transaction.
* **And:** The System keeps the task in the Ready state.
* **And:** The System does not reserve any of the available resources from the request.
* **And:** The Dispatcher receives a clear failure notification.

### Acceptance Test [TEST-04]: REQ-02 (Exception / Timeout)
* **Given:** Two different tasks are in the Ready state and both of their resource packages include the same available resource.
* **And:** Two Dispatchers are logged in at separate stations that show the tasks.
* **When:** Both of the Dispatchers attempt to reserve the packages of their task at the same time.
* **Then:** Exactly one of the reservations succeeds.
* **And:** The other task remains in the Ready state.
* **And:** The other Dispatcher receives a failure message.

The System shall automatically generate an SLA report for the month that ended, at the end of each calendar month.

### Acceptance Test [TEST-05]: REQ-07 (Happy Path)
* **Given:** The system contains completed events for the current calendar month.
* **When:** The system clock reaches the end of the current calendar month.
* **Then:** The System generates the SLA report for that month.
* **And:** The report calculates the average time from event opening to the closure of the last task, categorized by event types.
* **And:** The generated report becomes available in the system for the System Administrator to view.

### Acceptance Test [TEST-06]: REQ-07 (Exception / Timeout)
* **Given:** The system clock reaches the end of the current calendar month, but the database is unavailable.
* **When:** The System attempts to automatically generate the SLA report.
* **Then:** The data retrieval process times out.
* **And:** The System safely aborts the report generation process and logs it.
* **And:** The System Administrator receives a failure alert indicating that the report could not be generated.