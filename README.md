# Transfer Web Rest Service 
## Abstract
RESTful API service for money transfers between accounts, that allows:
* Creation of monetary accounts with an initial non negative balance
* Transfer money from one account to another

## Added additional features
* Add Docker image to be able to build without java proper version
* Add Circleci config to implement the pipeline
* Add lombok config to prototype implementation for get another handler
* Logger implementation to generate application logs
* Swagger for API documentation

## Domain Model
* Account
    * Has an unique Name;
    * Has a balance (unit is Euros);

* Transfer
    * Describes a transfer request between two Accounts;
    * Must have the source and destination Accounts IDs;
    * Must have the amount transferred between the Accounts;
    * The Transfer can also store a time stamp in the (yyyyMMdd-HHmmss) format for the Date-Time when it has been successfuly performed;

## Business Rules
    * An Account can't have a negative Balance;
    * A transfer cannot make the source Account negative, that is, the source account must have enough funds for the transfer to complete;
    * The application must support simultaneous (concurrent) account creation and transfer requests;
    * The application must keep data consistent between requests, even in a case of an invalid request or execution error.

## Solution Description
### Programming Language
* Java
### Web Service / REST Framework
* Spring Boot v1.5.1-RELEASE
### Persistence Medium
* H2 Embedded Database
### Data Persistency Layer / ORM solution
* JPA - spring-boot-starter-data-jpa
* Hibernate JPA
### Unity Test Framework
* Junit 4.12
* Mockito Core 1.10.19
### Project and Dependency Management
* Maven 3.6.3

## Design Description
### Application Main Flow
1. After staring the application, all requests are handled by TransferController (@RestController)
   1. Available Requests are:
      * /accounts
         * Description
            * Queries for all the persisted Accounts
         * Request Parameters:
            * No parameters
         * Method:
            * GET
         * Response:
            * JSON comprising an array of the retrieved Accounts.
            * In case of error there will be a JSON with the error code and description.

      * /tranfers
         * Description
            * Queries for all the persisted Transfers
         * Request Parameters:
            * No parameters
         * Method:
            * GET
         * Response:
            * JSON comprising an array of the retrieved Transfers.
            * In case of error there will be a JSON with the error code and description.

      * /accounts/new
         * Description
            * Creates a new Account with an initial balance
         * Request Parameters:
            * name : a String containing the new Account name. The Account name must be unique among the persisted Accounts;
            * initialBalance : a String containing a valid Integer or Decimal POSITIVE number for the initial account balance.
         * Method:
            * PUT
         * Response:
            * JSON comprising the newly created Account data "{id:..., name:..., balance:...}"
            * In case of error there will be a JSON with the error code and description.

      * /accounts/transfer
         * Description
            * Transfers a given amount between two Accounts
         * Request Parameters:
            * sourceId : a Long positive greater than zero number having the source Account Id;
            * destId   : a Long positive greater than zero number having the destinations Account Id;
            * amount   : a String containing the a valid Integer or Decimal POSITIVE number containing the initial for the amount being transferred.
         * Method:
            * PUT
         * Response:
            * JSON comprising the newly executed Transfer data "{id:..., sourceAccountId:..., destinationAccountId:..., amount:..., timestamp:...}"
            * In case of error there will be a JSON with the error code and description.
1. The TransferController parses the Resquest and calls the respective methods from TransferService class;
1. Besides the Constructor and setters, each TransferService public method corresponds to a public service call:
   1. createNewAccount
      * Creates a new Account having a giving Name and Initial Balance;
      * This method perform parameter validation to ensure that a valid unique account will be created:
         * Account name cannot be null nor empty;
         * Initial Balance must be greater or equals to ZERO.
   1. transfer
      * Registers a new Transfer from a Source Account and a Destination Account for a giving Amount;
      * This method perform parameter validation to ensure that a valid transfer will be created;
         * Source Account id must be of a valid persisted Account id;
         * Destination Account id must be of a valid persisted Account id;
         * Source and Destination Ids must be different;
         * Amount must be greater than ZERO. No Zero nor Negative transfers are allowed;
   1. findAllAccounts
      * Returns an Iterable<Account> for all the persisted Accounts found in the Database;
   1. findAllTransfers
      * Returns an Iterable<Transfer> for all the persisted Tranfers found in the Database;
      *  **Note: TransferService calls that modifies data are synchronized, having a Transational context allowing data to be rolled back in case of transaction error**
1. The TransferService delegates the persistence / data access calls to a Repository class.
   *  The Repositories interfaces are implemented by Spring's CrudRepository:
      * IAccountRepository  : interface for Account Data Access Methods;
      * ITransferRepository : interface for Transfer Data Access Methods;
1. Finally each Repository interacts with its underlying Entity class:
   *  Account : defines the Account entity and its basic validation rules;
   *  Transfer : defines the Transfer entity and its basic validation rules;
   *  **Note: All numerical financial data (amount, balances etc) are stored, retrieved and manipulated as BigDecimal instances to keep the required decimal precision.**

## Deployment Instructions
### Tech Stack 
   * Java version: 1.8.0_162
   * Maven version: 3.6.3
   * maven-surefire-plugin: 2.7.1
   
### Clone the repository from Git 
   * SSH:
      * git clone git@github.com:jyotirmani/transfer-serviceAPI.git
   * HTTPS:
      * git clone https://github.com/jyotirmani/transfer-serviceAPI.git
### Go to the project root directory:
   * cd transfer-service
### Package the application
   * mvn clean package
### Run the application
   * mvn spring-boot:run  
   or,
   * java -jar target/transfer-service-1.0.jar
### Database Location
   * The H2 database files are created at ~/tmp/transfer-service.mv.db and ~/tmp/transfer-service.trace.db
   * H2 DB is configured on file: application.properties 
   * **The path ~/tmp must exist. If needed change its path on the config file**

### Important notes
   * Database is running completely in memory. After the application is stopped, all the data will be lost.
   * Data consistency is guaranteed by append-only approach for storing the data and usage of idempotency keys.


### Building and running inside docker
   ** First run may take some time. Provided image is not optimized for any kind of workload and can only be used for testing.
  
   * First build an image:
  
    docker build -t transfer-service:latest .
   * Start the container using the following command:
  
    docker run --rm -it -p 7000:7000 transfer-service:latest
   

### API documentation using Swagger
   ** First Run the springboot application.
  
   * Swagger API docs URL for postman client:
  
    http://localhost:8080/v2/api-docs
    
   * Swagger UI URL from browser. This not read only, We can execute the API without the Postman client:
   
    http://localhost:8080/swagger-ui.html
    
    
### Usage Guidelines
   * You can use Postman client to execute the URLs
   or,
   * You can use your web browser or curl. Below examples use curl.
### Simple access
   * curl -i -H 'Content-Type: application/json' http://localhost:8080
### Query accounts
   * curl -i -H 'Content-Type: application/json' http://localhost:8080/accounts
### Query transfers
   * curl -i -H 'Content-Type: application/json' http://localhost:8080/transfers
### Create an account
   * curl -i -H 'Content-Type: application/json' -X PUT "http://localhost:8080/accounts/new?name=AccountOne&initialBalance=100"
   * curl -i -H 'Content-Type: application/json' -X PUT "http://localhost:8080/accounts/new?name=AccountTwo&initialBalance=300"
### Create a transfer
   * curl -i -H 'Content-Type: application/json' -X PUT "http://localhost:8080/accounts/transfer?sourceId=1&destId=2&amount=50"

### Known Limitations in existing version
   * Application has no Query By methods such as Accounts.findByName, Accounts.findByBalanceFilter, Transfers.findBySourceAccount, Transfers.findByDestinationAccount;
   * Application has no Delete methods;
   * Queries are unsorted;
   * Failed transfers are logged in the System.err output, but not registered in the Database;


## Version mgt - Changes from previous version (1.4)
### Added new features to application  
   * Implemented miscellaneous different features.
      * Uses of circleci for build pipeline;
      * Uses of Dockerise the build to independent of language version;
      * Uses of Swagger to API documentation 
      * Uses of logger to generate required log
## Version mgt - Changes from previous version (1.3)
### Concurrent Domain Entities creation test class
   * Implemented Integrated Test for TransferController class.
      * Uses SpringBootTest and MockMVC;
      * This means that running tests will always load Spring Boot, making tests slower;
      * To avoid loading all the Spring Boot harness on every test run, **TransferControllerTest is not part of default test set**;
      * **To run TransferControllerTest please use maven as follows:**
         * ```mvn clean -Dtest=TransferControllerTest test```
## Version mgt - Changes from previous version (1.2)
### Concurrent Domain Entities creation test class
   * Fixed a validation issue with the Long id constraint.
## Version mgt - Changes from previous version (1.0)
### Concurrent Domain Entities creation test class
   * A new test class was created to allow test of concurrent access to TransferService create funcions
   * long id of Account and Transfer were replaced by wrapper Long
   * New method findByName added to IAccountRepository
   * Removed Mockito from TransferServiceTest, created a MockRepository for testing purposes.
      * This MockRespository implements CrudRepository interface persisting the data on a LinkedHashMap.
      * The Template Pattern was used, an AbstractMockRepository was created to provide all commom methods while Account and Transfer specializations enable the required behavior for each entity persistence.
