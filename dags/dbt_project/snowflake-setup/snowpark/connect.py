from dotenv import load_dotenv
import os
from snowflake.snowpark import Session

load_dotenv()

connection_parameters = {
    "account": os.getenv("SNOWFLAKE_ACCOUNT"),
    "user": os.getenv("SNOWFLAKE_USER"),
    "password": os.getenv("SNOWFLAKE_PASSWORD"),
    "warehouse": os.getenv("SNOWFLAKE_WAREHOUSE"),
    "database": os.getenv("SNOWFLAKE_DATABASE"),
    "schema": os.getenv("SNOWFLAKE_SCHEMA"),
    "role": os.getenv("SNOWFLAKE_ROLE"),
}

session = None

try:
    # Create Snowflake session
    session = Session.builder.configs(connection_parameters).create()

    print("Connected to Snowflake Successfully!")

    # Test the connection
    result = session.sql("SELECT CURRENT_VERSION()").collect()

    print(result)

    flatten_df = session.sql("""
        SELECT
            raw_data:"Name"::STRING                                 AS parent_name,
            raw_data:"Gender"::STRING                                AS gender,
            raw_data:"DOB"::DATE                                     AS dob,
            raw_data:"Address"."City"::STRING        AS city,
            raw_data:"Address"."State"::STRING        AS state,
            raw_data:"Address"."House Number"::STRING  AS house_number,
            raw_data:"Phone"."Office"::STRING          AS office_phone,
            raw_data:"Phone"."Personal"::STRING        AS personal_phone,
            k.value::STRING                                          AS kid_name
        FROM family_raw,
        LATERAL FLATTEN(input => raw_data:"Kids") k
    """)

    row_count = flatten_df.count()
    flatten_df.write.mode("overwrite").save_as_table("family")
    print(f"family table created with {row_count} rows")

except Exception as e:
    print("Failed to connect to Snowflake")
    print(e)

finally:
    if session:
        session.close()