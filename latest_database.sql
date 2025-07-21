-- Authors table
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(40),
    last_name VARCHAR(40),
    birth_date DATE,
    death_date DATE,
    genre VARCHAR(30)
);

-- Grouping of books into thematic cycles
CREATE TABLE groups_list (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT
);

-- Genre reference
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- Language reference
CREATE TABLE languages (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL,
    iso_code CHAR(2)
);

-- Books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255),
    author_id INTEGER NOT NULL REFERENCES authors(id),
    group_id INTEGER REFERENCES groups_list(id),
    genre_id INTEGER REFERENCES genres(id),
    language_id INTEGER REFERENCES languages(id),
    parody VARCHAR(255),
    pages_number INTEGER NOT NULL,
    cover_image_url VARCHAR(255),
    isbn VARCHAR(13) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Hashtags and junction table
CREATE TABLE hashtags (
    id SERIAL PRIMARY KEY,
    hashtag VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE book_hashtags (
    book_id INTEGER NOT NULL,
    hashtag_id INTEGER NOT NULL,
    PRIMARY KEY (book_id, hashtag_id),
    FOREIGN KEY (book_id) REFERENCES books(id),
    FOREIGN KEY (hashtag_id) REFERENCES hashtags(id)
);
CREATE OR REPLACE FUNCTION update_last_modified_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_modified = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_last_modified
BEFORE UPDATE ON books
FOR EACH ROW
EXECUTE FUNCTION update_last_modified_column();

-- Seed genres
INSERT INTO genres (name) VALUES
('Weird Fiction'),
('Horror'),
('Science Fiction'),
('Fantasy'),
('Cosmic Horror'),
('Supernatural'),
('Psychological Horror'),
('Gothic'),
('Parody'),
('Dark Fantasy');

-- Seed languages
INSERT INTO languages (name, iso_code) VALUES
('English', 'EN'),
('French', 'FR'),
('German', 'DE'),
('Spanish', 'ES'),
('Russian', 'RU'),
('Japanese', 'JA'),
('Italian', 'IT'),
('Chinese', 'ZH');

CREATE OR REPLACE VIEW book_full_view AS
SELECT
    b.id,
    b.title,
    a.first_name || ' ' || a.last_name AS author,
    g.name AS group_name,
    gr.name AS genre,
    l.name AS language,
    b.parody,
    b.pages_number,
    b.isbn,
    b.cover_image_url,
    b.created_at,
    b.last_modified
FROM books b
LEFT JOIN authors a ON b.author_id = a.id
LEFT JOIN groups_list g ON b.group_id = g.id
LEFT JOIN genres gr ON b.genre_id = gr.id
LEFT JOIN languages l ON b.language_id = l.id;

CREATE OR REPLACE VIEW author_works_view AS
SELECT
    a.id,
    a.first_name,
    a.last_name,
    CONCAT(a.first_name, ' ', a.last_name) AS full_name,
    COUNT(b.id) AS works_count
FROM authors a
LEFT JOIN books b ON a.id = b.author_id
GROUP BY a.id, a.first_name, a.last_name;

CREATE TABLE MembershipPlans (
    plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    duration INTERVAL
);
CREATE TABLE Members (
    member_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    address TEXT,
    plan_id INTEGER REFERENCES MembershipPlans(plan_id),
    subscription_start DATE,
    subscription_end DATE,
    payment_status VARCHAR(50)
);
CREATE TABLE PaymentDetails (
    payment_id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES Members(member_id),
    payment_type VARCHAR(50),
    provider_token VARCHAR(255),
    expiration_date DATE
);

CREATE TABLE LoginCredentials (
    credential_id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES Members(member_id),
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255)
)
CREATE OR REPLACE VIEW MemberProfile AS
SELECT 
    m.member_id,
    m.name,
    m.email,
    m.address,
    mp.plan_name,
    mp.price,
    m.subscription_start,
    m.subscription_end
FROM Members m
JOIN MembershipPlans mp ON m.plan_id = mp.plan_id;

CREATE TABLE MemberRoles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    description TEXT
);
ALTER TABLE Members ADD COLUMN role_id INTEGER REFERENCES MemberRoles(role_id);
CREATE TABLE Staff_Roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(100) NOT NULL,
    description TEXT,
    permissions TEXT
);

CREATE TABLE Staff (
    staff_id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    role_id INTEGER REFERENCES Staff_Roles(role_id),
    email VARCHAR(100),
    phone VARCHAR(15),
    address TEXT,
    hire_date DATE
);
CREATE TABLE StaffLoginCredentials (
    credential_id SERIAL PRIMARY KEY,
    staff_id INTEGER REFERENCES Staff(staff_id),
    username VARCHAR(50) UNIQUE,
    password_hash VARCHAR(255)
);

CREATE TYPE payment_status AS ENUM ('active', 'expired', 'failed', 'pending');

-- Step 2: Alter the column's data type
ALTER TABLE Members
ALTER COLUMN payment_status TYPE payment_status
USING payment_status::payment_status;

ALTER TABLE LoginCredentials ADD CONSTRAINT unique_member_login UNIQUE (member_id);
ALTER TABLE StaffLoginCredentials ADD CONSTRAINT unique_staff_login UNIQUE (staff_id);
CREATE OR REPLACE VIEW MemberDashboard AS
SELECT 
    m.member_id,
    m.name,
    m.email,
    m.phone,
    m.address,
    mp.plan_name,
    mp.price,
    m.subscription_start,
    m.subscription_end,
    m.payment_status,
    pd.payment_type,
    pd.expiration_date,
    mr.role_name AS member_role
FROM Members m
LEFT JOIN MembershipPlans mp ON m.plan_id = mp.plan_id
LEFT JOIN PaymentDetails pd ON m.member_id = pd.member_id
LEFT JOIN MemberRoles mr ON m.role_id = mr.role_id;

ALTER TABLE Members
ADD CONSTRAINT fk_members_plan_id
FOREIGN KEY (plan_id)
REFERENCES MembershipPlans(plan_id)
ON DELETE SET NULL;


