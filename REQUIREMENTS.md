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
| **REQ-03** | The System shall not require the Dispatcher to perform more than 3 clicks to successfully book a complete resource package for a Ready task.                    |      NFR      |      `TBD`      | TEST-05, TEST-06 |
| **REQ-04** | The System shall execute the resource allocation database transaction and return a success or failure response to the Dispatcher within 1.5 seconds.            |      NFR      |      `TBD`      | TEST-07, TEST-08 |
| **REQ-05** | Upon receiving a task completion report, the System shall push the updated status to all active relevant event status screens within 500 milliseconds.          |      NFR      |      `TBD`      | TEST-09, TEST-10 |
| **REQ-06** | The System shall allow only the Field Commander assigned to a task to report its completion.                                                                    |      FR       |      `TBD`      | TEST-11, TEST-12 |
| **REQ-07** | The System shall automatically generate an SLA report for the month that ended, at the end of each calendar month.                                              |      FR       |      `TBD`      | TEST-13, TEST-14 |
| **REQ-08** | If the server is unavailable at the end of a celendar month, the System shall generate t he missing SLA report withing 5 minutes after the server starts again. |      FR       |      `TBD`      | TEST-13, TEST-14 |

[//]: # (Notes regarding the RTM:
      ・The three FRs were extracted from the `מחזור החיים של משימה`.
      ・The four NFRs cover the 4 required criteria:
        REQ-04 [שימושיות], REQ-05 [ביצועים], REQ-06 [אמינות] and REQ-07 [אבטחה]
        I kinda made shit up in the descriptions.. 
        I'm pretty sure that's exactly what we're supposed to do.) 

---

<!-- TODO: Finish the Acceptance tests. -->
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
* **Given:** Two different tasks are in the Ready state and both of their resource packages include the same available resource.
* **And:** Two Dispatchers are logged in at separate stations that show the tasks.
* **When:** Both of the Dispatchers attempt to reserve the packages of their task at the same time.
* **Then:** Exactly one of the reservations succeeds.
* **And:** The other task remains in the Ready state.
* **And:** The other Dispatcher receives a failure message.
<!-- 
### Acceptance Test [TEST-04]: REQ-02 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:** -->

### Acceptance Test [TEST-05]: REQ-03 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-06]: REQ-03 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

### Acceptance Test [TEST-07]: REQ-04 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-08]: REQ-04 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

### Acceptance Test [TEST-09]: REQ-05 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-10]: REQ-05 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

### Acceptance Test [TEST-11]: REQ-06 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-12]: REQ-06 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

### Acceptance Test [TEST-13]: REQ-07 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-14]: REQ-07 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

### Acceptance Test [TEST-15]: REQ-08 (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-16]: REQ-08 (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**

