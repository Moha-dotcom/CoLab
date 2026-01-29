--- ALL TABLES GO HERE

CREATE TABLE USERS (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
   _id uuid  NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    profile_picture TEXT,
    bio TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE friendships (
                             id SERIAL PRIMARY KEY,
                             requester_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                             addressee_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                             status TEXT NOT NULL CHECK (status IN ('pending', 'accepted', 'rejected')),
                             created_at TIMESTAMP DEFAULT NOW(),
                             UNIQUE(requester_id, addressee_id)
);
