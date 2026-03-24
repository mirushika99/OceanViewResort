--To create 

USE master;
GO

-- Check current state of sa
SELECT name, is_disabled, type_desc
FROM sys.server_principals
WHERE name = 'sa';
GO

-- Enable sa
ALTER LOGIN sa WITH PASSWORD = 'your_password',
    CHECK_POLICY = OFF,
    CHECK_EXPIRATION = OFF;
ALTER LOGIN sa ENABLE;
GO

-- Verify it worked
SELECT name, is_disabled
FROM sys.server_principals
WHERE name = 'sa';
GO