@echo off

:: NOTE(umut): script should run in the directory it is placed at, ensure that

:: to contain environment variables to this script
SETLOCAL

:: ends with \
set SCRIPT_LOCATION=%~dp0
:: removed \ suffix
set SCRIPT_LOCATION=%SCRIPT_LOCATION:~0,-1%

set CONTAINER_NAME=ecommerce_backend
set DATABASE_USER=all_mighty_admin
set DATABASE_NAME=ecommerce
set DATABASE_PASSWORD=mysecretpassword

if "%1"=="create" (
    docker create                                   ^
           --name %CONTAINER_NAME%                  ^
           -e POSTGRES_PASSWORD=%DATABASE_PASSWORD% ^
           -e POSTGRES_DB=%DATABASE_NAME%           ^
           -e POSTGRES_USER=%DATABASE_USER%         ^
           -it                                      ^
           -p 5432:5432                             ^
           postgres:alpine3.22

    docker start %CONTAINER_NAME% >NUL
    docker cp %SCRIPT_LOCATION%\..\assets\tables.sql %CONTAINER_NAME%:/person.sql >NUL
    echo Connecting to the container...
    :wait_pg
    docker exec -u postgres %CONTAINER_NAME% pg_isready -U %DATABASE_USER% -d %DATABASE_NAME% >NUL
    if errorlevel 1 (
        timeout /t 1 >nul
        goto wait_pg
    )
    timeout /t 1 >NUL
    echo Running intial SQL script...
    docker exec -u postgres %CONTAINER_NAME% psql -U %DATABASE_USER% -d %DATABASE_NAME% -f /person.sql >NUL
    docker stop %CONTAINER_NAME%
    echo ---
    echo Container is ready to start, run the following command to start it:
    echo %0 start
    goto :eof
) 

for %%A in ("remove" "delete" "rm") do if "%1"==%%A (
    echo Removing container
    docker rm %CONTAINER_NAME%

    goto :eof
)

for %%A in ("start" "run") do if "%1"==%%A (
    echo Starting container
    docker start %CONTAINER_NAME%

    goto :eof
)

if "%1"=="stop" (
    echo Stopping container
    docker stop %CONTAINER_NAME%

    goto :eof
)

for %%A in ("exec" "psql" "connect") do if "%1"==%%A (
    docker exec -it -u postgres %CONTAINER_NAME% psql ^
                                                 -U %DATABASE_USER% ^
                                                 -d %DATABASE_NAME%

    goto :eof
)

echo You should pass one of the following arguments: create, remove, start, stop, exec
echo Example: %0 create


ENDLOCAL
