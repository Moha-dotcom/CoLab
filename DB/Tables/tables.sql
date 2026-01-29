


CREATE TABLE users (
    id INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
   _id uuid  NOT NULL DEFAULT gen_random_uuid() UNIQUE,
    username TEXT UNIQUE NOT NULL,
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT,
    profile_picture TEXT,
    bio TEXT,
    created_at timestamptz DEFAULT now() NOT NULL ,
    delete_at timestamptz DEFAULT  now() NOT NULL ,
    updated_at timestamptz DEFAULT  now()NOT NULL
);




CREATE TABLE works (
    id BIGINT PRIMARY KEY GENERATED ALWAYS AS  IDENTITY ,
    public_id uuid NOT NULL DEFAULT gen_random_uuid() UNIQUE ,
    owner_id INTEGER references  users(id) NOT NULL ,
    title VARCHAR(250) NOT NULL,
    description text NOT NULL ,
    work_type TEXT NOT NULL CHECK (
        work_type IN ('idea', 'project', 'research', 'content')
        ),

    work_field TEXT NOT NULL CHECK (
        work_field IN ('AI', 'Blockchain', 'Education', 'Art', 'Health')
        ),
    status TEXT NOT NULL   CHECK (status IN ( 'pending','ongoing', 'needs_help', 'cancelled'
        )),
    created_at timestamptz DEFAULT now() NOT NULL ,
    delete_at timestamptz DEFAULT  now() NOT NULL ,
    updated_at timestamptz DEFAULT  now()NOT NULL,
    UNIQUE  ( owner_id, title )


);

DROP TABLE works;


ALTER TABLE WORKS ALTER COLUMN id TYPE BIGINT;
ALTER TABLE USERS RENAME COLUMN _Id to public_id;
ALTER TABLE USERS ALTER COLUMN id TYPE BIGINT;


--- Collaborator table
CREATE TABLE collaborators
(
    id BIGINT PRIMARY KEY generated always as IDENTITY,
    public_id uuid DEFAULT gen_random_uuid() NOT NULL UNIQUE,
    work_id BIGINT NOT NULL references works(id)  ON DELETE CASCADE,
    user_id BIGINT NOT NULL  references users(id) ON DELETE CASCADE ,
    role TEXT NOT NULL CHECK (
        role IN ('owner', 'editor', 'viewer', 'contributor')
        ),
    added_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (work_id, user_id)
);
-- =======================
-- CONTRIBUTIONS TABLE
-- =======================
CREATE TABLE contributions (
    id BIGINT PRIMARY KEY  generated always as  IDENTITY ,
    work_id BIGINT NOT NULL references works(id)  ON DELETE CASCADE,
    user_id BIGINT NOT NULL  references users(id) ON DELETE CASCADE ,
    content text NOT NULL ,
    type TEXT NOT NULL CHECK (
        type IN ('update', 'idea_note', 'progress', 'milestone')
        ),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()

);
CREATE TABLE nadas (
 id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
 work_id BIGINT NOT NULL REFERENCES works(id) ON DELETE CASCADE,
user_id BIGINT NOT NULL REFERENCES users(id),
 owner_id BIGINT NOT NULL REFERENCES users(id), -- who owns the work
role TEXT NOT NULL CHECK ( role IN ('editor', 'viewer')),
 nda_signed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
nda_s3_url TEXT NOT NULL,      -- S3 URL to the signed NDA
nda_s3_id TEXT NOT NULL,       -- S3 object ID for reference
notes TEXT,                    -- optional notes
UNIQUE(work_id, user_id)       -- one NDA per user per work
);


CREATE TABLE pending_contribution_requests (
 id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
 work_id BIGINT NOT NULL REFERENCES works(id) ON DELETE CASCADE,
 user_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
 role TEXT NOT NULL CHECK (
     role IN ('owner', 'editor', 'viewer', 'contributor')
     ),
 status TEXT NOT NULL DEFAULT 'pending' CHECK (
     status IN ('pending', 'approved', 'rejected')
     ),
 nda_id BIGINT NOT NULL REFERENCES nadas(id) ON DELETE CASCADE,  -- link to NDA
 nda_signed BOOLEAN NOT NULL DEFAULT FALSE,   -- true if accepted NDA
 message TEXT,  -- optional message explaining why they want to contribute
requested_at TIMESTAMPTZ NOT NULL DEFAULT now(),
UNIQUE(work_id, user_id)  -- prevent duplicate requests
);



CREATE TABLE work_access_records (
id BIGINT PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
work_id BIGINT NOT NULL REFERENCES works(id) ON DELETE CASCADE,
user_id BIGINT NOT NULL REFERENCES users(id),
granted_by_user_id BIGINT NOT NULL REFERENCES users(id),  -- usually the work owner
role TEXT NOT NULL CHECK ( role IN ('owner', 'editor', 'viewer')),
nda_signed BOOLEAN NOT NULL DEFAULT TRUE,      -- was NDA signed?
granted_at TIMESTAMPTZ NOT NULL DEFAULT now(), -- timestamp of approval
notes TEXT                                      -- optional notes
);




