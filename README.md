Understood. I will provide the revised README file structure without emojis, maintaining the removal of the Contribution and Prerequisites sections, and adding placeholders for relevant diagrams and graphs.

-----

## 📄 Revised README Template: Multi-Tier VProfile Deployment

## Project Overview

This project defines and provisions a complete, five-tier, production-like application environment using **Infrastructure as Code (IaC)**. The goal is to set up a robust, scalable architecture for the **VProfile** application, separating concerns into dedicated virtual machines (VMs).

### Core Architecture Diagram

The environment is orchestrated using **Vagrant** and consists of the following isolated tiers.

-----

## System Metrics and Flow

### 1\. Architectural Components

The table below illustrates the communication flow and port usage between the different tiers.

| Tier (VM Name) | OS | Private IP | Role | Key Ports |
| :--- | :--- | :--- | :--- | :--- |
| **`web01`** | Ubuntu Jammy | `192.168.56.11` | Nginx Reverse Proxy | 80, 443 |
| **`app01`** | CentOS Stream 9 | `192.168.56.12` | Tomcat Application | 8080 |
| **`rmq01`** | CentOS Stream 9 | `192.168.56.13` | RabbitMQ | 5672 |
| **`mc01`** | CentOS Stream 9 | `192.168.56.14` | Memcached | 11211 |
| **`db01`** | CentOS Stream 9 | `192.168.56.15` | MySQL Database | 3306 |

### 2\. Deployment Workflow

This chart shows the order of provisioning for the entire stack, highlighting the sequential execution of the shell scripts to ensure dependencies are met.

-----

## Getting Started

Follow these steps to bring up the entire multi-tier environment.

### 1\. Clone the Repository

```bash
git clone https://github.com/Bassantmohy/multiTierDeployment
cd multiTierDeployment
```

### 2\. Configure Application Properties

Ensure your local **`application.properties`** file (in the same directory as the `Vagrantfile`) is configured to point to the correct internal IPs:

```properties
# Example configuration snippet:
db.url=jdbc:mysql://192.168.56.15:3306/vprofiledb
memcache.servers=192.168.56.14:11211
rabbitmq.host=192.168.56.13
```

### 3\. Start the Environment

This command will provision and boot all five virtual machines.

```bash
vagrant up
```

-----

## Accessing the Application

Once provisioning is complete, the application can be accessed from your **Host Machine's Web Browser** via the Nginx reverse proxy.

  * **URL:** **`https://192.168.56.11`**

**Security Note:** The Nginx server is configured to use a **self-signed SSL certificate**. Your browser will show a security warning, which you must bypass to proceed to the VProfile application.

-----

## Maintenance and Troubleshooting

### SSH Access

You can SSH into any machine using its defined name:

```bash
# Example: SSH into the Application server
vagrant ssh app01 
```

### Key Log Locations

  * **Tomcat Application Logs (`app01`):** `/usr/local/tomcat/logs/catalina.out`
  * **Nginx Access Logs (`web01`):** `/var/log/nginx/access.log`

### Cleanup

To stop and remove all virtual machines and free up resources:

```bash
vagrant destroy -f
```
