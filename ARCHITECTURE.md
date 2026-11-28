# CrisisSync Architecture

## 1. Team
**Group:** G11

## 2. ECB Architecture

### 2.1 Overview
The design follows the Entity-Control-Boundary (ECB) pattern:
- **Boundary** classes are the interface with the actors (for example: screens).
- **Control** classes manage the flow of each use case. Client-side controllers
  only send requests and handle responses; server-side controllers hold the
  business logic (allocation, task state transitions, reports).
- **Entity** classes hold the domain data (events, tasks, resources, reports)
  and are shared by client and server, since they are sent over the network.

### 2.2 Class Mapping

| Class                              | Stereotype  |
|------------------------------------|-------------|
| **Client**                         |             |
| LoginScreen                        | boundary    |
| EventStatusScreen                  | boundary    |
| ResourceReservationScreen          | boundary    |
| ReportsScreen                      | boundary    |
| LoginClientController              | control     |
| ReservationClientController        | control     |
| TaskClientController               | control     |
| ReportClientController             | control     |
| **Common**                         |             |
| User                               | entity      |
| Event                              | entity      |
| Task                               | entity      |
| ResourcePackage                    | entity      |
| Resource (abstract)                | entity      |
| Equipment                          | entity      |
| CrewMember                         | entity      |
| Station                            | entity      |
| SLAReport                          | entity      |
| SLAReportRow                       | entity      |
| UserRole                           | enumeration |
| EventType                          | enumeration |
| TaskState                          | enumeration |
| ResourceStatus                     | enumeration |
| EquipmentType                      | enumeration |
| CrewRole                           | enumeration |
| **Server**                         |             |
| ServerMonitorScreen                | boundary    |
| MonthlyReportScheduler             | boundary    |
| AuthenticationController           | control     |
| ResourceAllocationController       | control     |
| TaskManagementController           | control     |
| NotificationController             | control     |
| ReportController                   | control     |
| SLAReportController                | control     |
| **Infrastructure: OCSF (network)** |             |
| AbstractClient (OCSF library)      | TBD         |
| ObservableClient (OCSF library)    | TBD         |
| AbstractServer (OCSF library)      | TBD         |
| ConnectionToClient (OCSF library)  | TBD         |
| CrisisSyncClient                   | control     |
| CrisisSyncServer                   | control     |
| Message                            | TBD         |
| MessageType                        | enumeration |
| **Infrastructure: Data Access**    |             |
| DBConnector                        | TBD         |
| UserDAO                            | TBD         |
| EventDAO                           | TBD         |
| TaskDAO                            | TBD         |
| ResourceDAO                        | TBD         |
| ReportDAO                          | TBD         |


### 2.3 Communication Rules
<!-- Boundary <-> Control only, DB access via server DAO only, no System class -->

### 2.4 Request Flow
<!-- Screen -> client control -> OCSF -> server control -> DAO -> MySQL -->

## 3. UML Diagrams

### 3.1 Activity Diagrams
<!-- ![Reserve Resource Package](diagrams/activity_reserve.png) -->
<!-- ![SLA Report](diagrams/activity_sla_report.png) -->

### 3.2 ECB Class Diagram
<!-- ![Class Diagram](diagrams/class_ecb.png) -->

### 3.3 Sequence Diagrams
<!-- ![Reserve Resource Package](diagrams/sequence_reserve.png) -->
<!-- ![SLA Report](diagrams/sequence_sla_report.png) -->

### 3.4 Package Diagram
<!-- ![Package Diagram](diagrams/package.png) -->

## 4. Design Pattern
<!-- Which pattern, where it is implemented, which requirement it serves -->

## 5. Race Condition Prevention
<!-- Optimistic / pessimistic locking, how the server handles conflicts -->
