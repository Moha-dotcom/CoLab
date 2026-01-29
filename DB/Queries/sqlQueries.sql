--- ALL QUERIES GO HERE

--- REjecting or approving Pending Contribution Request
SELECT * FROM work_access_records;
SELECT * FROM pending_contribution_requests;

UPDATE pending_contribution_requests
set nda_signed  = true
WHERE work_id = 1 AND user_id = 2;

-- This is a function that takes args of pending request id and owner user id
-- If the Collaborator signed an NDA we Instantly give them access to Work When we
--  Approve them
-- We can also reject them if they did no sign an NDA.

-- it approves pending contributor if they have NDAs on File.
-- If they don't it reject Them.
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

SELECT approve_pending_contributor(1, 2);

SELECT * FROM work_access_records;
SELECT * FROM pending_contribution_requests;
SELECT * FROM collaborators;

