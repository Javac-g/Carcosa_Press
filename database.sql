CREATE TABLE authors(
	id SERIAL PRIMARY KEY,
	first_name varchar(40),
	last_name varchar(40),
	birth_date DATE,
	death_date DATE,
	genre varchar(30)

);
CREATE TABLE books(
	id SERIAL PRIMARY KEY,
	title varchar(255),
	author_id INTEGER NOT NULL REFERENCES authors(id),
	genre varchar(30),
	language varchar(15),
	pages_number INTEGER NOT NULL,
	cover_image_url varchar(255)

);
CREATE TABLE hashtags(
	id SERIAL PRIMARY KEY,
	hashtag varchar(50) UNIQUE NOT NULL
);
ALTER TABLE books ADD COLUMN isbn VARCHAR(13) UNIQUE;
SELECT * FROM book_hashtags;

CREATE TABLE book_hashtags(
	book_id INTEGER NOT NULL,
	hashtag_id INTEGER NOT NULL,
	PRIMARY KEY (book_id , hashtag_id),
	FOREIGN KEY (book_id) REFERENCES books(id),
	FOREIGN KEY(hashtag_id) REFERENCES hashtags(id),
);
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
CREATE VIEW MemberProfile AS
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
CREATE TABLE Languages (
    language_id SERIAL PRIMARY KEY,
    language_name VARCHAR(100) NOT NULL,
    price INTEGER NOT NULL  -- price in local currency
);
CREATE TABLE ChatRooms (
    room_id SERIAL PRIMARY KEY,
    room_name VARCHAR(255) NOT NULL,
    language_id INTEGER REFERENCES Languages(language_id)
);
CREATE TABLE MembersLanguages (
    member_id INTEGER REFERENCES Members(member_id),
    language_id INTEGER REFERENCES Languages(language_id),
    PRIMARY KEY (member_id, language_id)
);
CREATE TABLE Messages (
    message_id SERIAL PRIMARY KEY,
    room_id INTEGER REFERENCES ChatRooms(room_id),
    member_id INTEGER REFERENCES Members(member_id),
    message_text TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE TABLE CurrencyTransactions (
    transaction_id SERIAL PRIMARY KEY,
    member_id INTEGER REFERENCES Members(member_id),
    amount INTEGER,
    transaction_type VARCHAR(50),  -- e.g., 'earn' or 'spend'
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
