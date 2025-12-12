## 📋 Project Overview

This database schema is built for a multi-user task management application. It supports complex relationships between users and projects, allowing for granular role assignments and detailed tracking of task progress through comments, labels, and activity logs.

---

## ✨ Key Features

* **User Management:** Full user profiles with status tracking and verification.
* **Project Collaboration:** Role-based access control (`owner`, `admin`, `member`, `viewer`) for shared projects.
* **Task Lifecycle:** Support for status (`todo`, `in-progress`, `done`) and priority levels (`Low` to `Urgent`).
* **Organized Workflows:** Label/Tagging system and task positioning for custom ordering.
* **Rich Interactions:** Support for file attachments (up to 100MB) and threaded comments.
* **Audit Trail:** Automated activity logging for every significant change to a task.
* **Data Integrity:** Automated `updated_at` timestamps via PL/pgSQL triggers and safe deletion via `deleted_at` columns.

---

## 🗄️ Database Structure

### 1. Core Tables

| Table | Description |
| :--- | :--- |
| `users` | Stores user credentials, contact info, and status. |
| `projects` | High-level containers for tasks, owned by a specific user. |
| `tasks` | The central unit of work, linked to projects and assignees. |

### 2. Relationship & Extension Tables

* **`project_members`**: Manages which users can access which projects and their specific roles.
* **`user_tasks`**: A many-to-many mapping allowing multiple users to be assigned to a single task.
* **`labels` & `task_labels`**: A project-specific tagging system for categorizing tasks.

### 3. Metadata & Logging

* **`task_comments`**: User discussions per task.
* **`task_attachments`**: Metadata for uploaded files associated with tasks.
* **`task_activities`**: A ledger of all changes (status shifts, reassignments, etc.) with old/new value tracking.

---

## 🛠️ Technical Details

* **Engine:** PostgreSQL
* **Data Types:** Utilizes custom `ENUM` types for rigid status and role management.
* **Performance:** Comprehensive indexing on foreign keys, slugs, and frequently searched columns (email, username, status).
* **Automation:** Trigger functions ensure that the `updated_at` timestamp is refreshed on every row modification.

---

## 🚀 Getting Started

1. Ensure you have **PostgreSQL** installed.
2. Run the script provided in your SQL client or terminal.
3. The script will automatically create the custom types, tables, indexes, and triggers, followed by a set of sample data including 8 users and 6 active projects.
