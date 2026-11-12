# Requirements Architecture & System Specification
**Course:** Software Engineering Methods  
**System:** CrisisSync Emergency Management System
**Submission Date:** `TBD`
**Group Number:** 11

## Requirements Traceability Matrix (RTM)

| Req ID | Requirement Description (Clean English with "shall") | Type (FR/NFR) | Mapped Use Case | Test ID |
| :--- | :--- | :---: |:----:| :---: |
| **REQ-01** | The System shall transition a task to an Active state only once a Dispatcher booked all required resources in a single transaction. | FR | `TBD` | TEST-`TBD` |
| **REQ-02** | In the event of a failure to reserve a resource for a task, the System shall roll back the entire allocation transaction and set the task to the Ready state.| FR | `TBD` | TEST-`TBD` |
| **REQ-03** | When a Dispatcher cancels a task, the System shall cancel all dependent tasks that have not yet reached a final state.| FR | `TBD` | TEST-`TBD` |
| **REQ-04** | The System shall not require the Dispatcher to perform more than 3 clicks to successfully book a complete resource package for a Ready task. | NFR | `TBD` | TEST-`TBD` |
| **REQ-05** | The System shall execute the resource allocation database transaction and return a success or failure response to the Dispatcher within 1.5 seconds.| NFR | `TBD` | TEST-`TBD` |
| **REQ-06** | Upon receiving a task completion report, the System shall push the updated status to all active event screens within 500 milliseconds.| NFR | `TBD` | TEST-`TBD` |
| **REQ-07** | The System shall automatically terminate the session of any user after 15 minutes of inactivity to enforce account security.| NFR | `TBD` | TEST-`TBD` |

[//]: # (Notes regarding the RTM:
      ・The three FRs were extracted from the `מחזור החיים של משימה`.
      ・The four NFRs cover the 4 required criteria:
        REQ-04 [שימושיות], REQ-05 [ביצועים], REQ-06 [אמינות] and REQ-07 [אבטחה]
        I kinda made shit up in the descriptions.. 
        I'm pretty sure that's exactly what we're supposed to do.)

---

<!-- TODO: Finish the Acceptance tests. -->
## Acceptance Tests (Given-When-Then)
### Acceptance Test [TEST-`TBD`]: `TBD` (Happy Path)
* **Given:** 
* **When:** 
* **Then:** 
* **And:**

### Acceptance Test [TEST-`TBD`]: `TBD` (Exception / Timeout)
* **Given:**
* **When:**
* **Then:**
* **And:**