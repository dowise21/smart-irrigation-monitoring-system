# 🌿 Smart Irrigation Monitoring System

The **Smart Irrigation Monitoring System** is a web-based project designed to support plant management, environmental monitoring, and irrigation operations through a centralized interface.

The project aims to simplify irrigation management by organizing plant information, monitoring sensor readings, managing watering schedules, and providing users with access to relevant system data.

## ✨ Key Features

- **Dashboard:** Provides a centralized view of relevant system information.
- **Plant Management:** Organizes and manages plant information.
- **Environmental Monitoring:** Displays sensor readings and environmental conditions.
- **Irrigation Management:** Supports the management of watering schedules and irrigation sessions.
- **Pump Management:** Organizes information related to irrigation equipment.
- **Alert Management:** Supports the monitoring and tracking of system alerts.
- **User Access Management:** Organizes user permissions according to assigned roles.

*Feature availability depends on the current project implementation.*

## 👥 Development Team

**Group 1 — PRJ301 — Fall 2026**

| Team Member | Responsibility |
|---|---|
| Lê Văn Ngoan | Backend Development & Database Design |
| Nguyễn Ngọc Linh | IoT Integration & Backend Logic |
| Phan Duy Bảo | Frontend UI/UX Development & Web Integration |

## 🔐 User Roles and Access Control

The project defines five user roles to organize access and responsibilities within the system.

| Role | Main Responsibilities |
|---|---|
| **ADMIN** | Manage user accounts and oversee system administration. |
| **MANAGER** | Manage plant information and irrigation schedules. |
| **TECHNICIAN** | Monitor sensors and manage irrigation equipment. |
| **STAFF** | Monitor system information and perform authorized operational tasks. |
| **VIEWER** | View available information with read-only access. |

Access to system functions is organized according to the permissions assigned to each role.

## 💾 Database Design

The database is designed to support the system's core operations, including user access management, plant management, environmental monitoring, irrigation scheduling, and system alerts.

It provides a structured way to store and manage application data, helping maintain data consistency and support interactions between different system components.

Database schema and related SQL scripts are maintained separately within the project.

Database scripts are organized in the project's SQL directory. Refer to the actual scripts for the latest schema and sample data.

## 🏗️ Application Architecture

The application follows the **MVC2 architectural pattern**, separating the presentation layer, request processing, business logic, and database operations.

- **Controller:** Handles incoming requests and coordinates application workflows.
- **Model:** Represents application data and domain entities.
- **DAO (Data Access Object):** Handles database access and data persistence.
- **Service:** Organizes business logic and application operations.
- **Filter:** Supports request filtering and access control.
- **JSP Pages:** Render the web interface and display application information.
- **Configuration:** Stores configuration files required by the application.

This structure helps separate responsibilities and makes the application easier to maintain and extend.

## 📂 Project Structure

```text
smart-irrigation-monitoring-system/
├── src/
│   ├── conf/                  # Configuration files
│   └── java/
│       ├── controller/        # Request handling
│       ├── dao/               # Database access
│       ├── filter/            # Request filtering and access control
│       ├── model/             # Application models
│       ├── service/           # Business logic
│       └── util/              # Shared utilities
│
├── web/
│   ├── *.jsp                  # JSP pages
│   ├── css/                   # CSS stylesheets
│   ├── js/                    # JavaScript files
│   ├── images/                # Image assets
|   ├── META-INF/ 
│   └── WEB-INF/
│       └── build.xml            # Web application configuration
│
├── sql/                       # Database scripts
└── scripts/                   # Utility scripts      
```

*Note: This is a simplified overview. Directory names and files should be adjusted to match the actual repository.*

## 🚀 Installation and Setup

### Prerequisites

Prepare the development environment required by the project:

- A compatible Java Development Kit (JDK)
- A compatible Java web application server
- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- A supported Java IDE or code editor

### 1. Clone the Repository

Open a terminal and run:

```bash
git clone https://github.com/baophan123-developer/smart-irrigation-monitoring-system.git
cd smart-irrigation-monitoring-system
```

Replace the example repository URL with the actual GitHub repository URL.

### 2. Set Up the Database

1. Open SQL Server Management Studio.
2. Connect to your SQL Server instance.
3. Locate the database scripts in the `sql/` directory.
4. Execute the schema script to create the database structure.
5. Execute the sample-data script if one is available.
6. Verify that the required tables have been created successfully.

### 3. Configure the Database Connection

1. Open the project in your IDE.
2. Locate the database connection configuration, such as `DBContext.java` if that is the class used by the project.
3. Update the database server, database name, username, and password to match your local environment.
4. Verify that the required JDBC driver is available.
5. Test the database connection before running the application.

**Security note:** Do not commit real database passwords or other sensitive credentials to a public repository.

### 4. Build and Run the Application

1. Open the project in a compatible Java IDE.
2. Configure the required Java web application server.
3. Build the project.
4. Deploy and start the application.
5. Open the local application URL using the context path configured for your project.

The exact server configuration and URL depend on the project setup.

## 🧪 Testing and Documentation

Project documentation may include the following materials, depending on what is available in the repository:

- Database schema and design documentation
- Functional testing reports
- User Acceptance Testing (UAT) results
- System Usability Scale (SUS) evaluation
- Project presentation materials

Refer to the corresponding files in the repository for detailed information.

## 🔒 Security Considerations

- Apply appropriate access controls to protected functions.
- Validate user input before processing requests.
- Protect database credentials and other sensitive configuration values.
- Avoid exposing sensitive information in logs or public repositories.
- Use demonstration accounts only in development or testing environments.

## 📌 Project Information

- **Project:** Smart Irrigation Monitoring System
- **Course:** PRJ301
- **Group:** Group 1
- **Semester:** FPT University Fall 2026

---

*Smart Irrigation Monitoring System — Supporting plant management and irrigation monitoring through a centralized web application.*
