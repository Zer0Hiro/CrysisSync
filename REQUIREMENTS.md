# Requirements Architecture & System Specification
**Course:** Software Engineering Methods  
**System:** CrisisSync Emergency Management System
**Group Number:** 11

Requirements and acceptance tests for the two operations defined in Assignment 1, Part B:
1. **Reserving a resource package for a task (manually or by automatic allocation), including reporting the task's completion.**
2. **Producing the SLA (on-time / service level) report.**

Each requirement states one behaviour or one measurable quality. Use case names refer to the Visual Paradigm model (`UseCase/G11_Assignment1.vpp`).

## Requirements Traceability Matrix (RTM)

| Req ID | Requirement Description | Type (FR/NFR) | Operation | Mapped Use Case | Test ID |
|:-------|:------------------------|:-------------:|:---------:|:----------------|:-------:|
| **REQ-01** | The System shall set a task to the Active state only after all resources of the task's resource package have been reserved together. | FR | 1 | Reserve Resources for Task | TEST-01, TEST-02 |
| **REQ-02** | If any resource of the package cannot be reserved, the System shall roll back the entire reservation, leaving none of the package's resources reserved. | FR | 1 | Reserve Resources for Task, Reject Unavailable Reservation | TEST-02, TEST-03, TEST-04, TEST-08 |
| **REQ-03** | After a failed reservation, the System shall keep the task in the Ready state. | FR | 1 | Reject Unavailable Reservation | TEST-02, TEST-03, TEST-04, TEST-08 |
| **REQ-04** | The System shall let the Dispatcher request automatic allocation of a Ready task's resource package. | FR | 1 | Request Automatic Allocation | TEST-05 |
| **REQ-05** | The System shall select each resource of the package according to the allocation criterion chosen by the Dispatcher. | FR | 1 | Request Automatic Allocation | TEST-05 |
| **REQ-06** | If a resource selected by automatic allocation is reserved by a concurrent allocation, the System shall automatically select the next-best available alternative for that resource. | FR | 1 | Retry with Alternative Resource | TEST-06, TEST-07 |
| **REQ-07** | The System shall make no more than 2 alternative attempts per resource during an automatic allocation. | FR | 1 | Retry with Alternative Resource | TEST-07 |
| **REQ-08** | The System shall fail an automatic allocation only when no available alternative remains within the 2 alternative attempts. | FR | 1 | Retry with Alternative Resource | TEST-08 |
| **REQ-09** | The System shall allow only the Field Commander assigned to a task to report that task's completion. | FR | 1 | Report Task Completion | TEST-10 |
| **REQ-10** | When the assigned Field Commander reports a task's completion, the System shall set the task to the Completed state. | FR | 1 | Report Task Completion | TEST-09 |
| **REQ-11** | When a task is completed, the System shall return all of its resources to Available. | FR | 1 | Release Task Resources | TEST-09 |
| **REQ-12** | When a task is completed, the System shall set to Ready every dependent task whose prerequisites are all Completed. | FR | 1 | Report Task Completion | TEST-09 |
| **REQ-13** | The System shall let the Dispatcher reserve a complete resource package manually for a Ready task with no more than 3 clicks. | NFR (Usability) | 1 | Reserve Resources for Task | TEST-01 |
| **REQ-14** | The System shall complete a reservation transaction and return a success or failure response to the Dispatcher within 1.5 seconds. | NFR (Performance) | 1 | Reserve Resources for Task | TEST-01, TEST-02 |
| **REQ-15** | The System shall complete an automatic allocation, including its alternative attempts, within 3 seconds. | NFR (Performance) | 1 | Request Automatic Allocation | TEST-05, TEST-06 |
| **REQ-16** | While an automatic allocation is running, the System shall respond to other users' requests within 1.5 seconds. | NFR (Performance) | 1 | Request Automatic Allocation | TEST-06 |
| **REQ-17** | After a task completion report, the System shall push the updated task and resource status to all relevant event status screens within 500 milliseconds. | NFR (Performance) | 1 | Report Task Completion, View Event Status Screen | TEST-09 |
| **REQ-18** | When two reservations request the same available resource at the same time, the System shall reserve the resource for at most one task, with 0 double reservations in 1,000 concurrent reservation attempts. | NFR (Reliability) | 1 | Reserve Resources for Task, Reject Unavailable Reservation | TEST-04, TEST-06 |
| **REQ-19** | The System shall reject 100% of reservation requests and completion reports that do not come from an authenticated session of an authorized role. | NFR (Security) | 1 | Reserve Resources for Task, Report Task Completion | TEST-10 |
| **REQ-20** | The System shall encrypt 100% of client-server traffic with TLS 1.3. | NFR (Security) | 1 | Reserve Resources for Task, Report Task Completion | TEST-11 |
| **REQ-21** | At the end of each calendar month, the System shall automatically generate the SLA report for the month that ended. | FR | 2 | Generate Report, Produce SLA Compliance Report | TEST-12, TEST-13 |
| **REQ-22** | The SLA report shall show, for each event type, the average time from the opening of an event to the closure of its last task, for the events whose last task was closed in the reporting month. | FR | 2 | Produce SLA Compliance Report | TEST-12 |
| **REQ-23** | The System shall let the System Administrator produce the SLA report on demand for a selected month in the past. | FR | 2 | Generate Report, Produce SLA Compliance Report | TEST-14, TEST-15 |
| **REQ-24** | The System shall generate the SLA report for a month with up to 10,000 events within 30 seconds. | NFR (Performance) | 2 | Produce SLA Compliance Report | TEST-12, TEST-14 |
| **REQ-25** | If the monthly SLA report cannot be generated because the server or the database is unavailable, the System shall generate the missing report within 5 minutes after both are available again. | NFR (Reliability) | 2 | Generate Report | TEST-13 |
| **REQ-26** | The System shall deny 100% of SLA report access attempts by users other than an authenticated System Administrator. | NFR (Security) | 2 | View Reports | TEST-16 |

**Coverage:** Operation 1 has 12 FR (REQ-01 to REQ-12) and 8 NFR (REQ-13 to REQ-20). Operation 2 has 3 FR (REQ-21 to REQ-23) and 3 NFR (REQ-24 to REQ-26). The NFRs cover performance, security, reliability and usability, each with a measurable threshold.

---

## Acceptance Tests (Given-When-Then)

### Operation 1: Reserving a resource package and reporting task completion

### Acceptance Test [TEST-01]: Reserve a complete package manually (Happy Path) - REQ-01, REQ-13, REQ-14
* **Given:** A task is in the Ready state, and every resource of its resource package is available.
* **When:** The Dispatcher selects a resource for each package item and confirms the reservation, using no more than 3 clicks.
* **Then:** The task moves to the Active state.
* **And:** All selected resources are marked as Reserved for the task.
* **And:** The Dispatcher receives the success response within 1.5 seconds.

### Acceptance Test [TEST-02]: Package with an unavailable resource (Exception) - REQ-01, REQ-02, REQ-03, REQ-14
* **Given:** A task is in the Ready state, one resource of its package is not available, and the others are available.
* **When:** The Dispatcher attempts to reserve the package.
* **Then:** The task remains in the Ready state.
* **And:** None of the resources are marked as Reserved for the task.
* **And:** The Dispatcher receives a failure message naming the unavailable resource within 1.5 seconds.

### Acceptance Test [TEST-03]: Resource taken during the transaction, then recovery (Error / Recovery) - REQ-02, REQ-03
* **Given:** A task is in the Ready state, and all resources of its package were available when the Dispatcher selected them.
* **When:** One of the selected resources becomes reserved by another task before the Dispatcher's transaction commits.
* **Then:** The System rolls back the entire reservation and reserves none of the resources.
* **And:** The task stays in the Ready state, and the Dispatcher's screen is refreshed to show the current availability.
* **When:** The Dispatcher selects an available alternative for that item and confirms again.
* **Then:** The reservation succeeds and the task moves to the Active state.

### Acceptance Test [TEST-04]: Two Dispatchers reserve the same resource at once (Concurrency) - REQ-02, REQ-03, REQ-18
* **Given:** Two different tasks are in the Ready state, and both of their resource packages include the same available bulldozer.
* **And:** Two Dispatchers are logged in at separate stations.
* **When:** Both Dispatchers confirm the reservation of their task's package at the same moment.
* **Then:** Exactly one of the reservations succeeds and its task moves to the Active state.
* **And:** The other task remains in the Ready state with none of its resources reserved, and its Dispatcher receives a failure message.
* **And:** The bulldozer is reserved for exactly one task (no double reservation).

### Acceptance Test [TEST-05]: Automatic allocation by nearest resources (Happy Path) - REQ-04, REQ-05, REQ-15
* **Given:** A task is in the Ready state, and several available resources of each required type are at different distances from the event location.
* **When:** The Dispatcher requests automatic allocation with the criterion "nearest available resources".
* **Then:** The System reserves, for each package item, the nearest available resource.
* **And:** The task moves to the Active state within 3 seconds.

### Acceptance Test [TEST-06]: Two automatic allocations compete for the same resource (Concurrency / Recovery) - REQ-06, REQ-15, REQ-16, REQ-18
* **Given:** Two tasks in different events are in the Ready state, the same bulldozer is the nearest available one for both, and a second bulldozer is available.
* **When:** Two Dispatchers request automatic allocation for their tasks at the same moment.
* **Then:** One task receives the nearest bulldozer.
* **And:** The other task automatically receives the second bulldozer, without its Dispatcher repeating the request.
* **And:** Both tasks move to the Active state within 3 seconds, and each bulldozer is reserved for exactly one task.
* **And:** A third user's unrelated request during the allocations is answered within 1.5 seconds.

### Acceptance Test [TEST-07]: Alternative attempts limit (Exception) - REQ-06, REQ-07
* **Given:** A task is in the Ready state, its two best-ranked bulldozers are taken by concurrent allocations during its automatic allocation, and a third bulldozer is available.
* **When:** The Dispatcher's automatic allocation runs.
* **Then:** The System tries the first alternative, which is taken, and then the second alternative, which succeeds.
* **And:** The System makes no more than 2 alternative attempts for the bulldozer.
* **And:** The task moves to the Active state.

### Acceptance Test [TEST-08]: Automatic allocation with no alternative available (Exception) - REQ-02, REQ-03, REQ-08
* **Given:** A task is in the Ready state, and its package needs a bulldozer, but the only available bulldozer is taken by a concurrent allocation.
* **When:** The Dispatcher's automatic allocation runs.
* **Then:** The System finds no available alternative and fails the allocation.
* **And:** None of the package's resources are reserved, and the task stays in the Ready state.
* **And:** The Dispatcher receives a failure message.

### Acceptance Test [TEST-09]: Report task completion (Happy Path) - REQ-10, REQ-11, REQ-12, REQ-17
* **Given:** Task A is in the Active state with its resources reserved, and its assigned Field Commander is logged in.
* **And:** Task B depends only on Task A and is in the Blocked state.
* **When:** The Field Commander reports Task A as completed.
* **Then:** Task A moves to the Completed state.
* **And:** All resources of Task A return to Available.
* **And:** Task B moves to the Ready state.
* **And:** All relevant event status screens show the change within 500 milliseconds.

### Acceptance Test [TEST-10]: Completion reported by an unauthorized user (Exception) - REQ-09, REQ-19
* **Given:** A task is in the Active state, and a Field Commander who is not assigned to it is logged in.
* **When:** That Field Commander attempts to report the task as completed.
* **Then:** The System rejects the report.
* **And:** The task stays in the Active state and its resources stay Reserved.
* **And:** The rejected attempt is recorded in the audit log.

### Acceptance Test [TEST-11]: Encrypted client-server connection (Security) - REQ-20
* **Given:** The server is running with TLS 1.3 enabled.
* **When:** A Dispatcher client connects to the server.
* **Then:** The connection is established with the negotiated protocol TLS 1.3.
* **When:** A client that offers only TLS 1.2 or lower tries to connect.
* **Then:** The server refuses the connection.

### Operation 2: Producing the SLA report

### Acceptance Test [TEST-12]: Automatic monthly SLA report (Happy Path) - REQ-21, REQ-22, REQ-24
* **Given:** The system contains events of several event types whose last task was closed during the current calendar month.
* **When:** The system clock reaches the end of the calendar month.
* **Then:** The System generates the SLA report for that month within 30 seconds.
* **And:** The report shows, for each event type, the average time from event opening to the closure of its last task.
* **And:** The report is available for the System Administrator to view.

### Acceptance Test [TEST-13]: Database unavailable at month end, then recovery (Exception / Timeout) - REQ-21, REQ-25
* **Given:** The system clock reaches the end of the calendar month, but the database is unavailable.
* **When:** The System attempts to generate the SLA report automatically.
* **Then:** The data retrieval times out, and the System safely aborts the generation and logs the failure.
* **And:** The System Administrator receives an alert that the report could not be generated.
* **When:** The database becomes available again.
* **Then:** The System generates the missing SLA report within 5 minutes, and the report is available to view.

### Acceptance Test [TEST-14]: SLA report on demand for a past month (Happy Path) - REQ-23, REQ-24
* **Given:** The System Administrator is logged in, and the system contains closed events from a past month.
* **When:** The System Administrator requests the SLA report for that past month.
* **Then:** The System generates the report for the selected month within 30 seconds.
* **And:** The report is displayed to the System Administrator.

### Acceptance Test [TEST-15]: SLA report requested for a month that has not ended (Error) - REQ-23
* **Given:** The System Administrator is logged in.
* **When:** The System Administrator requests the SLA report for the current month.
* **Then:** The System refuses the request and asks for a month in the past.
* **And:** No report is generated or stored.

### Acceptance Test [TEST-16]: SLA report accessed by another role (Security) - REQ-26
* **Given:** A Dispatcher is logged in, and an SLA report exists.
* **When:** The Dispatcher attempts to open the SLA report.
* **Then:** The System denies access.
* **And:** The denied attempt is recorded in the audit log.
