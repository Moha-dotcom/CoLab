--- ROW LEVEL SECURITY AND POLICIES IMPLEMENTATION
-- This is where we fix and make sure everyone see there data based on  ID or Primary Keys


--Worked on ROW LEVEL SECURITY - Makes sure that Everyone has access to their Own Data

-- Every user can have access to the

SET ROLE colab_admin; --  Admin Controls who has access to the Public Schemas and Tables
SET ROLE colab_app; -- App roles Has access to any data that is granted by admi
-- Giving access to app to be able to see Who is collaborating
-- On their work
GRANT SELECT ON collaborators TO colab_app;

GRANT SELECT on pending_contribution_requests TO colab_app;
GRANT INSERT on pending_contribution_requests TO colab_app;
GRANT SELECT ON collaborators TO colab_app;
GRANT SELECT on contributions TO colab_app;
GRANT SELECT on pending_friends_list TO colab_app;
GRANT SELECT(id, full_name , username, profile_picture, bio ) on users TO colab_app ;
-- Revoke then Grant
REVOKE SELECT(id, username, profile_picture, bio ) on users FROM colab_app;

SELECT current_user;





ALTER TABLE WORKS ENABLE  ROW  LEVEL SECURITY;
--- ID of the Current User is 3. So this user gets to see his data
SET app.current_user_id = '1';
show app.current_user_id;


SELECT * FROM users u
JOIN works w ON u.id = w.owner_id;


--- Create Policy for Who can see and what work they can see
--- User => 2 Can only see their work.
--- We will also create Collaborator Policy Where the user can only see
-- What collaborater requested what work to collaborate on.

CREATE POLICY user_can_see_works ON works
    FOR SELECT
    USING (
    owner_id = current_setting('app.current_user_id')::BIGINT
    );

DROP POLICY user_can_see_works on works;

ALTER TABLE pending_contribution_requests ENABLE ROW LEVEL SECURITY;

-- This is a policy that restricts user to see other users pending_cotribution_requests
-- It a fence

CREATE POLICY collaborator_pending_requests_policy ON pending_contribution_requests
    FOR SELECT
    USING (
    user_id = current_setting('app.current_user_id')::BIGINT          -- requester sees their own
        OR work_id IN (
        SELECT id FROM works WHERE owner_id = current_setting('app.current_user_id')::BIGINT  -- owner sees requests for their works
    )
    );

-- Insert only allowed if requester_id = current user
CREATE POLICY insert_pending_request_policy ON pending_contribution_requests
    FOR INSERT
    WITH CHECK (user_id = current_setting('app.current_user_id')::BIGINT);

ALTER TABLE pending_friends_list ENABLE ROW LEVEL SECURITY ;
CREATE POLICY get_pending_friend_list_policy ON pending_friends_list
FOR SELECT
USING(requestor_id = current_setting('app.current_user_id')::BIGINT OR
      requested_id =  current_setting('app.current_user_id')::BIGINT);

DROP POLICY get_pending_friend_list_policy on pending_friends_list;
SET ROLE colab_app;
SET app.current_user_id = '2';



SELECT * FROM contributions;