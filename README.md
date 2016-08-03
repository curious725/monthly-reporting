#   Vacation Management System for CyberCraft Inc.
This is implementation of the **Second Iteration**.

##  Installation
The project is powered by **Ruby**, **Node.js**, **Ruby on Rails**, **Backbone**, and **MySQL**.


### Ruby and RVM
1.  Install RVM.

    Follow instructions on https://rvm.io/.

2.  Install Ruby with the following command:
    ```
    rvm install 2.2.3
    rvm --default use 2.2.3
    ```

3.  Install **bundler** with the following command:
    ```
    gem install bundler
    ```
    For details see http://bundler.io.


### Project Sources
1.  Clone the project repository.

2.  Open the project directory.


### Node.js
Currently **Node.js** 4.x is proven to be sufficient.

For details on how to install **Node.js** see https://nodejs.org.


### MySQL
1.  Install **MySQL** related components with the following command:
    ```
    sudo apt-get install mysql-server mysql-client libmysqlclient-dev
    ```

### PhantomJS
1.  Install PhantomJS from [PPA](https://launchpad.net/~tanguy-patte/+archive/ubuntu/phantomjs)
    ```
    sudo apt-add-repository ppa:tanguy-patte/phantomjs
    sudo apt-get update
    sudo apt-get install phantomjs
    ```


### Resolve Project Dependencies
1.  Install the project related dependencies:
    ```
    bundle install
    ```
    In the command above failed, something like the following may be needed:
    ```
    bundle update <gem>
    ```
    Substitute `<gem>` with particular gem name.

### Configuration
1.  Generate secret token:
    ```
    echo SECRET_KEY_BASE=`rake secret` > .env
    ```

2.  Add DB related credentials:
    ```
    echo DATABASE_USER=user >> .env
    echo DATABASE_PASS=pass >> .env
    ```
    Replace `user` and `pass` with appropriate values.

2.  Add action mailer related credentials:
    ```
    echo EMAIL_USER=user >> .env
    echo EMAIL_PASS=pass >> .env
    ```
    Replace `user` and `pass` with appropriate values.

3.  Create DB with the following command:
    ```
    bundle exec rake db:create
    bundle exec rake db:migrate
    bundle exec rake db:seed
    ```

##  Deployment
The application server is to be hosted on **Heroku**.

### Prerequisites
The Ruby version must be `2.2.3`.

For the list of supported Ruby versions see appropriate **Heroku**
[documentation](https://devcenter.heroku.com/articles/ruby-support#ruby-versions).

### Create Heroku Application
1.  Create application on **Heroku**:
    ```
    heroku create
    ```

1.  Put application on **Heroku** into maintenance state:
    ```
    heroku maintenance:on
    ```

1.  Provision **ClearDB** add-on to provide **Heroku** dedicated **MySQL** server:
    ```
    heroku addons:create cleardb:ignite
    ```
    _HINT:_ For more details about **ClearDB**, see official [documentation](https://devcenter.heroku.com/articles/cleardb#provisioning-the-add-on).

1.  Create DB structure on **Heroku**:
    ```
    heroku run rake db:migrate
    ```

1.  Put application on **Heroku** into operational state:
    ```
    heroku maintenance:off
    ```
    _HINT:_ It is recommended to put application back into maintenance state
    after checking that application is up and running.

    _HINT:_ It is possible to check logs to get some details about application,
    with the following command:
    ```
    heroku logs
    ```


### DB Export
It is supposed to dump data from development environment.
All the related credentials are stored in the `.env` file.

1.  Issue the following command:
    ```
    mysqldump -u user_name -h host_name -p database_name  > dump.sql
    ```
    **NOTE:** You will be prompted for a password for specified DB `user_name`.

    **NOTE:** Replace `user_name`, `host_name`, and `database_name` with appropriate
    values.

    _HINT:_ It is good idea to provide a file name with a human readable time stamp.
    So the previous command should look like the following:
    ```
     mysqldump -u user_name -h host_name -p database_name  > `date +%F_%k-%M-%S`_dump.sql
    ```
    As a result, the file name will look like `2015-11-23_12-27-32_dump.sql`.


### DB Import on Heroku
The application uses **ClearDB** add-on as a DB service.

1.  Ensure the **ClearDB** is added and configured properly on **Heroku**.

1.  Put application on **Heroku** into maintenance state:
    ```
    heroku maintenance:on
    ```

1.  Get **ClearDB** credentials:
    ```
    heroku config
    ```
    _HINT:_ The output should contain the line that looks like as follows:
    ```
    CLEARDB_DATABASE_URL:     mysql://user_name:password@host_name/heroku_link?reconnect=true
    ```

1.  Issue the following command:
    ```
    mysql --host=host_name --user=user_name -p --reconnect heroku_link < dump.sql
    ```
    **NOTE:** You will be prompted for a password for specified `user_name`.

    **NOTE:** Use `user_name`, `password`, `host_name`, and `heroku_link` stored in `CLEARDB_DATABASE_URL`.
    See the previous step for details.

    **NOTE:** The operation may take some time, at least 3-12 seconds.

1.  Put application on **Heroku** into operational state:
    ```
    heroku maintenance:off
    ```
