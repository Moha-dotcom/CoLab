-- This is a function that takes args of pending request id and owner user id
-- If the Collaborator signed an NDA we Instantly give them access to Work When we
--  Approve them
-- We can also reject them if they did no sign an NDA.
SHOW max_connections;

-- it approves pending contributor if they have NDAs on File.
-- If they Don't it reject Them.


CREATE OR REPLACE FUNCTION approve_pending_contributor(
    pending_request_id BIGINT,
    owner_user_id BIGINT
)
    RETURNS TEXT
    LANGUAGE plpgsql
AS $$
DECLARE
    work_id BIGINT;
    user_id BIGINT;
    role TEXT;
    nda_signed BOOLEAN;
BEGIN
    -- Fetch pending request and convert nda_signed_at to boolean
SELECT p.work_id, p.user_id, p.role, (n.nda_signed_at IS NOT NULL)
INTO work_id, user_id, role, nda_signed
FROM pending_contribution_requests p
         JOIN nadas n ON p.nda_id = n.id
WHERE p.id = pending_request_id;

-- Reject if NDA not signed
IF nda_signed IS NOT TRUE THEN
DELETE FROM pending_contribution_requests WHERE id = pending_request_id;
RETURN 'Pending request rejected: NDA not signed.';
END IF;

    -- Approve collaborator
INSERT INTO collaborators (work_id, user_id, role)
VALUES (work_id, user_id, role);

-- Log access in work_access_records
INSERT INTO work_access_records (work_id, user_id, granted_by_user_id, role, nda_signed, granted_at, notes)
VALUES (work_id, user_id, owner_user_id, role, TRUE, now(), 'Approved from pending request ID ' || pending_request_id);

-- Remove pending request
DELETE FROM pending_contribution_requests WHERE id = pending_request_id;

RETURN 'Pending request approved and collaborator added.';
END;
$$;


DROP FUNCTION approve_pending_contributor(pending_request_id BIGINT, owner_user_id BIGINT)

SELECT approve_pending_contributor(1, 1);


--- Sending Friend Request
--- prevent self-friend request
--- duplicated
-- re-adding existing friends
--  After all of that we insert the requestor into pending_friend_list

CREATE OR REPLACE FUNCTION send_friend_request(
    p_requester_id BIGINT,
    p_requested_id BIGINT
)
    RETURNS VOID
    LANGUAGE plpgsql
AS $$
BEGIN
    -- Prevent self-friend requests
    IF p_requester_id = p_requested_id THEN
        RAISE EXCEPTION 'You cannot send a friend request to yourself';
    END IF;

    -- Prevent duplicate pending requests
    IF EXISTS (
        SELECT 1
        FROM pending_friends_list pfl
        WHERE pfl.requestor_id = p_requester_id
          AND pfl.requested_id = p_requested_id
          AND pfl.status = 'pending'
    ) THEN
        RAISE EXCEPTION 'Friend request already pending';
    END IF;

    -- Prevent adding existing friends
    IF EXISTS (
        SELECT 1
        FROM friends f
        WHERE (f.user_id = p_requester_id AND f.friend_id = p_requested_id)
           OR (f.user_id = p_requested_id AND f.friend_id = p_requester_id)
    ) THEN
        RAISE EXCEPTION 'You are already friends';
    END IF;

    -- Create pending friend request
    INSERT INTO pending_friends_list (
        requestor_id,
        requested_id,
        status
    )
    VALUES (
               p_requester_id,
               p_requested_id,
               'pending'
           );
END;
$$;
set ROLE colab_app;
SET app.current_user_id = '3';
SELECT
    current_user;
SET ROLE colab_admin;


DROP FUNCTION send_friend_request(requestor_id BIGINT, requested_id BIGINT)







