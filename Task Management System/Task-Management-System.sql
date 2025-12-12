CREATE DATABASE project_tracker_db;

USE project_tracker_db;

CREATE TYPE task_status_type AS ENUM ('todo', 'in-progress', 'done');
CREATE TYPE task_priority_type AS ENUM ('Low', 'Medium', 'High', 'Urgent');
CREATE TYPE project_role_type AS ENUM ('owner', 'admin', 'member', 'viewer');
CREATE TYPE activity_action_type AS ENUM (
    'created', 'updated', 'deleted', 'status_changed', 
    'priority_changed', 'assigned', 'unassigned', 
    'commented', 'attachment_added', 'attachment_removed',
    'due_date_changed', 'moved'
);

CREATE TABLE users (
    user_id BIGSERIAL PRIMARY KEY,
    user_full_name VARCHAR(100) NOT NULL,
    user_name VARCHAR(100) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    phone_number VARCHAR(20),
    date_of_birth DATE,
    gender VARCHAR(20),
    avatar_url VARCHAR(500),
    is_active BOOLEAN DEFAULT TRUE,
    email_verified BOOLEAN DEFAULT FALSE,
    last_login_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP
);

CREATE INDEX idx_users_user_name ON users(user_name);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_is_active ON users(is_active);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

CREATE TABLE projects (
    project_id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL,
    project_name VARCHAR(255) NOT NULL,
    project_slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    color VARCHAR(7),
    is_archived BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_projects_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE
);

CREATE INDEX idx_projects_user_id ON projects(user_id);
CREATE INDEX idx_projects_slug ON projects(project_slug);
CREATE INDEX idx_projects_is_archived ON projects(is_archived);
CREATE INDEX idx_projects_deleted_at ON projects(deleted_at);

CREATE TABLE project_members (
    project_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    role project_role_type DEFAULT 'member',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (project_id, user_id),
    
    CONSTRAINT fk_project_members_project FOREIGN KEY (project_id) 
        REFERENCES projects(project_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_project_members_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE INDEX idx_project_members_user_id ON project_members(user_id);
CREATE INDEX idx_project_members_role ON project_members(role);

CREATE TABLE tasks (
    task_id BIGSERIAL PRIMARY KEY,
    task_title VARCHAR(500) NOT NULL,
    task_description TEXT,
    task_status task_status_type NOT NULL DEFAULT 'todo',
    task_priority task_priority_type NOT NULL DEFAULT 'Medium',
    position INTEGER DEFAULT 0,
    due_date DATE,
    completed_at TIMESTAMP,
    project_id BIGINT NOT NULL,
    created_by BIGINT NOT NULL,
    assigned_to BIGINT,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_tasks_project FOREIGN KEY (project_id) 
        REFERENCES projects(project_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_tasks_created_by FOREIGN KEY (created_by) 
        REFERENCES users(user_id) 
        ON DELETE RESTRICT 
        ON UPDATE CASCADE,
    CONSTRAINT fk_tasks_assigned_to FOREIGN KEY (assigned_to) 
        REFERENCES users(user_id) 
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);

CREATE INDEX idx_tasks_project_id ON tasks(project_id);
CREATE INDEX idx_tasks_created_by ON tasks(created_by);
CREATE INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE INDEX idx_tasks_status ON tasks(task_status);
CREATE INDEX idx_tasks_priority ON tasks(task_priority);
CREATE INDEX idx_tasks_due_date ON tasks(due_date);
CREATE INDEX idx_tasks_position ON tasks(position);
CREATE INDEX idx_tasks_deleted_at ON tasks(deleted_at);
CREATE INDEX idx_tasks_project_status ON tasks(project_id, task_status);

CREATE TABLE labels (
    label_id BIGSERIAL PRIMARY KEY,
    project_id BIGINT NOT NULL,
    label_name VARCHAR(50) NOT NULL,
    color VARCHAR(7) DEFAULT '#808080',
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_labels_project FOREIGN KEY (project_id) 
        REFERENCES projects(project_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT unique_label_per_project UNIQUE (project_id, label_name)
);

CREATE INDEX idx_labels_project_id ON labels(project_id);

CREATE TABLE task_labels (
    task_id BIGINT NOT NULL,
    label_id BIGINT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (task_id, label_id),
    
    CONSTRAINT fk_task_labels_task FOREIGN KEY (task_id) 
        REFERENCES tasks(task_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_labels_label FOREIGN KEY (label_id) 
        REFERENCES labels(label_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE INDEX idx_task_labels_label_id ON task_labels(label_id);

CREATE TABLE task_comments (
    comment_id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    comment_text TEXT NOT NULL,
    is_edited BOOLEAN DEFAULT FALSE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_task_comments_task FOREIGN KEY (task_id) 
        REFERENCES tasks(task_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_comments_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE INDEX idx_task_comments_task_id ON task_comments(task_id);
CREATE INDEX idx_task_comments_user_id ON task_comments(user_id);
CREATE INDEX idx_task_comments_created_at ON task_comments(created_at);
CREATE INDEX idx_task_comments_deleted_at ON task_comments(deleted_at);

CREATE TABLE task_attachments (
    attachment_id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    file_name VARCHAR(255) NOT NULL,
    storage_path VARCHAR(500) UNIQUE NOT NULL,
    file_type VARCHAR(100),
    file_size_bytes BIGINT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP,
    
    CONSTRAINT fk_task_attachments_task FOREIGN KEY (task_id) 
        REFERENCES tasks(task_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_attachments_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    
    CONSTRAINT chk_file_size CHECK (file_size_bytes > 0 AND file_size_bytes <= 104857600)
);

CREATE INDEX idx_task_attachments_task_id ON task_attachments(task_id);
CREATE INDEX idx_task_attachments_user_id ON task_attachments(user_id);
CREATE INDEX idx_task_attachments_deleted_at ON task_attachments(deleted_at);

CREATE TABLE user_tasks (
    user_id BIGINT NOT NULL,
    task_id BIGINT NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (user_id, task_id),
    
    CONSTRAINT fk_user_tasks_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_user_tasks_task FOREIGN KEY (task_id) 
        REFERENCES tasks(task_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE INDEX idx_user_tasks_task_id ON user_tasks(task_id);

CREATE TABLE task_activities (
    activity_id BIGSERIAL PRIMARY KEY,
    task_id BIGINT NOT NULL,
    user_id BIGINT NOT NULL,
    action_type activity_action_type NOT NULL,
    old_value TEXT,
    new_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT fk_task_activities_task FOREIGN KEY (task_id) 
        REFERENCES tasks(task_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE,
    CONSTRAINT fk_task_activities_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) 
        ON DELETE CASCADE 
        ON UPDATE CASCADE
);

CREATE INDEX idx_task_activities_task_id ON task_activities(task_id);
CREATE INDEX idx_task_activities_user_id ON task_activities(user_id);
CREATE INDEX idx_task_activities_action_type ON task_activities(action_type);
CREATE INDEX idx_task_activities_created_at ON task_activities(created_at);

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_members_updated_at BEFORE UPDATE ON project_members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_tasks_updated_at BEFORE UPDATE ON tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_labels_updated_at BEFORE UPDATE ON labels
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_comments_updated_at BEFORE UPDATE ON task_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_task_attachments_updated_at BEFORE UPDATE ON task_attachments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_user_tasks_updated_at BEFORE UPDATE ON user_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

INSERT INTO users (
    user_full_name, user_name, email, phone_number, 
    date_of_birth, gender, is_active, email_verified
) VALUES
    ('Rajesh Kumar Sharma', 'rajesh.sharma', 'rajesh.sharma@gmail.com', 
     '+91-9876543210', '1990-05-15', 'Male', TRUE, TRUE),
    ('Priya Singh', 'priya.singh', 'priya.singh@yahoo.com', 
     '+91-9765432109', '1992-08-22', 'Female', TRUE, TRUE),
    ('Amit Patel', 'amit.patel', 'amit.patel@outlook.com', 
     '+91-9654321098', '1988-11-30', 'Male', TRUE, TRUE),
    ('Sneha Reddy', 'sneha.reddy', 'sneha.reddy@gmail.com', 
     '+91-9543210987', '1995-03-18', 'Female', TRUE, TRUE),
    ('Vikram Malhotra', 'vikram.malhotra', 'vikram.m@hotmail.com', 
     '+91-9432109876', '1991-07-25', 'Male', TRUE, TRUE),
    ('Anjali Gupta', 'anjali.gupta', 'anjali.gupta@gmail.com', 
     '+91-9321098765', '1993-12-10', 'Female', TRUE, TRUE),
    ('Arjun Nair', 'arjun.nair', 'arjun.nair@rediffmail.com', 
     '+91-9210987654', '1989-04-05', 'Male', TRUE, TRUE),
    ('Kavita Deshmukh', 'kavita.d', 'kavita.deshmukh@gmail.com', 
     '+91-9109876543', '1994-09-14', 'Female', TRUE, TRUE);

INSERT INTO projects (user_id, project_name, project_slug, description, color) VALUES
    (1, 'E-Commerce Website Development', 'ecommerce-website-dev', 
     'Building a modern e-commerce platform', '#FF6B6B'),
    (2, 'Mobile Banking App', 'mobile-banking-app', 
     'Secure mobile banking application', '#4ECDC4'),
    (3, 'School Management System', 'school-mgmt-system', 
     'Complete school administration system', '#45B7D1'),
    (1, 'Digital Marketing Campaign', 'digital-marketing-campaign', 
     'SEO and social media marketing', '#95E1D3'),
    (4, 'Healthcare Portal', 'healthcare-portal', 
     'Patient management system', '#F38181'),
    (5, 'Food Delivery Platform', 'food-delivery-platform', 
     'Restaurant and delivery management', '#FECEA8');

INSERT INTO project_members (project_id, user_id, role) VALUES
    (1, 1, 'owner'),
    (1, 2, 'admin'),
    (1, 3, 'member'),
    (2, 2, 'owner'),
    (2, 4, 'member'),
    (3, 3, 'owner'),
    (3, 5, 'member'),
    (4, 1, 'owner'),
    (4, 6, 'member'),
    (5, 4, 'owner'),
    (5, 7, 'member'),
    (6, 5, 'owner'),
    (6, 8, 'member');

INSERT INTO labels (project_id, label_name, color) VALUES
    (1, 'Frontend', '#FF6B6B'),
    (1, 'Backend', '#4ECDC4'),
    (1, 'Bug', '#FF0000'),
    (1, 'Enhancement', '#00FF00'),
    (2, 'Security', '#FFA500'),
    (2, 'UI/UX', '#9B59B6'),
    (3, 'Database', '#3498DB'),
    (4, 'Content', '#E74C3C'),
    (5, 'API', '#16A085');

INSERT INTO tasks (
    task_title, task_description, task_status, task_priority, 
    position, due_date, project_id, created_by, assigned_to
) VALUES
    ('Design Homepage UI', 'Create wireframes and mockups for homepage with modern design',
     'done', 'High', 1, '2024-12-05', 1, 1, 1),
    ('Implement Payment Gateway', 'Integrate Razorpay payment gateway with testing',
     'in-progress', 'High', 2, '2024-12-20', 1, 1, 2),
    ('Setup Database Schema', 'Design and implement PostgreSQL database with proper indexing',
     'done', 'High', 3, '2024-11-28', 1, 1, 3),
    ('User Authentication Module', 'Implement login/signup with OTP verification',
     'in-progress', 'Medium', 1, '2024-12-18', 2, 2, 2),
    ('KYC Verification Feature', 'Add Aadhaar and PAN verification for banking compliance',
     'todo', 'Urgent', 2, '2024-12-25', 2, 2, 4),
    ('Student Attendance System', 'Biometric attendance integration with hardware',
     'in-progress', 'Medium', 1, '2024-12-22', 3, 3, 3),
    ('Report Card Generation', 'Automated report card PDF generation system',
     'todo', 'Low', 2, '2025-01-10', 3, 3, 5),
    ('Social Media Strategy', 'Plan Instagram and Facebook campaigns for Q1',
     'done', 'Medium', 1, '2024-12-01', 4, 1, 6),
    ('SEO Optimization', 'Improve website ranking on Google search results',
     'in-progress', 'High', 2, '2024-12-15', 4, 1, 1),
    ('Doctor Appointment Booking', 'Online appointment scheduling system with calendar',
     'in-progress', 'High', 1, '2024-12-30', 5, 4, 4),
    ('Patient Medical Records', 'Digital health record management with encryption',
     'todo', 'Medium', 2, '2025-01-05', 5, 4, 7),
    ('Restaurant Partner Onboarding', 'Add 50 new restaurant partners in Mumbai',
     'in-progress', 'High', 1, '2024-12-28', 6, 5, 5),
    ('Delivery Tracking Feature', 'Real-time GPS tracking for delivery orders',
     'todo', 'High', 2, '2025-01-15', 6, 5, 8);

INSERT INTO task_labels (task_id, label_id) VALUES
    (1, 1),
    (2, 2),
    (3, 2),
    (4, 2),
    (5, 5),
    (6, 7),
    (9, 8),
    (10, 9),
    (12, 9);

INSERT INTO task_comments (task_id, user_id, comment_text, is_edited) VALUES
    (1, 2, 'Great design! Looks very professional and modern.', FALSE),
    (1, 1, 'Thanks! Made changes based on client feedback.', FALSE),
    (2, 1, 'Please ensure test mode is working properly before going live.', FALSE),
    (2, 2, 'Yes, tested with test credentials. All good!', FALSE),
    (4, 4, 'Should we use Firebase or custom OTP service?', FALSE),
    (4, 2, 'Let''s go with MSG91 for OTP. It''s reliable and cost-effective.', TRUE),
    (6, 5, 'Which biometric device are we using for this?', FALSE),
    (6, 3, 'We''re integrating with Mantra MFS100 scanner.', FALSE),
    (9, 6, 'Keywords research completed. Shared document in drive.', FALSE),
    (9, 1, 'Perfect! Will start implementation this week.', FALSE),
    (10, 7, 'Need to add slot availability feature too.', FALSE),
    (10, 4, 'Yes, adding it in the next sprint.', FALSE);

INSERT INTO task_attachments (
    task_id, user_id, file_name, storage_path, 
    file_type, file_size_bytes
) VALUES
    (1, 1, 'homepage_mockup_v2.fig', '/storage/projects/1/homepage_mockup_v2.fig',
     'application/figma', 2458624),
    (1, 1, 'design_specifications.pdf', '/storage/projects/1/design_specifications.pdf',
     'application/pdf', 1024567),
    (2, 2, 'razorpay_integration_guide.pdf', '/storage/projects/1/razorpay_integration_guide.pdf',
     'application/pdf', 856234),
    (3, 3, 'database_schema_diagram.png', '/storage/projects/1/database_schema_diagram.png',
     'image/png', 345678),
    (4, 2, 'auth_flow_diagram.jpg', '/storage/projects/2/auth_flow_diagram.jpg',
     'image/jpeg', 234567),
    (6, 3, 'biometric_api_docs.pdf', '/storage/projects/3/biometric_api_docs.pdf',
     'application/pdf', 1567890),
    (8, 6, 'social_media_calendar.xlsx', '/storage/projects/4/social_media_calendar.xlsx',
     'application/vnd.ms-excel', 45678),
    (9, 1, 'seo_keywords_report.csv', '/storage/projects/4/seo_keywords_report.csv',
     'text/csv', 23456),
    (10, 4, 'appointment_system_wireframe.pdf', '/storage/projects/5/appointment_system_wireframe.pdf',
     'application/pdf', 987654),
    (12, 5, 'restaurant_list_mumbai.xlsx', '/storage/projects/6/restaurant_list_mumbai.xlsx',
     'application/vnd.ms-excel', 67890);

INSERT INTO user_tasks (user_id, task_id) VALUES
    (1, 1), (2, 1),
    (2, 2),
    (3, 3),
    (2, 4),
    (4, 5),
    (3, 6),
    (5, 7),
    (6, 8),
    (1, 9), (6, 9),
    (4, 10),
    (7, 11),
    (5, 12),
    (8, 13);

INSERT INTO task_activities (task_id, user_id, action_type, old_value, new_value) VALUES
    (1, 1, 'created', NULL, 'Task created'),
    (1, 1, 'status_changed', 'todo', 'in-progress'),
    (1, 1, 'status_changed', 'in-progress', 'done'),
    (2, 1, 'created', NULL, 'Task created'),
    (2, 1, 'assigned', NULL, '2'),
    (2, 2, 'commented', NULL, 'Added implementation details'),
    (4, 2, 'created', NULL, 'Task created'),
    (4, 4, 'commented', NULL, 'Asked about OTP service');