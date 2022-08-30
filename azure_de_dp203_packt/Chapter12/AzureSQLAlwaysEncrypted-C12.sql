-- Always encrypted example

CREATE COLUMN MASTER KEY CMK  
WITH (  
     KEY_STORE_PROVIDER_NAME = 'AZURE_KEY_VAULT',   
     KEY_PATH = '<INSERT KEYVAULT PATH>'  
);  

CREATE COLUMN ENCRYPTION KEY CEK   
WITH VALUES  
(  
    COLUMN_MASTER_KEY = CMK,   
    ALGORITHM = 'RSA_OAEP',   
    ENCRYPTED_VALUE = <INSERT ENCRYPTION KEY>
);  

CREATE TABLE Customer (  
   [name] VARCHAR(30),
   [email] VARCHAR(10)   
        COLLATE  Latin1_General_BIN2 ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = CEK,  
        ENCRYPTION_TYPE = RANDOMIZED,  
        ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'),   
   [phone] VARCHAR (12),
   [SSN] VARCHAR (11)   
        COLLATE  Latin1_General_BIN2 ENCRYPTED WITH (COLUMN_ENCRYPTION_KEY = CEK,  
        ENCRYPTION_TYPE = DETERMINISTIC ,  
        ALGORITHM = 'AEAD_AES_256_CBC_HMAC_SHA_256'),   
);  

INSERT INTO Customer VALUES (101, 'Alan Li', 'alan@li.com', '111-222-3333', '111-11-1111');
INSERT INTO Customer VALUES (102, 'Becky King', 'becky@king.com', '222-333-4444', '222-22-2222');
INSERT INTO Customer VALUES (103, 'Daniel Martin', 'daniel@someone.com', '333-444-555', '333-33-3333');

SELECT * FROM Customer;