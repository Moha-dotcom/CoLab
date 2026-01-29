CREATE ROLE colab_admin LOGIN PASSWORD 'Strongpassword' SUPERUSER;
CREATE ROLE colab_app LOGIN PASSWORD  'colab_password'

SET ROLE colab_admin