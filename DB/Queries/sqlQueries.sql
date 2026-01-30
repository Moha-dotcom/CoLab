--- ALL QUERIES GO HERE

--- REjecting or approving Pending Contribution Request

SET ROLE colab_app;
SET app.current_user_id = '1';


SELECT * FROM work_access_records;
SELECT * FROM pending_contribution_requests;

UPDATE pending_contribution_requests
set nda_signed  = true
WHERE work_id = 1 AND user_id = 2;

-- GET all Pending Friend Request , Just for the Current user.
SELECT full_name, username, profile_picture  FROM pending_friends_list pfl
JOIN users u ON pfl.requestor_id = u.id;